# frozen_string_literal: true
require 'spec_helper'

describe Bunq::QrCodeContent, :requires_session do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#show' do
    let(:response) { IO.read('spec/bunq/fixtures/qrcode.png') }
    subject { user.draft_share_invite_bank(15).qr_code_content.show }

    it 'returns the QR code of the draft share invite in PNG format' do
      stub_request(:get, "#{user_url}/draft-share-invite-bank/15/qr-code-content")
        .to_return(body: response)

      expect(subject).to eq(response)
    end
  end
end
