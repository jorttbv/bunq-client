# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Installations do
  let(:client) { Bunq.client }
  let(:installations) { client.installations }

  let(:bunq_uri) { "#{client.configuration.base_url}/v1/installation" }

  describe '#create' do
    let(:public_key) { IO.read('spec/bunq/fixtures/test-public.pem') }
    let(:response) { IO.read('spec/bunq/fixtures/installations.post.json') }

    it 'fails when no public key is passed' do
      expect { installations.create(nil) }.to raise_error ArgumentError, 'public_key is required'
    end

    it 'creates a new installation' do
      stub_request(:post, bunq_uri)
        .with(
          body: {client_public_key: public_key},
        )
        .to_return(
          status: 200,
          body: response,
        )

      result = installations.create(public_key)
      expect(result).to include_json(JSON.parse(response)['Response'])
    end
  end

  describe '#index' do
    let(:response) { IO.read('spec/bunq/fixtures/installations.list.json') }

    it 'returns the current installation' do
      stub_request(:get, bunq_uri)
        .to_return(
          status: 200,
          body: response,
        )

      result = installations.index
      expect(result).to include_json(JSON.parse(response)['Response'])
    end
  end
end
