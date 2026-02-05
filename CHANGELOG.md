# Changelog

## 0.1.0 - 2026-02-05
- Extracted BaseInteractor (formerly BaseService) into the YABI gem.
- Added BaseContract wrapper and global shims (BaseInteractor/BaseService/BaseContract).
- Switched contract attribute capture to `dry_initializer.attributes` with instance-variable fallback.
- Removed bundled HTTP interactor (to drop Faraday dependency); README now includes an optional copy/paste example.
- BaseContract now defaults to the I18n message backend and loads dry-validation translations.
- Removed ActiveSupport dependency; internal helpers now handle symbolization and class-level contract accessors, reducing runtime deps.
