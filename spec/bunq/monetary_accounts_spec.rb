require 'spec_helper'

describe Bunq::MonetaryAccounts do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#index', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/monetary_account.list.json') }

    it 'returns a list of monetary accounts' do
      expect(SecureRandom).to receive(:uuid).twice.and_return('foo')

      stub_request(:get, "#{user_url}/monetary-account")
        .with(
          query: {count: 200},
          headers: {
            'X-Bunq-Client-Request-Id' => 'foo',
            'X-Bunq-Client-Signature' => 'U514vpiHyKW3Oifl65v6E+nljE42VJse+WzRhMHiklhVM0kch20DX96yfOQiX43+0bTJnLBpSxcUbfplt1/LupSQcq7ic8BEYlUdv4gnh7M7BeS7HuL2MdfK8JzKefFc9MxXBZjUdZcHjiMh20MUSJoFwSbypc9cpND7aRIl26VhJVpFY0QvEGlOGFVtjfeHDTN6XIlNoWyDknfPw1Cc+2+KuFsT5hbq9I3eSMJuiIlzUbMWRt45h/EvkXQnnI9C7IQ4PPSvctHj/8BzdHqovtXH6KbqXxZrZYQSWZg84gqK2LQeRLEPtQED96ozMsybW/IxU0viVT3kgmqCNAd1ag=='
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
