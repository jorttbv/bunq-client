require 'spec_helper'
require 'rspec/json_expectations'
require_relative '../../lib/bunq/errors'

describe Bunq::Resource do
  let(:client) { Bunq.client }
  let(:url) { "#{client.configuration.base_url}" }

  let(:resource) { Bunq::Resource.new(client, '/timeout') }

  context 'timeouts' do
    it 'has a default timeout of 60 seconds' do
      expect(client.configuration.timeout).to eq 60
    end

    it 'handles timeouts for get' do
      stub_request(:get, "#{url}/timeout").to_timeout

      expect { resource.get }.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end

    it 'handles timeouts for put' do
      stub_request(:put, "#{url}/timeout").to_timeout

      expect { resource.put({}) }.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end

    it 'handles timeouts for post' do
      stub_request(:post, "#{url}/timeout").to_timeout

      expect { resource.post({}) }.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end
  end
end
