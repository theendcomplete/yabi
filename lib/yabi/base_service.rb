# frozen_string_literal: true

require_relative 'base_interactor'

module Yabi
  # Backwards compatibility wrapper. Prefer Yabi::BaseInteractor.
  BaseService = BaseInteractor
end

unless defined?(::BaseService)
  ::BaseService = Yabi::BaseService
end
