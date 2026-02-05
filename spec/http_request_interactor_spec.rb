# frozen_string_literal: true

require 'spec_helper'
require 'yabi/http/request_interactor'
require 'faraday'

RSpec.describe Yabi::Http::RequestInteractor do
  let(:url) { 'https://example.com' }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new(url:) do |builder|
      builder.adapter :test, stubs
    end
  end

  before do
    allow(Faraday).to receive(:new).and_return(connection)
  end

  it 'returns Success for a valid GET request' do
    stubs.get('/') { [200, { 'Content-Type' => 'application/json' }, '{"ok":true}'] }

    result = described_class.call(http_method: 'get', url: url)

    expect(result).to be_success
    expect(result.value!.status).to eq(200)
  end

  it 'fails validation for invalid http_method' do
    result = described_class.call(http_method: 'TRACE', url: url)

    expect(result).to be_failure
    expect(result.failure).to have_key(:http_method)
  end

  it 'fails validation for invalid url' do
    result = described_class.call(http_method: 'get', url: 'not-a-url')

    expect(result).to be_failure
    expect(result.failure).to have_key(:url)
  end

  it 'wraps Faraday exceptions in Failure' do
    stubs.get('/') { raise Faraday::TimeoutError }

    result = described_class.call(http_method: 'get', url: url)

    expect(result).to be_failure
    expect(result.failure).to be_a(Faraday::TimeoutError)
  end

  it 'normalizes string-keyed arguments' do
    stubs.get('/') { [200, {}, ''] }

    result = described_class.call('http_method' => 'get', 'url' => url)

    expect(result).to be_success
  end
end
