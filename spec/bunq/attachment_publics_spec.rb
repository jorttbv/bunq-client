# frozen_string_literal: true

require 'spec_helper'

describe Bunq::AttachmentPublics, :requires_session do
  let(:client) { Bunq.client }
  let(:attachment_url) { "#{client.configuration.base_url}/v1/attachment-public" }

  describe '#create' do
    let(:payload) { IO.read('spec/bunq/fixtures/attachment_public.png') }
    let(:response) { IO.read('spec/bunq/fixtures/attachment_publics.post.json') }
    let(:description) { 'Just test attachment' }
    let(:mime_type) { 'image/png' }
    subject { client.attachment_publics.create(payload, description, mime_type) }

    before do
      stub_request(:post, attachment_url)
        .with(body: Base64.decode64(payload))
        .to_return(body: response)
    end

    it 'creates an attachment public' do
      is_expected.to include_json([{"Id": {"id": '2c7935a6-1e58-4daf-8cdb-41874e9f1a71'}}])
    end
  end
end
