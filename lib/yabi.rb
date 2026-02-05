# frozen_string_literal: true

require_relative 'yabi/version'
require_relative 'yabi/base_interactor'
require_relative 'yabi/base_contract'
require_relative 'yabi/base_service'

module Yabi
end

# Provide global constants for easier adoption in existing Rails apps.
unless defined?(::BaseInteractor)
  ::BaseInteractor = Yabi::BaseInteractor
end

# Backwards compatibility shim for legacy code using BaseService naming.
unless defined?(::BaseService)
  ::BaseService = Yabi::BaseInteractor
end
