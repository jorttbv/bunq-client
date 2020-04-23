# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Avatar do
  let(:client) { Bunq.client }
  let(:avatar_url) { "#{client.configuration.base_url}/v1/avatar/#{avatar_id}" }

  describe '#show', :requires_session do
    let(:avatar_id) { '2c7935a6-1e58-4daf-8cdb-41874e9f1a71' }
    let(:avatar) { client.avatar(avatar_id) }

    before do
      stub_request(:get, avatar_url)
        .to_return({
          status: status_code,
          body: response,
        },
                  )
    end

    context 'given a known id' do
      let(:status_code) { 200 }
      let(:response) { IO.read('spec/bunq/fixtures/avatar.get.json') }

      it 'returns a specific avatar' do
        expect(avatar.show)
          .to include_json [{"Avatar": {"uuid": '2c7935a6-1e58-4daf-8cdb-41874e9f1a71'}}]
      end
    end

    context 'given an unknown id' do
      let(:status_code) { 404 }
      let(:response) { IO.read('spec/bunq/fixtures/not-found.json') }

      it 'raises a ResourceNotFound error' do
        expect { avatar.show }
          .to raise_error(Bunq::ResourceNotFound)
      end
    end
  end
end
