# frozen_string_literal: true
require_relative 'errors'

module Bunq
  class Signature
    # headers in raw_headers hash in rest client are all lower case
    BUNQ_HEADER_PREFIX = 'X-Bunq-'.downcase
    BUNQ_SERVER_SIGNATURE_RESPONSE_HEADER = 'X-Bunq-Server-Signature'.downcase

    def initialize(private_key, server_public_key)
      fail ArgumentError, 'private_key is mandatory' unless private_key
      fail ArgumentError, 'server_public_key is mandatory' unless server_public_key

      @private_key = OpenSSL::PKey::RSA.new(private_key)
      @server_public_key = OpenSSL::PKey::RSA.new(server_public_key)
    end

    def create(body)
      signature = private_key.sign(digest, body.to_s)

      Base64.strict_encode64(signature)
    end

    def verify!(response)
      return if skip_signature_check(response.code)

      signature_headers = response.raw_headers.find { |k, _| k.to_s.downcase == BUNQ_SERVER_SIGNATURE_RESPONSE_HEADER }
      unless signature_headers
        fail AbsentResponseSignature.new(code: response.code, headers: response.raw_headers, body: response.body)
      end

      signature_headers_value = signature_headers[1]
      unless signature_headers_value
        fail AbsentResponseSignature.new(code: response.code, headers: response.raw_headers, body: response.body)
      end

      signature = Base64.strict_decode64(signature_headers_value.first)
      if !verify_modern(signature, response) && !verify_legacy(signature, response)
        fail InvalidResponseSignature.new(code: response.code, headers: response.raw_headers, body: response.body)
      end
    end

    private

    attr_reader :private_key, :server_public_key

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def verifiable_header?(header_name, _)
      _header_name = header_name.to_s.downcase
      _header_name.start_with?(BUNQ_HEADER_PREFIX) && _header_name != BUNQ_SERVER_SIGNATURE_RESPONSE_HEADER
    end

    def skip_signature_check(responseCode)
      (Bunq.configuration.sandbox && responseCode == 409) || responseCode == 429
    end

    def verify_legacy(signature, response)
      sorted_bunq_headers = response
        .raw_headers
        .select(&method(:verifiable_header?))
        .sort
        .to_h
        .map do |k, v|
          "#{k.to_s.split('-').map(&:capitalize).join('-')}: #{v.first}"
        end

      verify(signature, %(#{response.code}\n#{sorted_bunq_headers.join("\n")}\n\n#{response.body}))
    end

    def verify_modern(signature, response)
      verify(signature, response.body)
    end

    def verify(signature, data)
      server_public_key.verify(digest, signature, data)
    end
  end
end
