require_relative 'errors'

module Bunq
  class Signature
    # headers in raw_headers hash in rest client are all lower case
    BUNQ_HEADER_PREFIX = 'X-Bunq-'.downcase
    BUNQ_SERVER_SIGNATURE_RESPONSE_HEADER = 'X-Bunq-Server-Signature'.downcase
    CACHE_CONTROL_HEADER = 'Cache-Control'.downcase
    USER_AGENT_HEADER = 'User-Agent'.downcase
    SIGNABLE_HEADERS = [CACHE_CONTROL_HEADER, USER_AGENT_HEADER]

    def initialize(private_key, server_public_key)
      fail ArgumentError.new('private_key is mandatory') unless private_key
      fail ArgumentError.new('server_public_key is mandatory') unless server_public_key

      @private_key = OpenSSL::PKey::RSA.new(private_key)
      @server_public_key = OpenSSL::PKey::RSA.new(server_public_key)
    end

    def create(verb, path, headers, body)
      signature = private_key.sign(
        digest,
        signable_input(verb, path, headers.select { |header_name, _| signable_header?(header_name) }, body)
      )

      Base64.strict_encode64(signature)
    end

    def verify!(response)
      sorted_bunq_headers = response.raw_headers.select(&method(:verifiable_header?)).sort.to_h.map { |k, v| "#{k.to_s.split('-').map(&:capitalize).join('-')}: #{v.first}" }
      data = %Q{#{response.code}\n#{sorted_bunq_headers.join("\n")}\n\n#{response.body}}

      signature_headers = response.raw_headers.find { |k, _| k.to_s.downcase == BUNQ_SERVER_SIGNATURE_RESPONSE_HEADER }
      fail AbsentResponseSignature.new(code: response.code, headers: response.raw_headers, body: response.body) unless signature_headers

      signature_headers_value = signature_headers[1]
      fail AbsentResponseSignature.new(code: response.code, headers: response.raw_headers, body: response.body) unless signature_headers_value

      signature = Base64.strict_decode64(signature_headers_value.first)
      fail UnexpectedResponse.new(code: response.code, headers: response.raw_headers, body: response.body) unless server_public_key.verify(digest, signature, data)
    end

    private

    attr_reader :private_key, :server_public_key

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def signable_input(verb, path, headers, body)
      sortable_headers = Hash[headers.collect{ |k,v| [k.to_s, v] }]
      head = [
        [verb, path].join(' '),
        sortable_headers.sort.to_h.map { |k,v| "#{k}: #{v}" }.join("\n")
      ].join("\n")
      "#{head}\n\n#{body}"
    end

    def signable_header?(header_name)
      _header_name = header_name.to_s.downcase
      SIGNABLE_HEADERS.include?(_header_name) || _header_name.start_with?(BUNQ_HEADER_PREFIX)
    end

    def verifiable_header?(header_name, _)
      _header_name = header_name.to_s.downcase
      _header_name.start_with?(BUNQ_HEADER_PREFIX) && _header_name != BUNQ_SERVER_SIGNATURE_RESPONSE_HEADER
    end
  end
end
