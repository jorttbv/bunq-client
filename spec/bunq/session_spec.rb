require 'spec_helper'

describe 'Bunq sessions' do
  let(:client) { Bunq.client }
  let(:another_client) { Bunq.client }

  before do
    stub_request(:get, "#{client.configuration.base_url}/v1/user/42")
      .to_return(body: IO.read('spec/bunq/fixtures/user.get.json'))
  end

  context 'given the default session cache' do
    let(:session_cache) { client.configuration.session_cache }

    before do
      stub_request(:post, "#{client.configuration.base_url}/v1/session-server")
        .to_return(body: IO.read('spec/bunq/fixtures/session_server.post.json'))
    end

    it 'creates a new session per client instance' do
      stub_request(:post, "#{client.configuration.base_url}/v1/session-server")
        .to_return(body: '{"Response": [{}, {"Token": {"token": "first"}}, {"UserCompany": {"id": 42}}]}')
      client.me_as_user.show
      first_session = client.current_session
      expect(first_session).to_not be_nil

      stub_request(:post, "#{client.configuration.base_url}/v1/session-server")
        .to_return(body: '{"Response": [{}, {"Token": {"token": "second"}}, {"UserCompany": {"id": 42}}]}')
      another_client.me_as_user.show
      second_session = another_client.current_session
      expect(second_session).to_not be_nil

      expect(first_session).to_not eq(second_session)
    end
  end

  context 'given a configured session cache' do
    let(:session_cache) { Bunq::ThreadSafeSessionCache.new }

    before do
      Bunq.configure do |config|
        config.session_cache = session_cache
      end
    end

    before do
      stub_request(:post, "#{client.configuration.base_url}/v1/session-server")
        .to_return(body: IO.read('spec/bunq/fixtures/session_server.post.json'))
    end

    it 'shares the session from the cache between client instances' do
      client.me_as_user.show
      first_session = session_cache.get
      expect(first_session).to_not be_nil

      another_client.me_as_user.show
      second_session = session_cache.get
      expect(second_session).to_not be_nil

      expect(first_session).to eq(second_session)
    end

    context 'and a session timeout' do
      before do
        stub_request(:get, "#{client.configuration.base_url}/v1/user/42")
          .to_return(status: 401, body: IO.read('spec/bunq/fixtures/session-timeout.json'))
      end

      it 'clears the session from the cache' do
        expect { client.me_as_user.show }.to raise_error(Bunq::UnauthorisedResponse)
        expect(session_cache.get).to be_nil
      end

      context 'and another client performs a call' do
        it 'succeeds' do
          expect { client.me_as_user.show }.to raise_error(Bunq::UnauthorisedResponse)

          stub_request(:get, "#{client.configuration.base_url}/v1/user/42")
            .to_return(body: IO.read('spec/bunq/fixtures/user.get.json'))

          another_client.me_as_user.show
        end
      end
    end
  end
end
