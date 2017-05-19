require 'spec_helper'

describe Bunq::MonetaryAccounts do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#index', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account.list.json') }

    it 'returns a list of monetary accounts' do
      client.configuration.user_agent = 'bunq ruby client 0.1.2'
      expect(SecureRandom).to receive(:uuid).twice.and_return('foo')


      stub_request(:get, "#{user_url}/monetary-account")
        .with(
          query: {count: 200},
          headers: {
            'X-Bunq-Client-Request-Id' => 'foo',
            'X-Bunq-Client-Signature' => 'aUdpwr1KGKWWKJOC2Zk34Ehg0JGwWx0zf1OOZyFo+ZncnsX7UWzWXyvMKUxar6cEzwK7hSRVrsXPR8E/pZKL/4KGyW4c32drIeBOFBq8tFWGLgYgSpsRpjuWDny1SiFCI08jM5Mj3puLGAiJ2nI46aLLpKASOIqhO5n++Yb4eJPbm/h3fqLn3YfTw7AlEswO0K0SFu5xvqkk40VLlhjaU6i85gRcQCqxr2bcOgyDI0xhjHR8elWrIJBaMax5d5AX17Rvcq3ejrDBw4ZPUaTe27ifRbWqq/bP6f+H6TAqcegHFVO1JOmLiMsZdBfEjlSiV2IUYZLHsmR/lNejxyO82Q=='
          }
        )
        .to_return({
          body: response
        })

      result = user.monetary_accounts.index
      expect(result.to_a).to include_json ([{"MonetaryAccountBank": {"id": 42}}])
    end
  end
end
