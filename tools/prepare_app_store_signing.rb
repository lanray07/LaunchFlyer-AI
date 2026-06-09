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

def delete_resource(resource_type, resource_id)
  return if resource_id.nil? || resource_id.empty?

  request_json("delete", "/#{resource_type}/#{resource_id}", expected: [204, 404])
  puts "Deleted stale #{resource_type} #{resource_id}"
end

def query_path(path, params)
  encoded = URI.encode_www_form(params)
  "#{path}?#{encoded}"
end

def bundle_id_for(identifier)
  path = query_path("/bundleIds", { "filter[identifier]" => identifier, "limit" => "10" })
  bundle_id = get_data(path).find { |item| item.dig("attributes", "identifier") == identifier }
  bundle_id
end

def fetch_app_bundle_identifier(app_id)
  response = request_json("get", "/apps/#{app_id}", expected: [200])
  JSON.parse(response.body).fetch("data").dig("attributes", "bundleId")
end

def create_certificate(csr_path)
  csr_content = File.read(csr_path)
  body = {
    data: {
      type: "certificates",
      attributes: {
        certificateType: "IOS_DISTRIBUTION",
        csrContent: csr_content
      }
    }
  }

  response = request_json("post", "/certificates", body: body, expected: [201])
  JSON.parse(response.body).fetch("data")
end

def create_profile(bundle_id, certificate_id, profile_name)
  body = {
    data: {
      type: "profiles",
      attributes: {
        name: profile_name,
        profileType: "IOS_APP_STORE"
      },
      relationships: {
        bundleId: {
          data: {
            type: "bundleIds",
            id: bundle_id
          }
        },
        certificates: {
          data: [
            {
              type: "certificates",
              id: certificate_id
            }
          ]
        }
      }
    }
  }

  response = request_json("post", "/profiles", body: body, expected: [201])
  JSON.parse(response.body).fetch("data")
end

def append_github_env(values)
  github_env = env!("GITHUB_ENV")
  File.open(github_env, "a") do |file|
    values.each do |key, value|
      file.puts "#{key}=#{value}"
    end
  end
end

app_id = ENV.fetch("APP_ID", "6777979967")
requested_bundle_identifier = ENV.fetch("BUNDLE_ID", "com.launchflyer.ai")
csr_path = env!("DIST_CSR_PATH")
cert_path = env!("DIST_CERT_PATH")
profile_path = env!("PROFILE_PATH")
profile_name = "LaunchFlyer AI GitHub App Store #{Time.now.utc.strftime("%Y%m%d%H%M%S")}"

app_bundle_identifier = fetch_app_bundle_identifier(app_id)
candidate_bundle_identifiers = [requested_bundle_identifier, app_bundle_identifier].compact.uniq
bundle_id = nil
bundle_identifier = nil

candidate_bundle_identifiers.each do |candidate|
  bundle_id = bundle_id_for(candidate)
  if bundle_id
    bundle_identifier = candidate
    break
  end
end

raise "No Bundle ID resource found for candidates: #{candidate_bundle_identifiers.join(", ")}" unless bundle_id

puts "Found bundle ID #{bundle_id.fetch("id")} for #{bundle_identifier}"

delete_resource("profiles", ENV["REVOKE_PROFILE_ID"])
delete_resource("certificates", ENV["REVOKE_DISTRIBUTION_CERTIFICATE_ID"])

certificate = create_certificate(csr_path)
certificate_id = certificate.fetch("id")
certificate_content = certificate.fetch("attributes").fetch("certificateContent")
File.binwrite(cert_path, Base64.decode64(certificate_content))
puts "Created distribution certificate #{certificate_id}"

profile = create_profile(bundle_id.fetch("id"), certificate_id, profile_name)
profile_id = profile.fetch("id")
profile_content = profile.fetch("attributes").fetch("profileContent")
File.binwrite(profile_path, Base64.decode64(profile_content))
puts "Created App Store provisioning profile #{profile_id}: #{profile_name}"

append_github_env(
  "BUNDLE_ID" => bundle_identifier,
  "DISTRIBUTION_CERTIFICATE_ID" => certificate_id,
  "PROFILE_ID" => profile_id,
  "PROFILE_NAME" => profile_name
)
