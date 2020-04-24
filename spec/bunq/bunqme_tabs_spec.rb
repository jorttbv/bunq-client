# frozen_string_literal: true

require 'spec_helper'

describe Bunq::BunqmeTabs do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }
  let(:account_id) { '2' }
  let(:monetary_account) { user.monetary_account(account_id) }
  let(:account_url) { "#{user_url}/monetary-account/#{account_id}" }
  let(:bunqme_tab_url) { "#{account_url}/bunqme-tab" }

  describe '#index', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/bunqme_tabs.list.json') }

    it 'returns a list of bunqme tabs' do
      stub_request(:get, bunqme_tab_url)
        .with(query: {count: 200})
        .to_return({body: response})

      result = monetary_account.bunqme_tabs.index
      expect(result.to_a).to include_json [{"BunqMeTab": {"id": 100}}]
    end
  end

  describe '#create', :requires_session do
    let(:attributes) do
      {
        "bunqme_tab_entry": {
          "amount_inquired": {
            "value": 'string',
            "currency": 'string',
          },
          "description": 'string',
          "redirect_url": 'string',
          "alias": {
            "avatar": {
              "uuid": 'string',
            },
            "label_user": {
              "uuid": 'string',
              "display_name": 'string',
              "country": 'string',
              "avatar": {
                "uuid": 'string',
              },
            },
            "bunq_me": {
              "type": 'string',
              "value": 'string',
              "name": 'string',
            },
          },
        },
        "status": 'string',
      }
    end
    let(:response) { IO.read('spec/bunq/fixtures/bunqme_tabs.post.json') }
    subject { monetary_account.bunqme_tabs.create(attributes) }

    it 'creates a bunqme tab' do
      stub_request(:post, bunqme_tab_url)
        .with(body: attributes)
        .to_return(body: response)

      is_expected.to include_json [{"Id": {"id": 12}}]
    end
  end
end
