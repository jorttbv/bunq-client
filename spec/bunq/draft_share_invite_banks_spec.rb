require 'spec_helper'

describe Bunq::DraftShareInviteBanks, :requires_session do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }

  describe '#create' do
    let(:invite) do
      {
        "status": 'PENDING',
        "expiration": Time.now.strftime('%Y-%m-%d %H:%M:%S.%L%3N'),
        "draft_share_settings": {
          "share_detail": {
            "ShareDetailReadOnly": {
              "view_balance": true,
              "view_old_events": true,
              "view_new_events": true,
            },
          },
        },
      }
    end
    let(:response) { IO.read('spec/bunq/fixtures/draft_share_invite_banks.post.json') }
    subject { user.draft_share_invite_banks.create(invite) }

    it 'creates a draft share invite for a monetary account with another Bunq user' do
      stub_request(:post, "#{user_url}/draft-share-invite-bank")
        .with(body: invite)
        .to_return(body: response)

      expect(subject).to include_json(JSON.parse(response)['Response'])
    end
  end

  describe '#index' do
    let(:response) { IO.read('spec/bunq/fixtures/draft_share_invite_banks.list.json') }
    subject { user.draft_share_invite_banks.index }

    it 'returns a list of all draft share invites' do
      stub_request(:get, "#{user_url}/draft-share-invite-bank")
        .to_return(body: response)

      expect(subject).to include_json(JSON.parse(response)['Response'])
    end
  end
end
