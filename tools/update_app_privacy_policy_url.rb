#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "openssl"
require "uri"

API_BASE = "https://api.appstoreconnect.apple.com/v1"
DEFAULT_APP_ID = "6777979967"
DEFAULT_PRIVACY_POLICY_URL = "https://lanray07.github.io/LaunchFlyer-AI/privacy-policy.html"

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

def app_info_ids(app_id)
  path = "/apps/#{app_id}/appInfos?fields[appInfos]=id&limit=10"
  get_data(path).map { |app_info| app_info.fetch("id") }
end

def localizations_for(app_info_id)
  path = "/appInfos/#{app_info_id}/appInfoLocalizations?fields[appInfoLocalizations]=locale,privacyPolicyUrl&limit=50"
  get_data(path)
end

def patch_privacy_policy_url(localization_id, url)
  body = {
    data: {
      id: localization_id,
      type: "appInfoLocalizations",
      attributes: {
        privacyPolicyUrl: url
      }
    }
  }

  request_json("patch", "/appInfoLocalizations/#{localization_id}", body: body)
end

app_id = ENV.fetch("APP_ID", DEFAULT_APP_ID)
privacy_policy_url = ENV.fetch("PRIVACY_POLICY_URL", DEFAULT_PRIVACY_POLICY_URL)
preferred_locale = ENV["APP_INFO_LOCALE"]

raise "Privacy policy URL must start with https://" unless privacy_policy_url.start_with?("https://")

localizations = app_info_ids(app_id).flat_map { |app_info_id| localizations_for(app_info_id) }
raise "No App Info localizations found for app #{app_id}" if localizations.empty?

targets = if preferred_locale && !preferred_locale.empty?
            localizations.select { |localization| localization.dig("attributes", "locale") == preferred_locale }
          else
            localizations
          end

raise "No App Info localization matched #{preferred_locale.inspect}" if targets.empty?

targets.each do |localization|
  id = localization.fetch("id")
  locale = localization.dig("attributes", "locale")
  response = patch_privacy_policy_url(id, privacy_policy_url)
  attributes = JSON.parse(response.body).fetch("data").fetch("attributes")

  puts "Updated #{locale} privacyPolicyUrl to #{attributes.fetch("privacyPolicyUrl")}"
end
