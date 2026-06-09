#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "openssl"
require "uri"

API_BASE = "https://api.appstoreconnect.apple.com/v1"

SCREENSHOTS = [
  {
    subscription_id: "6778076040",
    label: "Creator Monthly",
    path: "LaunchFlyerAI/MarketingAssets/upload-ready/app-store-connect/subscription-review-compatible/creator-monthly-review-iphone-6.5-1284x2778.jpg"
  },
  {
    subscription_id: "6778076907",
    label: "Creator Yearly",
    path: "LaunchFlyerAI/MarketingAssets/upload-ready/app-store-connect/subscription-review-compatible/creator-yearly-review-iphone-6.5-1284x2778.jpg"
  }
].freeze

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

def get_existing_screenshot(subscription_id)
  response = request_json(
    "get",
    "/subscriptions/#{subscription_id}/appStoreReviewScreenshot",
    expected: [200, 404]
  )
  return nil if response.code.to_i == 404

  JSON.parse(response.body).dig("data", "id")
end

def delete_screenshot(screenshot_id)
  request_json(
    "delete",
    "/subscriptionAppStoreReviewScreenshots/#{screenshot_id}",
    expected: [204, 404]
  )
end

def create_reservation(subscription_id, file_name, file_size)
  body = {
    data: {
      type: "subscriptionAppStoreReviewScreenshots",
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

  response = request_json("post", "/subscriptionAppStoreReviewScreenshots", body: body, expected: [201])
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

def commit_screenshot(screenshot_id)
  body = {
    data: {
      id: screenshot_id,
      type: "subscriptionAppStoreReviewScreenshots",
      attributes: {
        uploaded: true
      }
    }
  }

  request_json(
    "patch",
    "/subscriptionAppStoreReviewScreenshots/#{screenshot_id}",
    body: body,
    expected: [200]
  )
end

def verify_screenshot(screenshot_id)
  response = request_json(
    "get",
    "/subscriptionAppStoreReviewScreenshots/#{screenshot_id}",
    expected: [200]
  )
  JSON.parse(response.body).fetch("data").fetch("attributes")
end

SCREENSHOTS.each do |screenshot|
  path = screenshot.fetch(:path)
  raise "Missing screenshot file: #{path}" unless File.file?(path)

  file_bytes = File.binread(path)
  file_name = File.basename(path)
  file_size = file_bytes.bytesize
  subscription_id = screenshot.fetch(:subscription_id)

  puts "Uploading #{screenshot.fetch(:label)} review screenshot (#{file_name}, #{file_size} bytes)"

  existing_id = get_existing_screenshot(subscription_id)
  if existing_id
    puts "Deleting existing review screenshot #{existing_id}"
    delete_screenshot(existing_id)
  end

  reservation = create_reservation(subscription_id, file_name, file_size)
  screenshot_id = reservation.fetch("id")
  upload_operations(file_bytes, reservation.fetch("attributes").fetch("uploadOperations"))
  commit_screenshot(screenshot_id)
  attributes = verify_screenshot(screenshot_id)

  puts "Uploaded #{screenshot.fetch(:label)}: #{attributes.to_json}"
end
