# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Signature do
  context do
    let(:body) { '{"amount": 10}' }

    subject { Bunq.client.signature.create(body) }

    let(:expected_signature) do
      'qB/d2z/78SxyOXDOLHVgoalmcINnDggiGlMLyh5Kf/pDkG9Qs2JCSk/QjOwGQ/h4b0K6MWA4OLVrmzIUbbF++/sYNs+sEK4PVOUATKMOjShWn' \
      'Z4NHUU9HqoS3ruAdV6XU5LFjvpqsUQ/egXAGzFlUgPaq4g2t8P8hQHKH9C2SJjCOLAt07VleaiQRlPdyyEmmNMfxbp4bFe3EP62ILFz4t/4ox' \
      'ZRDchXWAAAUT6DnIiXuimBNRebi0Nsk32IIdieDeOcjrppIx2BIN0jNLULzLbiE9hsV9XwjNMYU6+SCQDQMLweRXgggB8wPJBK9sApdSdhkmS' \
      'ZeNE1sOdRG12F+g=='
    end

    it 'can be created from an HTTP request' do
      expect(subject).to eq(expected_signature)
    end

    context 'given a different HTTP body' do
      let(:body) { '{"amount": 50}' }

      it 'creates a different signature' do
        expect(subject).to_not be_nil
        expect(subject).to_not eq(expected_signature)
      end
    end

    context 'given a different private key' do
      before do
        Bunq.configure do |config|
          config.private_key = OpenSSL::PKey::RSA.new(2048).to_pem
        end
      end

      it 'creates a different signature' do
        expect(subject).to_not be_nil
        expect(subject).to_not eq(expected_signature)
      end
    end
  end

  describe 'response verification' do
    let(:server_private_key) { OpenSSL::PKey::RSA.new(IO.read('spec/bunq/fixtures/server-test-private.pem')) }
    let(:server_signature) do
      Base64.strict_encode64(
        server_private_key.sign(OpenSSL::Digest::SHA256.new, signable_response),
      )
    end

    let(:headers) do
      {
        'X-Bunq-Server-Signature': [server_signature],
        'X-Bunq-Client-Request-Id': ['57061b04b67ef'],
        'X-Bunq-Server-Response-Id': ['89dcaa5c-fa55-4068-9822-3f87985d2268'],
      }
    end
    let(:code) { 200 }
    let(:body) { '{"Response":[{"Id":{"id":1561}}]}' }

    let(:response) do
      double(
        raw_headers: headers,
        code: code,
        body: body,
      )
    end
    subject { Bunq.client.signature.verify!(response) }

    context 'given the response code, headers & body are signed' do
      let(:signable_response) do
        "200\n" \
        "X-Bunq-Client-Request-Id: 57061b04b67ef\n" \
        "X-Bunq-Server-Response-Id: 89dcaa5c-fa55-4068-9822-3f87985d2268\n" \
        "\n" \
        '{"Response":[{"Id":{"id":1561}}]}'
      end

      it 'verifies that response successfully' do
        expect { subject }.to_not raise_error
      end

      context 'and a tampered response' do
        let(:code) { 404 }

        it 'fails' do
          expect { subject }.to raise_error(Bunq::InvalidResponseSignature)
        end
      end

      context 'and an absent server signature' do
        let(:headers) { {} }

        it 'fails' do
          expect { subject }.to raise_error(Bunq::AbsentResponseSignature)
        end
      end

      context 'and a server signature that is nil' do
        let(:headers) { {'X-Bunq-Server-Signature': nil} }

        it 'fails' do
          expect { subject }.to raise_error(Bunq::AbsentResponseSignature)
        end
      end
    end

    context 'given only the response body is signed' do
      let(:signable_response) do
        '{"Response":[{"Id":{"id":1561}}]}'
      end

      it 'verifies that response successfully' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
