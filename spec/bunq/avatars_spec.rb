require 'spec_helper'

describe Bunq::Avatars, :requires_session do
  let(:client) { Bunq.client }
  let(:avatar_url) { "#{client.configuration.base_url}/v1/avatar" }

  describe '#create' do
    let(:attachment_public_uuid) { 'f7dd168a-e487-49b5-98ce-bc78171bc291' }
    let(:payload) { { attachment_public_uuid: attachment_public_uuid } }
    let(:response) { IO.read('spec/bunq/fixtures/avatars.post.json') }
    subject { client.avatars.create(attachment_public_uuid) }

    before do
      stub_request(:post, avatar_url)
        .with(body: payload)
        .to_return(body: response)
    end

    it 'creates an avatar' do
      is_expected
        .to include_json([{"Uuid": {"uuid": '2c7935a6-1e58-4daf-8cdb-41874e9f1a71'}}])
    end
  end
end
