# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Encryptor do
  let(:body) { '{"amount": 10}' }

  subject { Bunq.client.encryptor }

  describe '#encrypt' do
    let(:server_private_key) { OpenSSL::PKey::RSA.new(IO.read('spec/bunq/fixtures/server-test-private.pem')) }

    let(:encryption_data) { subject.encrypt(body) }
    let(:encrypted_body) { encryption_data.first }
    let(:encryption_headers) { encryption_data.last }

    let(:iv) { Base64.strict_decode64(encryption_headers[described_class::HEADER_CLIENT_ENCRYPTION_IV]) }
    let(:encrypted_key) { Base64.strict_decode64(encryption_headers[described_class::HEADER_CLIENT_ENCRYPTION_KEY]) }
    let(:hmac) { Base64.strict_decode64(encryption_headers[described_class::HEADER_CLIENT_ENCRYPTION_HMAC]) }

    let(:key) { server_private_key.private_decrypt(encrypted_key) }

    it 'allows decryption using the server private key' do
      cipher = OpenSSL::Cipher.new(described_class::AES_ENCRYPTION_METHOD)
      cipher.decrypt

      cipher.iv = iv
      cipher.key = key

      decrypted_body = cipher.update(encrypted_body) + cipher.final

      expect(decrypted_body).to eq(body)
    end

    it 'returns a valid HMAC' do
      test_hmac = OpenSSL::HMAC.new(key, OpenSSL::Digest.new(described_class::HMAC_ALGORITHM))
      test_hmac << iv
      test_hmac << encrypted_body

      expect(test_hmac.digest).to eq(hmac)
    end
  end
end
