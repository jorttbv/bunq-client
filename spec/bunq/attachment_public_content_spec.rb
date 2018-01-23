require 'spec_helper'

describe Bunq::AttachmentPublicContent, :requires_session do
  let(:client) { Bunq.client }

  describe '#show' do
    let(:response) { IO.read('spec/bunq/fixtures/attachment_public.png') }
    subject { client.attachment_public_content(15).show }

    it 'returns the attachment public content in PNG format' do
      stub_request(:get, "#{client.configuration.base_url}/v1/attachment-public/15/content")
        .to_return(body: response)

      expect(subject).to eq(response)
    end
  end
end
