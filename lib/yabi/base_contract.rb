# frozen_string_literal: true

require 'dry/validation'

module Yabi
  # Opinionated base contract to share common Dry::Validation config.
  # Adjust load paths / message backends in your host app initializer if needed.
  class BaseContract < Dry::Validation::Contract
    # example defaults; host app can override via subclassing
    config.messages.default_locale = :en
  end
end

# Provide a global constant for easy migration.
unless defined?(::BaseContract)
  ::BaseContract = Yabi::BaseContract
end
