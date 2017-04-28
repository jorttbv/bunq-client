require 'spec_helper'

describe Bunq::MonetaryAccount do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#show', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account.get.json') }
    let(:account_id) { 10 }

    it 'returns a specific monetary account' do
      stub_request(:get, "#{user_url}/monetary-account/#{account_id}").
        to_return({
          body: response
        })

      result = user.monetary_account(account_id).show
      expect(result).to include_json ([{"MonetaryAccountBank": {"id": 42}}])
    end
  end
end
