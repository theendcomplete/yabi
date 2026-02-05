# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yabi::BaseInteractor do
  describe '.call' do
    let(:service_class) do
      Class.new(described_class) do
        option :foo

        const_set(
          :ValidationContract,
          Class.new(Dry::Validation::Contract) do
            params { required(:foo).filled(:integer) }
          end
        )

        def call
          Success(foo * 2)
        end
      end
    end

    it 'validates and executes call for valid input' do
      result = service_class.call(foo: 2)

      expect(result).to be_success
      expect(result.value!).to eq(4)
    end

    it 'returns failure with validation errors for invalid input' do
      result = service_class.call(foo: 'bad')

      expect(result).to be_failure
      expect(result.failure).to have_key(:foo)
    end

    it 'normalizes string-keyed arguments' do
      result = service_class.call({ 'foo' => 3 })

      expect(result).to be_success
      expect(result.value!).to eq(6)
    end

    it 'localizes unexpected positional argument errors' do
      expect do
        service_class.call(1)
      end.to raise_error(ArgumentError, I18n.t('yabi.errors.unexpected_positional_arguments', args: '[1]'))
    end
  end

  describe '#attributes_for_contract' do
    it 'uses dry-initializer attributes and ignores internal ivars' do
      custom_service = Class.new(described_class) do
        option :foo

        def initialize(foo:)
          super
          @internal = :secret
        end

        def call
          Success(foo)
        end
      end

      instance = custom_service.new(foo: 5)

      expect(instance.send(:attributes_for_contract)).to eq(foo: 5)
    end
  end

  describe 'compatibility shim' do
    it 'defines top-level shims for legacy names' do
      expect(Object.const_defined?(:BaseInteractor)).to be(true)
      expect(BaseInteractor).to eq(described_class)
      expect(BaseService).to eq(described_class)
    end
  end
end

RSpec.describe Yabi::BaseContract do
  it 'is available as BaseContract' do
    expect(BaseContract).to eq(described_class)
  end

  it 'sets a default locale that can be overridden' do
    subclass = Class.new(described_class) do
      config.messages.default_locale = :ru
    end

    expect(described_class.config.messages.default_locale).to eq(:en)
    expect(subclass.config.messages.default_locale).to eq(:ru)
  end
end
