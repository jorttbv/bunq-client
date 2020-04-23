# frozen_string_literal: true

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

        expect(subject.to_a).to include_json(
          [
            {
              "Payment": {"id": 42},
            },
            {
              "Payment": {"id": 84},
            },
          ],
        )
      end
    end

    context 'paginate forwards' do
      subject { user.monetary_account(2).payments.index(count: 1, newer_id: 180) }

      let(:page_1_response) { IO.read('spec/bunq/fixtures/pagination-page-1.list.json') }
      let(:page_2_response) { IO.read('spec/bunq/fixtures/pagination-page-2.list.json') }
      let(:page_3_response) { IO.read('spec/bunq/fixtures/pagination-page-3.list.json') }

      it 'returns a list of all payments, starting with the most recent payment' do
        stub_request(:get, "#{user_url}/monetary-account/2/payment")
          .with(query: {count: 1, newer_id: 180})
          .to_return(body: page_3_response)

        stub_request(:get, "#{user_url}/monetary-account/2/payment")
          .with(query: {count: 1, newer_id: 170})
          .to_return(body: page_2_response)

        stub_request(:get, "#{user_url}/monetary-account/2/payment")
          .with(query: {count: 1, newer_id: 120})
          .to_return(body: page_1_response)

        expect(subject.to_a).to include_json(
          [
            {
              "Payment": {"id": 170},
            },
            {
              "Payment": {"id": 120},
            },
            {
              "Payment": {"id": 42},
            },
          ],
        )
      end
    end
  end
end
