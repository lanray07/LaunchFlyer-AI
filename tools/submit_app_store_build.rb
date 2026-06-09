#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "openssl"
require "time"
require "uri"

API_BASE = "https://api.appstoreconnect.apple.com/v1"

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

def get_data(path)
  JSON.parse(request_json("get", path).body).fetch("data")
end

def query_path(path, params)
  encoded = URI.encode_www_form(params)
  "#{path}?#{encoded}"
end

def app_store_version(app_id, version_string)
  path = query_path(
    "/apps/#{app_id}/appStoreVersions",
    {
      "filter[platform]" => "IOS",
      "filter[versionString]" => version_string,
      "limit" => "50"
    }
  )

  versions = get_data(path)
  version = versions.find do |candidate|
    attrs = candidate.fetch("attributes")
    attrs["platform"] == "IOS" && attrs["versionString"] == version_string
  end

  raise "No iOS App Store version #{version_string} found for app #{app_id}" unless version

  version
end

def latest_matching_build(app_id, build_number)
  path = query_path(
    "/apps/#{app_id}/builds",
    {
      "limit" => "200"
    }
  )

  get_data(path).find { |build| build.dig("attributes", "version") == build_number }
end

def wait_for_processed_build(app_id, build_number, timeout_minutes)
  deadline = Time.now + (timeout_minutes * 60)

  loop do
    build = latest_matching_build(app_id, build_number)
    if build
      attrs = build.fetch("attributes")
      state = attrs.fetch("processingState")
      puts "Build #{build_number} is #{state} (build id #{build.fetch("id")})"

      return build if state == "VALID"

      raise "Build #{build_number} processing failed with state #{state}" if %w[FAILED INVALID].include?(state)
    else
      puts "Build #{build_number} is not visible in App Store Connect yet"
    end

    raise "Timed out waiting for build #{build_number} to become VALID" if Time.now >= deadline

    sleep 60
  end
end

def attach_build_to_version(app_store_version_id, build_id)
  body = {
    data: {
      type: "builds",
      id: build_id
    }
  }

  request_json(
    "patch",
    "/appStoreVersions/#{app_store_version_id}/relationships/build",
    body: body,
    expected: [200, 204]
  )
  puts "Attached build #{build_id} to App Store version #{app_store_version_id}"
end

def active_review_submissions(app_id)
  path = query_path(
    "/apps/#{app_id}/reviewSubmissions",
    {
      "filter[platform]" => "IOS",
      "limit" => "200"
    }
  )
  active_states = %w[READY_FOR_REVIEW WAITING_FOR_REVIEW IN_REVIEW UNRESOLVED_ISSUES CANCELING COMPLETING]

  get_data(path).select { |submission| active_states.include?(submission.dig("attributes", "state")) }
end

def create_review_submission(app_id)
  body = {
    data: {
      type: "reviewSubmissions",
      attributes: {
        platform: "IOS"
      },
      relationships: {
        app: {
          data: {
            type: "apps",
            id: app_id
          }
        }
      }
    }
  }

  response = request_json("post", "/reviewSubmissions", body: body, expected: [201])
  data = JSON.parse(response.body).fetch("data")
  puts "Created review submission #{data.fetch("id")}"
  data
end

def add_version_to_review_submission(review_submission_id, app_store_version_id)
  body = {
    data: {
      type: "reviewSubmissionItems",
      relationships: {
        reviewSubmission: {
          data: {
            type: "reviewSubmissions",
            id: review_submission_id
          }
        },
        appStoreVersion: {
          data: {
            type: "appStoreVersions",
            id: app_store_version_id
          }
        }
      }
    }
  }

  response = request_json("post", "/reviewSubmissionItems", body: body, expected: [201])
  item = JSON.parse(response.body).fetch("data")
  puts "Added App Store version #{app_store_version_id} to review submission #{review_submission_id}"
  item
end

def submit_review_submission(review_submission_id)
  body = {
    data: {
      id: review_submission_id,
      type: "reviewSubmissions",
      attributes: {
        submitted: true
      }
    }
  }

  response = request_json("patch", "/reviewSubmissions/#{review_submission_id}", body: body, expected: [200])
  data = JSON.parse(response.body).fetch("data")
  puts "Submitted review submission #{review_submission_id}; state: #{data.dig("attributes", "state")}"
  data
end

app_id = ENV.fetch("APP_ID", "6777979967")
version_string = ENV.fetch("APP_VERSION", "1.0")
build_number = env!("BUILD_NUMBER")
timeout_minutes = ENV.fetch("PROCESSING_TIMEOUT_MINUTES", "45").to_i

version = app_store_version(app_id, version_string)
version_id = version.fetch("id")
version_state = version.dig("attributes", "appStoreState") || version.dig("attributes", "appVersionState")
puts "Found App Store version #{version_string} (#{version_id}) state: #{version_state}"

build = wait_for_processed_build(app_id, build_number, timeout_minutes)
attach_build_to_version(version_id, build.fetch("id"))

active_submissions = active_review_submissions(app_id)
unless active_submissions.empty?
  summary = active_submissions.map { |submission| "#{submission.fetch("id")}:#{submission.dig("attributes", "state")}" }.join(", ")
  raise "An active review submission already exists: #{summary}"
end

submission = create_review_submission(app_id)
add_version_to_review_submission(submission.fetch("id"), version_id)
submit_review_submission(submission.fetch("id"))
