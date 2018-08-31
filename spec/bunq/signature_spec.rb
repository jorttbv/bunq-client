require 'spec_helper'

describe Bunq::Signature do
  context do
    let(:verb) { 'GET' }
    let(:path) { '/' }
    let(:signable_headers) do
      {
        'Cache-Control': 'no-cache',
        'User-Agent': 'bunq-TestServer/1.00 sandbox/0.17b3',
        'X-Bunq-Client-Authentication': 'f15f1bbe1feba25efb00802fa127042b54101c8ec0a524c36464f5bb143d3b8b',
        'X-Bunq-Client-Request-Id': '57061b04b67ef',
        'X-Bunq-Geolocation': '0 0 0 0 NL',
        'X-Bunq-Language': 'en_US',
        'X-Bunq-Region': 'en_US',
      }
    end
    let(:headers) { signable_headers }
    let(:body) { '{"amount": 10}' }

    subject { Bunq.client.signature.create(verb, path, headers, body) }

    let(:expected_signature) do
      'o5AXc4Ag72GzfzXwDbvlEck3SnrEILHVjmc6wJhjZVGn+rtPmAilCKQiSvneo2VbjwuP2vHJdZEQk4NF/1PmrVByUjdmCF/' \
      'c9y5LP/w4+SgZMoyu6DfzDtoVRMMFM0tC4MPVaAZ8//vniQEaR7EK3RBL5Nh4dUnA3UVQ972SbTl+Huof5XknUlONOpzSU+' \
      'ms3VIj8FmogzfRmjnJoDUvfwxY+5mRhQDi9wD+nAXPUo2yT2OL1by/RkE5bfLlBbZXmUwXYMQ8IHAF7Rnow8aBY7FCjl8Ye' \
      'Sulw58bPOb9HJJM3lk0ZaPisN/S1HbwQ9LcRLX0SdSuKlvnu2U/uZv8AA=='
    end

    it 'can be created from an HTTP request' do
      expect(subject).to eq(expected_signature)
    end

    context 'given a header other than Cache-Control, User-Agent and X-Bunq-*' do
      let(:headers) { signable_headers.merge('Accept': '*/*', 'Content-Type': 'application/json') }

      it 'omits that header from the signature ' do
        expect(subject).to eq(expected_signature)
      end
    end

    context 'given a different HTTP verb' do
      let(:verb) { 'POST' }

      it 'creates a different signature' do
        expect(subject).to_not be_nil
        expect(subject).to_not eq(expected_signature)
      end
    end

    context 'given a different HTTP path' do
      let(:path) { '/installation' }

      it 'creates a different signature' do
        expect(subject).to_not be_nil
        expect(subject).to_not eq(expected_signature)
      end
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
    let(:signable_response) do
      "200\n" \
      "X-Bunq-Client-Request-Id: 57061b04b67ef\n" \
      "X-Bunq-Server-Response-Id: 89dcaa5c-fa55-4068-9822-3f87985d2268\n" \
      "\n" \
      "{\"Response\":[{\"Id\":{\"id\":1561}}]}"
    end
    let(:server_signature) do
      Base64.strict_encode64(
        server_private_key.sign(OpenSSL::Digest::SHA256.new, signable_response)
      )
    end

    let(:headers) do
      {
        :'X-Bunq-Server-Signature' => [server_signature],
        :'X-Bunq-Client-Request-Id' => ['57061b04b67ef'],
        :'X-Bunq-Server-Response-Id' => ['89dcaa5c-fa55-4068-9822-3f87985d2268'],
      }
    end
    let(:code) { 200 }
    let(:body) { '{"Response":[{"Id":{"id":1561}}]}' }

    let(:response) do
      double(
        raw_headers: headers,
        code: code,
        body: body
      )
    end
    subject { Bunq.client.signature.verify!(response) }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end

    context 'given a tampered response' do
      let(:code) { 404 }

      it 'fails' do
        expect { subject }.to raise_error(Bunq::UnexpectedResponse)
      end
    end

    context 'given an absent server signature' do
      let(:headers) { {} }

      it 'fails' do
        expect { subject }.to raise_error(Bunq::AbsentResponseSignature)
      end
    end

    context 'given a server signature that is nil' do
      let(:headers) { {:'X-Bunq-Server-Signature' => nil} }

      it 'fails' do
        expect { subject }.to raise_error(Bunq::AbsentResponseSignature)
      end
    end
  end
end
