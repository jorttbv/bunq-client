# frozen_string_literal: true

require 'spec_helper'

describe Bunq::AttachmentPublic do
  let(:client) { Bunq.client }
  let(:attachment_url) { "#{client.configuration.base_url}/v1/attachment-public/#{attachment_id}" }

  describe '#show', :requires_session do
    let(:attachment_id) { 'b07faaa7-003a-4cdf-a2c1-434e71d42fca' }
    let(:attachment_public) { client.attachment_public(attachment_id) }

    before do
      stub_request(:get, attachment_url)
        .to_return(
          status: status_code,
          body: response,
        )
    end

    context 'given a known id' do
      let(:status_code) { 200 }
      let(:response) { IO.read('spec/bunq/fixtures/attachment_public.get.json') }

      it 'returns a specific public attachment' do
        expect(attachment_public.show)
          .to include_json [{"AttachmentPublic": {"uuid": attachment_id}}]
      end
    end

    context 'given an unknown id' do
      let(:status_code) { 404 }
      let(:response) { IO.read('spec/bunq/fixtures/not-found.json') }

      it 'raises a ResourceNotFound error' do
        expect { attachment_public.show }
          .to raise_error(Bunq::ResourceNotFound)
      end
    end
  end
end
