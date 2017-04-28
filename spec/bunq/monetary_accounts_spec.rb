require 'spec_helper'

describe Bunq::MonetaryAccounts do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#index', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account.list.json') }

    it 'returns a list of monetary accounts' do
      stub_request(:get, "#{user_url}/monetary-account")
        .with(query: {count: 200})
        .to_return({
          body: response
        })

      result = user.monetary_accounts.index
      expect(result.to_a).to include_json ([{"MonetaryAccountBank": {"id": 42}}])
    end
  end
end
