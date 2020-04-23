# frozen_string_literal: true

require 'spec_helper'

describe Bunq::BunqmeTab do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }
  let(:account_id) { '2' }
  let(:monetary_account) { user.monetary_account(account_id) }
  let(:account_url) { "#{user_url}/monetary-account/#{account_id}" }
  let(:bunqme_tab_id) { '10' }
  let(:bunqme_tab) { monetary_account.bunqme_tab(bunqme_tab_id) }
  let(:bunqme_tab_url) { "#{account_url}/bunqme-tab/#{bunqme_tab_id}" }

  describe '#show', :requires_session do
    before do
      stub_request(:get, bunqme_tab_url)
        .to_return(
          {
            status: status_code,
            body: response,
          },
        )
    end

    context 'given a known id' do
      let(:status_code) { 200 }
      let(:response) { IO.read('spec/bunq/fixtures/bunqme_tab.get.json') }

      it 'returns a specific bunqme tab' do
        expect(bunqme_tab.show)
          .to include_json [{"BunqMeTab": {"id": 10}}]
      end
    end

    context 'given an unknown id' do
      let(:status_code) { 404 }
      let(:response) { IO.read('spec/bunq/fixtures/not-found.json') }

      it 'raises a ResourceNotFound error' do
        expect { bunqme_tab.show }
          .to raise_error(Bunq::ResourceNotFound)
      end
    end
  end

  describe '#update', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/bunqme_tab.put.json') }
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

    before do
      stub_request(:put, bunqme_tab_url)
        .with(body: attributes)
        .to_return(
          {
            status: 200,
            body: response,
          },
        )
    end

    it 'updates and returns the bunqme tab id' do
      result = bunqme_tab.update(attributes)
      expect(result).to include_json [{"Id": {"id": 10}}]
    end
  end
end
