#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "openssl"
require "uri"

API_BASE = "https://api.appstoreconnect.apple.com/v1"
IMAGE_DIR = "LaunchFlyerAI/MarketingAssets/upload-ready/app-store-connect/subscription-promotional-no-text-1024x1024"

PROMOTIONAL_IMAGES = [
  {
    product_id: "launchflyer.creator.monthly",
    label: "Creator Monthly",
    path: "#{IMAGE_DIR}/creator-monthly-promotional-image-1024x1024.png"
  },
  {
    product_id: "launchflyer.creator.yearly",
    label: "Creator Yearly",
    path: "#{IMAGE_DIR}/creator-yearly-promotional-image-1024x1024.png"
  },
  {
    product_id: "launchflyer.business.monthly",
    label: "Business Monthly",
    path: "#{IMAGE_DIR}/business-monthly-promotional-image-1024x1024.png"
  },
  {
    product_id: "launchflyer.agency.monthly",
    label: "Agency Monthly",
    path: "#{IMAGE_DIR}/agency-monthly-promotional-image-1024x1024.png"
  }
].freeze

KNOWN_SUBSCRIPTION_IDS = {
  "launchflyer.creator.monthly" => "6778076040",
  "launchflyer.creator.yearly" => "6778076907"
}.freeze

def env!(name)
  value = ENV[name]
  raise "Missing required environment variable #{name}" if value.nil? || value.empty?

  value
end

def base64url(value)
  Base64.urlsafe_encode64(value).delete("=")
end

def int_to_fixed_bytes(value, width)
  hex = value.to_s(16)
  hex = "0#{hex}" if hex.length.odd?
  bytes = [hex].pack("H*")
  raise "ECDSA signature integer is too wide" if bytes.bytesize > width

  ("\x00".b * (width - bytes.bytesize)) + bytes
end

def jwt_token
  key_id = env!("ASC_KEY_ID")
  issuer_id = env!("ASC_ISSUER_ID")
  private_key = env!("ASC_PRIVATE_KEY").gsub("\\n", "\n")

  key = OpenSSL::PKey.read(private_key)
  now = Time.now.to_i
  header = { alg: "ES256", kid: key_id, typ: "JWT" }
  payload = {
    iss: issuer_id,
    iat: now,
    exp: now + (20 * 60),
    aud: "appstoreconnect-v1"
  }

  signing_input = "#{base64url(header.to_json)}.#{base64url(payload.to_json)}"
  digest = OpenSSL::Digest::SHA256.digest(signing_input)
  der_signature = key.dsa_sign_asn1(digest)
  sequence = OpenSSL::ASN1.decode(der_signature)
  r, s = sequence.value.map(&:value)
  raw_signature = int_to_fixed_bytes(r, 32) + int_to_fixed_bytes(s, 32)

  "#{signing_input}.#{base64url(raw_signature)}"
end

def path_from_link(link)
  return nil if link.nil? || link.empty?

  uri = URI(link)
  path = uri.relative? ? link : uri.request_uri
  path.start_with?("/v1/") ? path.delete_prefix("/v1") : path
end

def query_path(path, params)
  encoded = URI.encode_www_form(params)
  "#{path}?#{encoded}"
end

def request_json(method, path, body: nil, expected: [200])
  uri = URI("#{API_BASE}#{path}")
  request_class = Net::HTTP.const_get(method.capitalize)
  request = request_class.new(uri)
  request["Authorization"] = "Bearer #{jwt_token}"
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request.body = JSON.generate(body) if body

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  return response if expected.include?(response.code.to_i)

  raise "App Store Connect #{method.upcase} #{path} failed: HTTP #{response.code} #{response.body}"
end

def get_paged_data(path)
  data = []
  next_path = path

  while next_path
    payload = JSON.parse(request_json("get", next_path).body)
    data.concat(payload.fetch("data"))
    next_path = path_from_link(payload.dig("links", "next"))
  end

  data
end

