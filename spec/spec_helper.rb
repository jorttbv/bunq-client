# frozen_string_literal: true
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bunq/bunq'
require 'webmock/rspec'
require 'rspec/json_expectations'

module RequiresSessionExampleGroup
  def self.included(base)
    base.let!(:session_stub) do
      stub_request(:post, "#{client.configuration.base_url}/v1/session-server")
        .with({
          body: JSON.dump({secret: client.configuration.api_key}),
        },
             )
        .to_return(
          body: session_response,
        )
    end
    base.let(:session_response) { IO.read('spec/bunq/fixtures/session_server.post.json') }
  end
end

RSpec.configure do |config|
  config.include RequiresSessionExampleGroup, :requires_session

  config.before do
    Bunq.reset_configuration

    Bunq.configure do |c|
      c.disable_response_signature_verification = true
      c.installation_token = 'foo'
      c.api_key = 'apikey'
      c.server_public_key = IO.read('spec/bunq/fixtures/server-test-public.pem')
      c.private_key = IO.read('spec/bunq/fixtures/test-private.pem')
    end
  end

  config.after :each, :requires_session do
    expect(session_stub).to have_been_requested
  end
end
