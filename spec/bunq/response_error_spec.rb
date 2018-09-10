require 'spec_helper'

describe Bunq::ResponseError do
  context 'with a JSON body' do
    let(:error) {
      json = '{"Error": "foo"}'
      Bunq::ResponseError.new(code: 400, headers: { 'Content-Type' => 'application/json' }, body: json)
    }

    describe '#parsed_body' do
      it 'returns the parsed JSON' do
        parsed_body = error.parsed_body
        expect(parsed_body).to eq({ "Error" => "foo" })
      end
    end

    describe '#errors' do
      it 'returns the Error field from the JSON body' do
        errors = error.errors
        expect(errors).to eq("foo")
      end
    end
  end

  context 'without a JSON body' do
    let(:error) {
      Bunq::ResponseError.new(code: 400, headers: nil, body: "")
    }

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
  end
end
