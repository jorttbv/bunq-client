# frozen_string_literal: true

require 'spec_helper'

describe Bunq::MonetaryAccountBanks do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#index', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account_banks.list.json') }

    it 'returns a list of monetary account banks' do
      stub_request(:get, "#{user_url}/monetary-account-bank")
        .with(query: {count: 200})
        .to_return({body: response})

      result = user.monetary_account_banks.index
      expect(result.to_a).to include_json [{"MonetaryAccountBank": {"id": 42}}]
    end
  end

  describe '#create', :requires_session do
    let(:attributes) do
      {
        "currency": 'string',
        "description": 'string',
        "daily_limit": {
          "value": 'string',
          "currency": 'string',
        },
        "avatar_uuid": 'string',
        "status": 'string',
        "sub_status": 'string',
        "reason": 'string',
        "reason_description": 'string',
        "display_name": 'string',
        "setting": {
          "color": 'string',
          "icon": 'string',
          "default_avatar_status": 'string',
          "restriction_chat": 'string',
        },
      }
    end
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account_banks.post.json') }
    subject { user.monetary_account_banks.create(attributes) }

    it 'creates a monetary account bank' do
      stub_request(:post, "#{user_url}/monetary-account-bank")
        .with(body: attributes)
        .to_return(body: response)

      is_expected.to include_json [{"Id": {"id": 9}}]
    end
  end
end
