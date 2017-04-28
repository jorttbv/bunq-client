require 'spec_helper'

describe Bunq::User do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#show', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/user.get.json') }

    it 'returns a specific monetary account' do
      stub_request(:get, user_url).
        to_return({
          body: response
        })

      result = user.show
      expect(result).to include_json ([{"UserCompany": {"id": 42}}])
    end
  end
end
