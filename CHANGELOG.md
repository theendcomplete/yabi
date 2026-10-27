# Changelog

## 0.2.0 - 2026-10-27
- **Breaking:** require Ruby >= 3.3 (3.1 and 3.2 are EOL; current dry-rb releases need 3.3+).
- Updated development dependencies: rspec ~> 3.13, rubocop ~> 1.92, rubocop-rspec ~> 3.10.
- Dropped the RuboCop compatibility shim (`rubocop_compat.rb`), no longer needed with rubocop-rspec 3.
- CI: test on Ruby 3.3, 3.4 and 4.0; added a RuboCop job.
- README: install from RubyGems, document Ruby requirement, use `Yabi::BaseInteractor` in examples.

## 0.1.0 - 2026-02-05
- Extracted BaseInteractor (formerly BaseService) into the YABI gem.
- Added BaseContract wrapper and global shims (BaseInteractor/BaseService/BaseContract).
- Switched contract attribute capture to `dry_initializer.attributes` with instance-variable fallback.
- Removed bundled HTTP interactor (to drop Faraday dependency); README now includes an optional copy/paste example.
- BaseContract now defaults to the I18n message backend and loads dry-validation translations.
- Removed ActiveSupport dependency; internal helpers now handle symbolization and class-level contract accessors, reducing runtime deps.
