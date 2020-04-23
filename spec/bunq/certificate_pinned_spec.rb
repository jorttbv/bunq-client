# frozen_string_literal: true
require 'spec_helper'

describe Bunq::CertificatePinned do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#create', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/certificate_pinned.post.json') }

    it 'pins a certificate' do
      stub_request(:post, "#{user_url}/certificate-pinned")
        .with({
          body: {
            certificate_chain: [
              {certificate: 'MY CERTIFICATE'},
            ],
          },
        },
             )
        .to_return({
          body: response,
        },
                  )

      result = user.certificate_pinned.create('MY CERTIFICATE')
      expect(result).to include_json ({"Response": [{"Id": {"id": 82}}]})
    end
  end
end
