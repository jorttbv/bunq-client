require 'spec_helper'
require 'rspec/json_expectations'

describe Bunq::Client do
  describe '.client' do
    context 'given default configuration' do
      it 'creates a new instance' do
        expect(Bunq.client).to_not equal(Bunq.client)
      end
    end

    context 'given configuration with cache_client = true' do
      before { Bunq.configure { |config| config.cache_client = true } }

      it 'returns the cached client' do
        expect(Bunq.client).to equal(Bunq.client)
      end
    end
  end
end
