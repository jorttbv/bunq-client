# frozen_string_literal: true

require 'spec_helper'
require 'rspec/json_expectations'
require_relative '../../lib/bunq/errors'

describe Bunq::Resource do
  let(:client) { Bunq.client }
  let(:url) { client.configuration.base_url.to_s }

  let(:resource) { Bunq::Resource.new(client, '/resource') }

  context 'timeouts' do
    it 'has a default timeout of 60 seconds' do
      expect(client.configuration.timeout).to eq 60
    end

    it 'handles timeouts for get' do
      stub_request(:get, "#{url}/resource").to_timeout

      expect do
        resource.get
      end.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end

    it 'handles timeouts for put' do
      stub_request(:put, "#{url}/resource").to_timeout

      expect do
        resource.put({})
      end.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
    end

    it 'handles timeouts for post' do
      stub_request(:post, "#{url}/resource").to_timeout

      expect do
        resource.post({})
      end.to(raise_error(Bunq::Timeout)) { |e| expect(e.cause).to be_a_kind_of RestClient::Exceptions::Timeout }
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
        .to_return({status: 409})

      expect { resource.get({}) }.to raise_error(Bunq::TooManyRequestsResponse)
    end
  end

  context 'too many requests production response' do
    it 'fails' do
      stub_request(:get, "#{url}/resource")
        .to_return({status: 429})

      expect { resource.get({}) }.to raise_error(Bunq::TooManyRequestsResponse)
    end
  end

  describe 'given a response with status code 401 Unauthorized' do
    it 'raises a Bunq::UnauthorisedResponse' do
      stub_request(:get, "#{url}/resource")
        .to_return({status: 401})

      expect { resource.get({}) }.to raise_error(Bunq::UnauthorisedResponse)
    end
  end

  describe 'given a response with status code 403 Forbidden' do
    it 'raises a Bunq::UnauthorisedResponse' do
      stub_request(:get, "#{url}/resource")
        .to_return({status: 403})

      expect { resource.get({}) }.to raise_error(Bunq::UnauthorisedResponse)
    end
  end

  describe 'given a maintenance response' do
    let(:maintenance_html) do
      <<~HTML
        <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
        <html><head>
        <title>503 Service Unavailable</title>
        </head><body>
        <h1>Service Unavailable</h1>
        <p>The server is temporarily unable to service your
        request due to maintenance downtime or capacity
        problems. Please try again later.</p>
        </body></html>
      HTML
    end

    context 'and status code 491' do
      it 'raises a Bunq::MaintenanceResponse' do
        stub_request(:get, "#{url}/resource")
          .to_return(status: 491, body: maintenance_html)

        expect { resource.get({}) }.to raise_error(Bunq::MaintenanceResponse)
      end
    end

    context 'and status code 503' do
      it 'raises a Bunq::MaintenanceResponse' do
        stub_request(:get, "#{url}/resource")
          .to_return(status: 503, body: maintenance_html)

        expect { resource.get({}) }.to raise_error(Bunq::MaintenanceResponse)
      end
    end
  end

  describe 'given a bad gateway response' do
    let(:bad_gateway_html) do
      <<~HTML
        <html>
        <head><title>502 Bad Gateway</title></head>
        <body bgcolor="white">
        <center><h1>502 Bad Gateway</h1></center>
        </body>
        </html>
      HTML
    end

    before do
      Bunq.configure do |c|
        c.disable_response_signature_verification = false
      end
    end

    it 'raises a Bunq::UnexpectedResponse' do
      stub_request(:get, "#{url}/resource")
        .to_return(status: 502, body: bad_gateway_html)

      expect { resource.get({}) }.to raise_error(Bunq::UnexpectedResponse)
    end
  end
end
