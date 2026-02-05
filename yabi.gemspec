# frozen_string_literal: true

require_relative 'lib/yabi/version'

Gem::Specification.new do |spec|
  spec.name          = 'yabi'
  spec.version       = Yabi::VERSION
  spec.authors       = ['Nikkie Grom']
  spec.email         = ['nikkie@nikkie.dev']

  spec.summary       = 'Yet Another Base Interactor'
  spec.description   = 'A small dry-rb-based base service/interactor with optional contract validation.'
  spec.homepage      = 'https://github.com/theendcomplete/yabi'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.1')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'config/locales/**/*', 'README.md', 'LICENSE', 'CHANGELOG.md']
  end

  spec.add_dependency 'dry-initializer', '>= 3.1'
  spec.add_dependency 'dry-matcher', '>= 1.0'
  spec.add_dependency 'dry-monads', '>= 1.6'
  spec.add_dependency 'dry-validation', '>= 1.10'
  spec.add_dependency 'i18n', '>= 1.6', '< 2'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.66'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.30'
  spec.add_development_dependency 'rubocop-rspec_rails', '~> 2.29'
end
