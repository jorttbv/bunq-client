require 'spec_helper'
require 'rspec/json_expectations'

describe Bunq::Client do
  let(:client) { Bunq.client }

  describe '#with_local_config' do
    it 'yields with a copy of the global config' do
      expect { |block| client.with_local_config(&block) }.to yield_with_args(Bunq::Configuration)
    end

    it 'does not alter the global configuration' do
      expect { client.with_local_config { |config| config.timeout = 30 } }
        .to_not change { client.configuration.timeout }
    end

    it 'returns what the block returns' do
      expect(client.with_local_config { 'return value' }).to eq('return value')
    end
  end
end
