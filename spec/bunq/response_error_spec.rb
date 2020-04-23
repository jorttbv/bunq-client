# frozen_string_literal: true
require 'spec_helper'

describe Bunq::ResponseError do
  context 'with a JSON body' do
    let(:error) do
      json = '{"Error": "foo"}'
      Bunq::ResponseError.new(code: 400, headers: {'content-type' => ['application/json']}, body: json)
    end

    describe '#parsed_body' do
      it 'returns the parsed JSON' do
        parsed_body = error.parsed_body
        expect(parsed_body).to eq({'Error' => 'foo'})
      end
    end

    describe '#errors' do
      it 'returns the Error field from the JSON body' do
        errors = error.errors
        expect(errors).to eq('foo')
      end
    end

    describe '#message' do
      it 'returns a human readable message' do
        expect(error.message).to eq('Response error (code: 400, body: {"Error": "foo"})')
      end
    end
  end

  context 'without a JSON body' do
    let(:error) do
      Bunq::ResponseError.new(code: 400, headers: nil, body: '')
    end

    describe '#parsed_body' do
      it 'returns nil' do
        parsed_body = error.parsed_body
        expect(parsed_body).to eq(nil)
      end
    end

    describe '#errors' do
      it 'returns nil' do
        errors = error.errors
        expect(errors).to eq(nil)
      end
    end

    describe '#message' do
      it 'returns a human readable message' do
        expect(error.message).to eq('Response error (code: 400, body: )')
      end
    end
  end
end
