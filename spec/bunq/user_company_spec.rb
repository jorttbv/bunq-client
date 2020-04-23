require 'spec_helper'

describe Bunq::UserCompany, :requires_session do
  let(:client) { Bunq.client }
  let(:user_company) { client.user_company('42') }
  let(:user_company_url) { "#{client.configuration.base_url}/v1/user-company/42" }

  describe '#show' do
    let(:response) { IO.read('spec/bunq/fixtures/user_company.get.json') }

    it 'returns a specific user company' do
      stub_request(:get, user_company_url)
        .to_return({
          body: response,
        },
                  )

      result = user_company.show
      expect(session_stub).to have_been_requested
      expect(result).to include_json [{"UserCompany": {"id": 42}}]
    end
  end

  describe '#update' do
    let(:response) { IO.read('spec/bunq/fixtures/user_company.put.json') }
    let(:notification_filters) do
      [
        notification_delivery_method: 'URL',
        notification_target: 'https://my.company.com/callback-url',
        category: 'PAYMENT',
      ]
    end

    it 'returns the user company' do
      stub_request(:put, user_company_url)
        .with(body: {notification_filters: notification_filters})
        .to_return({
          body: response,
        },
                  )

      result = user_company.update({notification_filters: notification_filters})
      expect(result).to include_json [{"Id": {"id": 42}}]
    end
  end
end
