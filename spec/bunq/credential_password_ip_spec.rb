# frozen_string_literal: true

require 'spec_helper'

describe Bunq::CredentialPasswordIp do
  let(:client) { Bunq.client }
  let(:user_id) { '1' }
  let(:user) { client.user(user_id) }
  let(:url) { "#{client.configuration.base_url}/v1/user/#{user_id}/credential-password-ip" }

  describe '#list', :requires_session do
    let(:response) { IO.read('spec/bunq/fixtures/credentials_password_ip.list.json') }

    it 'returns all credential password ip for a user' do
      stub_request(:get, url)
        .to_return(body: response)

      result = user.credential_password_ip.list
      expect(result).to include_json [
        { "CredentialPasswordIp": { "id": 12121212 } }, { "CredentialPasswordIp": { "id": 21212121 } }
      ]
    end
  end

  describe '#ip', :requires_session do
    describe '#list' do
      let(:url) { "#{client.configuration.base_url}/v1/user/#{user_id}/credential-password-ip/12121212/ip" }
      let(:response) { IO.read('spec/bunq/fixtures/ip.list.json') }
      it 'lists all ips of a credential-password-ip' do
        stub_request(:get, url)
          .to_return(body: response)

        result = user.credential_password_ip.ip('12121212').list
        expect(result).to include_json [
          { "PermittedIp": { "id": 123 } }
        ]
      end
    end

    describe '#show' do
      let(:url) { "#{client.configuration.base_url}/v1/user/#{user_id}/credential-password-ip/12121212/ip/123" }
      let(:response) { IO.read('spec/bunq/fixtures/ip.get.json') }
      it 'gets a single ip of a credential-password-ip' do
        stub_request(:get, url)
          .to_return(body: response)

        result = user.credential_password_ip.ip('12121212').show('123')
        expect(result).to include_json [
          { "PermittedIp": { "id": 123 } }
        ]
      end
    end

    describe '#add_ip_address' do
      let(:url) { "#{client.configuration.base_url}/v1/user/#{user_id}/credential-password-ip/12121212/ip" }
      let(:response) { IO.read('spec/bunq/fixtures/ip.post.json') }

      it 'gets a single ip of a credential-password-ip' do
        stub_request(:post, url)
          .with(body: { ip: '111.111.222.111', status: 'ACTIVE' }.to_json)
          .to_return(body: response)

        result = user.credential_password_ip.ip('12121212').add_ip_address('111.111.222.111', 'ACTIVE')
        expect(result).to include_json [
          { "Id": { "id": 42 } }
        ]
      end
    end
  end
end
