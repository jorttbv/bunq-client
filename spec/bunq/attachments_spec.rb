# frozen_string_literal: true

require 'spec_helper'

describe Bunq::AttachmentPublics, :requires_session do
  let(:client) { Bunq.client }

  describe '#create' do
    let(:payload) { IO.read('spec/bunq/fixtures/attachment_public.png') }
    let(:response) { IO.read('spec/bunq/fixtures/attachments.post.json') }
    let(:description) { 'Just test attachment' }
    let(:mime_type) { 'image/png' }
    let(:user_id) { '1' }
    let(:user) { client.user(user_id) }
    let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }
    let(:account_id) { '45' }
    let(:account_url) { "#{user_url}/monetary-account/#{account_id}" }
    let(:account) { user.monetary_account(account_id) }
    let(:attachment_id) { '4' }
    let(:attachment_url) { "#{account_url}/attachment" }

    subject { account.attachments.create(payload, description, mime_type) }

    before do
      stub_request(:post, attachment_url)
        .with(body: Base64.decode64(payload))
        .to_return(body: response)
    end

    it 'creates a monetary account attachment' do
      is_expected.to include_json([{"Id": {"id": '2c7935a6-1e58-4daf-8cdb-41874e9f1a72'}}])
    end
  end
end
