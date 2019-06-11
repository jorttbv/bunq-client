require 'spec_helper'
require 'rspec/json_expectations'

describe Bunq do
  describe '.client' do
    it 'dups the configuration' do
      expect(Bunq.client.configuration).to_not equal(Bunq.configuration)
    end
  end
end
