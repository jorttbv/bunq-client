# frozen_string_literal: true

require 'spec_helper'

describe Bunq::MonetaryAccountBank do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }
  let(:account_bank_id) { 42 }

  describe '#show', :requires_session do
    before do
      stub_request(:get, "#{user_url}/monetary-account-bank/#{account_bank_id}")
        .to_return(
          {
            status: status_code,
            body: response,
          },
        )
    end

    context 'given a known id' do
      let(:status_code) { 200 }
      let(:response) { IO.read('spec/bunq/fixtures/monetary_account_bank.get.json') }

      it 'returns a specific monetary account' do
        expect(user.monetary_account_bank(account_bank_id).show)
          .to include_json [{"MonetaryAccountBank": {"id": 42}}]
      end
    end

    context 'given an unknown id' do
      let(:status_code) { 404 }
      let(:response) { IO.read('spec/bunq/fixtures/not-found.json') }

      it 'raises a ResourceNotFound error' do
        expect { user.monetary_account_bank(account_bank_id).show }
          .to raise_error(Bunq::ResourceNotFound)
      end
    end
  end

  describe '#update', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account_bank.put.json') }
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

    before do
      stub_request(:put, "#{user_url}/monetary-account-bank/#{account_bank_id}")
        .with(body: attributes)
        .to_return(
          {
            status: 200,
            body: response,
          },
        )
    end

    it 'updates and returns the user monetary account bank id' do
      result = user.monetary_account_bank(account_bank_id).update(attributes)
      expect(result).to include_json [{"Id": {"id": 45}}]
    end
  end
end
