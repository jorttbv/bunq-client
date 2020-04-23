# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Installation, :requires_session do
  let(:client) { Bunq.client }
  let(:installation) { client.installation(12) }
  let(:installation_url) { "#{client.configuration.base_url}/v1/installation/12" }

  describe '#show' do
    let(:response) { IO.read('spec/bunq/fixtures/installation.get.json') }
    subject { installation.show }

    it 'returns the installation id for the current session' do
      stub_request(:get, installation_url)
        .to_return(body: response)

      expect(subject).to include_json (JSON.parse(response)['Response'])
    end
  end
end
