# frozen_string_literal: true

require_relative 'yabi/version'
require_relative 'yabi/base_interactor'
require_relative 'yabi/base_contract'
require_relative 'yabi/base_service'

require 'i18n'

# Load bundled translations for error messages.
YABI_LOCALE_PATH = File.expand_path('../config/locales/en.yml', __dir__)
unless I18n.load_path.include?(YABI_LOCALE_PATH)
  I18n.load_path << YABI_LOCALE_PATH
  I18n.backend.load_translations
end

module Yabi
end

# Provide global constants for easier adoption in existing Rails apps.
BaseInteractor = Yabi::BaseInteractor unless defined?(BaseInteractor)

# Backwards compatibility shim for legacy code using BaseService naming.
BaseService = Yabi::BaseInteractor unless defined?(BaseService)
