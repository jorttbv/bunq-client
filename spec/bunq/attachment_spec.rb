# frozen_string_literal: true

require 'spec_helper'

describe Bunq::Attachment do
  let(:client) { Bunq.client }

  describe '#show', :requires_session do
    context 'via user' do
      let(:user_id) { '1' }
      let(:user) { client.user(user_id) }
      let(:user_url) { "#{client.configuration.base_url}/v1/user/#{user_id}" }
      let(:attachment_id) { '4' }
      let(:attachment_url) { "#{user_url}/attachment/#{attachment_id}" }
      before do
        stub_request(:get, attachment_url)
          .to_return(
            {
              status: status_code,
              body: response,
            },
          )
      end

      context 'given a known id' do
        let(:status_code) { 200 }
        let(:response) { IO.read('spec/bunq/fixtures/user_attachment.get.json') }

        it 'returns a specific user attachment' do
          expect(user.attachment(attachment_id).show)
            .to include_json [{"Attachment": {"id": 4}}]
        end
      end

      context 'given an unknown id' do
        let(:status_code) { 404 }
        let(:response) { IO.read('spec/bunq/fixtures/not-found.json') }

        it 'raises a ResourceNotFound error' do
          expect { user.attachment(attachment_id).show }
            .to raise_error(Bunq::ResourceNotFound)
        end
      end
    end
  end
end
