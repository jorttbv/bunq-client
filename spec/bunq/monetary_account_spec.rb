require 'spec_helper'

describe Bunq::MonetaryAccount do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#show', :requires_session do
    let(:account_id) { 10 }

    before do
      stub_request(:get, "#{user_url}/monetary-account/#{account_id}")
        .to_return({
          status: status_code,
          body: response,
        },
                  )
    end

    context 'given a known id' do
      let(:status_code) { 200 }
      let(:response) { IO.read('spec/bunq/fixtures/monetary_account.get.json') }

      it 'returns a specific monetary account' do
        expect(user.monetary_account(account_id).show)
          .to include_json [{"MonetaryAccountBank": {"id": 42}}]
      end
    end

    context 'given an unknown id' do
      let(:status_code) { 404 }
      let(:response) { IO.read('spec/bunq/fixtures/not-found.json') }

      it 'raises a ResourceNotFound error' do
        expect { user.monetary_account(account_id).show }
          .to raise_error(Bunq::ResourceNotFound)
      end
    end
  end
end
