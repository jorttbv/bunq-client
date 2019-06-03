require 'spec_helper'
require 'rspec/json_expectations'
require_relative '../../lib/bunq/errors'

describe Bunq::Resource do
  let(:client) { Bunq.client }
  let(:url) { "#{client.configuration.base_url}" }

  let(:resource) { Bunq::Resource.new(client, '/resource') }

  context 'timeouts' do
    it 'has a default timeout of 60 seconds' do
      expect(client.configuration.timeout).to eq 60
    end

    it 'handles timeouts for get' do
      stub_request(:get, "#{url}/resource").to_timeout

      expect { resource.get }.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end

    it 'handles timeouts for put' do
      stub_request(:put, "#{url}/resource").to_timeout

      expect { resource.put({}) }.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end

    it 'handles timeouts for post' do
      stub_request(:post, "#{url}/resource").to_timeout

      expect { resource.post({}) }.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end
  end

  context 'too many requests sandbox response' do
    before do
      Bunq.configure do |config|
        config.sandbox = true
      end
    end

    it 'fails' do
      stub_request(:get, "#{url}/resource")
        .to_return({ status: 409 })

      expect { resource.get({}) }.to raise_error(Bunq::TooManyRequestsResponse)
    end
  end

  context 'too many requests production response' do
    it 'fails' do
      stub_request(:get, "#{url}/resource")
        .to_return({ status: 429 })

      expect { resource.get({}) }.to raise_error(Bunq::TooManyRequestsResponse)
    end
  end

  describe 'given a response with status code 401 Unauthorized' do
    it 'raises a Bunq::UnauthorisedResponse' do
      stub_request(:get, "#{url}/resource")
        .to_return({ status: 401 })

      expect { resource.get({}) }.to raise_error(Bunq::UnauthorisedResponse)
    end
  end
end