def discover_subscription_ids(app_id)
  groups = get_paged_data(query_path("/apps/#{app_id}/subscriptionGroups", { "limit" => "200" }))
  puts "Found #{groups.length} subscription group(s)"

  groups.each_with_object({}) do |group, result|
    group_id = group.fetch("id")
    group_name = group.dig("attributes", "referenceName") || group.dig("attributes", "name") || group_id
    subscriptions = get_paged_data(
      query_path("/subscriptionGroups/#{group_id}/subscriptions", { "limit" => "200" })
    )
    puts "Found #{subscriptions.length} subscription(s) in #{group_name}"

    subscriptions.each do |subscription|
      attrs = subscription.fetch("attributes")
      product_id = attrs["productId"] || attrs["productID"]
      next unless product_id

      result[product_id] = subscription.fetch("id")
      puts "Resolved #{product_id} to subscription #{subscription.fetch("id")}"
    end
  end
end

def target_subscriptions(app_id)
  discovered = discover_subscription_ids(app_id)

  PROMOTIONAL_IMAGES.filter_map do |image|
    product_id = image.fetch(:product_id)
    subscription_id = discovered[product_id] || KNOWN_SUBSCRIPTION_IDS[product_id]

    unless subscription_id
      warn "Skipping #{image.fetch(:label)}; no App Store Connect subscription found for #{product_id}"
      next
    end

    image.merge(subscription_id: subscription_id)
  end
end

def existing_images(subscription_id)
  get_paged_data(query_path("/subscriptions/#{subscription_id}/images", { "limit" => "50" }))
end

def delete_image(image_id)
  request_json("delete", "/subscriptionImages/#{image_id}", expected: [204, 404])
end

def create_reservation(subscription_id, file_name, file_size)
  body = {
    data: {
      type: "subscriptionImages",
      attributes: {
        fileName: file_name,
        fileSize: file_size
      },
      relationships: {
        subscription: {
          data: {
            type: "subscriptions",
            id: subscription_id
          }
        }
      }
    }
  }

  response = request_json("post", "/subscriptionImages", body: body, expected: [201])
  JSON.parse(response.body).fetch("data")
end

def upload_operations(file_bytes, upload_operations)
  upload_operations.each do |operation|
    uri = URI(operation.fetch("url"))
    request = Net::HTTP.const_get(operation.fetch("method").capitalize).new(uri)

    operation.fetch("requestHeaders", []).each do |header|
      request[header.fetch("name")] = header.fetch("value")
    end

    offset = operation.fetch("offset")
    length = operation.fetch("length")
    request.body = file_bytes.byteslice(offset, length)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    next if response.code.to_i.between?(200, 299)

    raise "Asset upload failed: HTTP #{response.code} #{response.body}"
  end
end

def commit_image(image_id)
  body = {
    data: {
      id: image_id,
      type: "subscriptionImages",
      attributes: {
        uploaded: true
      }
    }
  }

  request_json("patch", "/subscriptionImages/#{image_id}", body: body, expected: [200])
end

def verify_image(image_id)
  response = request_json("get", "/subscriptionImages/#{image_id}", expected: [200])
  JSON.parse(response.body).fetch("data").fetch("attributes")
end

app_id = ENV.fetch("APP_ID", "6777979967")
targets = target_subscriptions(app_id)
raise "No subscription promotional image targets were resolved" if targets.empty?

targets.each do |image|
  path = image.fetch(:path)
  raise "Missing promotional image file: #{path}" unless File.file?(path)

  file_bytes = File.binread(path)
  file_name = File.basename(path)
  file_size = file_bytes.bytesize
  subscription_id = image.fetch(:subscription_id)
  label = image.fetch(:label)

  puts "Uploading #{label} promotional image (#{file_name}, #{file_size} bytes) to subscription #{subscription_id}"

  existing_images(subscription_id).each do |existing_image|
    existing_id = existing_image.fetch("id")
    puts "Deleting existing promotional image #{existing_id}"
    delete_image(existing_id)
  end

  reservation = create_reservation(subscription_id, file_name, file_size)
  image_id = reservation.fetch("id")
  upload_operations(file_bytes, reservation.fetch("attributes").fetch("uploadOperations"))
  commit_image(image_id)
  attributes = verify_image(image_id)

  puts "Uploaded #{label}: #{attributes.to_json}"
end
