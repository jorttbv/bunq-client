require 'spec_helper'

describe Bunq::Payments, :requires_session do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#index' do
    subject { user.monetary_account(2).payments.index(count: 1) }

    context 'given a single payment' do
      let(:response) { IO.read('spec/bunq/fixtures/payments.list.json') }

      it 'returns a list of payments' do
        stub_request(:get, "#{user_url}/monetary-account/2/payment")
          .with(query: {count: 1})
          .to_return(body: response)

        expect(subject.to_a).to include_json([Payment: {id: 42}])
      end
    end

    context 'given multiple pages of payments' do
      let(:page_1_response) { IO.read('spec/bunq/fixtures/payments-page-1.list.json') }
      let(:page_2_response) { IO.read('spec/bunq/fixtures/payments-page-2.list.json') }

      it 'returns a list of all payments, starting with the most recent payment' do
        stub_request(:get, "#{user_url}/monetary-account/2/payment")
          .with(query: {count: 1})
          .to_return(body: page_1_response)

        stub_request(:get, "#{user_url}/monetary-account/2/payment")
          .with(query: {count: 1, older_id: 42})
          .to_return(body: page_2_response)

        expect(subject.to_a).to include_json([
          {
            "Payment": { "id": 42 },
          },
          {
            "Payment": { "id": 84 },
          },
        ])
      end
    end
  end

  describe '#show' do
    let(:response) { IO.read('spec/bunq/fixtures/payments.get.json') }
    let(:payment_id) { 10 }

    it 'returns a specific payment' do
      stub_request(:get, "#{user_url}/monetary-account/2/payment/#{payment_id}").
        to_return({
          body: response
        })

      result = user.monetary_account(2).payments.show(payment_id)
      expect(result).to include_json ([{"Payment": {"id": 42}}])
    end
  end
end
