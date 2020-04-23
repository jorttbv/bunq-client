# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Payment, :requires_session do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#show' do
    let(:response) { IO.read('spec/bunq/fixtures/payment.get.json') }
    let(:payment_id) { 10 }

    it 'returns a specific payment' do
      stub_request(:get, "#{user_url}/monetary-account/2/payment/#{payment_id}")
        .to_return({
          body: response,
        },
                  )

      result = user.monetary_account(2).payment(payment_id).show
      expect(result).to include_json [{"Payment": {"id": 42}}]
    end
  end
end
