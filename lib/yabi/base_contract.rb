# frozen_string_literal: true

require 'dry/validation'
require 'i18n'

module Yabi
  # Opinionated base contract to share common Dry::Validation config.
  # Adjust load paths / message backends in your host app initializer if needed.
  class BaseContract < Dry::Validation::Contract
    # example defaults; host app can override via subclassing
    config.messages.backend = :i18n
    config.messages.default_locale = :en
    if defined?(Gem) && Gem.loaded_specs['dry-validation']
      default_messages_path = File.join(Gem.loaded_specs['dry-validation'].full_gem_path, 'config', 'errors.yml')
      config.messages.load_paths << default_messages_path if File.exist?(default_messages_path)
    end
  end
end

# Provide a global constant for easy migration.
BaseContract = Yabi::BaseContract unless defined?(BaseContract)
