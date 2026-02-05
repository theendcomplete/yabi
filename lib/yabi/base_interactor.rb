# frozen_string_literal: true

require 'dry/monads/all'
require 'dry/validation'
require 'dry/initializer'
require 'dry/matcher/result_matcher'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash/keys'

module Yabi
  # Base object for building service objects / interactors backed by dry-rb.
  class BaseInteractor
    include Dry::Monads[:result, :do, :try, :maybe]
    extend Dry::Initializer

    # Optional Dry::Validation::Contract subclass to run before #call.
    class_attribute :contract

    class << self
      # Entrypoint. Instantiates, runs validation, then #call.
      def call(*positional_args, contract: nil, **args, &block)
        merged_args =
          if positional_args.first.is_a?(Hash)
            args.merge(positional_args.first)
          elsif positional_args.any?
            raise ArgumentError,
                  I18n.t('yabi.errors.unexpected_positional_arguments', args: positional_args.inspect)
          else
            args
          end

        normalized_args = transform_values_to_hash(merged_args)
        validation_contract = contract || self.contract

        instance = new(**normalized_args)
        validation = instance.validate_contract(validation_contract)
        result = validation.success? ? instance.call : instance.log_warning_and_return_failure(validation)

        return result unless block

        Dry::Matcher::ResultMatcher.call(result, &block)
      end

      def contract
        return unless const_defined?(:ValidationContract)

        const_get(:ValidationContract)
      end

      private

      # Normalize params: convert ActionController::Parameters and other to_h-capable
      # values, then deep-symbolize keys for dry-validation compatibility.
      def transform_values_to_hash(args)
        args.transform_values do |value|
          if value.respond_to?(:to_h) && !value.is_a?(Hash)
            value.to_h
          else
            value
          end
        end.deep_symbolize_keys
      end
    end

    # Run validation if a contract is provided; return Success() on skip.
    def validate_contract(validation_contract)
      return Success() unless validation_contract

      validation_contract.new.call(**attributes_for_contract)
    end

    # Hook for app-specific logging; override to plug in your logger.
    def log_warning_and_return_failure(validation)
      # LoggerService.call(message: "Validation failed: #{validation.errors.inspect}", level: :warn)
      errors = validation.respond_to?(:errors) ? validation.errors : validation
      errors = errors.to_h if errors.respond_to?(:to_h)
      Failure(errors)
    end

    # Implement in subclasses.
    def call
      raise NotImplementedError
    end

    # Convenience wrapper; no-op if ActiveRecord is missing.
    def in_transaction(&)
      ActiveRecord::Base.transaction(&)
    end

    # Wrap a block in Try and convert to Result with optional handlers.
    def safe_call(on_success: ->(s) { Success(s) }, on_error: ->(e) { Failure(e) }, &)
      Try(&).to_result.either(on_success, on_error)
    end

    private

    # Uses dry-initializer metadata to capture declared options/params rather than
    # every instance variable (which may include internal ones).
    def attributes_for_contract
      return self.class.dry_initializer.attributes(self) if self.class.respond_to?(:dry_initializer)

      fallback_instance_variables_hash
    end

    def fallback_instance_variables_hash
      instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete('@').to_sym
        hash[key] = instance_variable_get(var)
      end
    end
  end
end
