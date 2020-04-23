# frozen_string_literal: true
require 'spec_helper'

describe Bunq::DeviceServers do
  let(:client) { Bunq.client }
  let(:device_servers) { client.device_servers }

  let(:bunq_uri) { "#{client.configuration.base_url}#{resource_url}" }
  let(:resource_url) { '/v1/device-server' }

  describe '#create' do
    let(:api_key) { Bunq.client.configuration.api_key }
    let(:description) { 'rspec server' }
    let(:permitted_ips) { ['1.2.3.4', '*'] }

    it 'fails when no description is passed' do
      expect { device_servers.create(nil) }.to raise_error ArgumentError
    end

    context 'with valid input' do
      let(:response) do
        {
          "Response": [{
            "Id": {
              "id": 30,
            },
          },
],
        }
      end
      it 'returns the id of the created device server' do
        stub_request(:post, bunq_uri)
          .with(
            body: {description: description, secret: api_key, permitted_ips: permitted_ips},
          )
          .to_return({
            body: JSON.dump(response),
          },
                    )

        result = device_servers.create(description, permitted_ips: permitted_ips)
        expect(result).to include_json([{
          "Id": {
            "id": 30,
          },
        },
],
                                      )
      end
    end
  end

  describe '#index' do
    let(:response) do
      {
        "Response": [
          {
            "DeviceServer": {
              "id": 42,
              "created": '2015-06-13 23:19:16.215235',
              "updated": '2015-06-30 09:12:31.981573',
              "description": 'Mainframe23 in Amsterdam',
              "ip": '255.255.255.255',
              "status": 'ACTIVE',
            },
          },
        ],
      }
    end

    it 'lists the device servers' do
      stub_request(:get, bunq_uri)
        .to_return({
          body: JSON.dump(response),
        },
                  )

      result = device_servers.index
      expect(result).to include_json(
        [
          {
            "DeviceServer": {
              "id": 42,
              "created": '2015-06-13 23:19:16.215235',
              "updated": '2015-06-30 09:12:31.981573',
              "description": 'Mainframe23 in Amsterdam',
              "ip": '255.255.255.255',
              "status": 'ACTIVE',
            },
          },
        ],
      )
    end
  end
end
