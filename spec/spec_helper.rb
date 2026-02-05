# frozen_string_literal: true

require 'bundler/setup'
require 'yabi'
require 'dry/validation'
require 'dry/monads'
require 'rspec'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end
