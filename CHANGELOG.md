# Changelog

## 0.1.0 - 2026-02-05
- Extracted BaseInteractor (formerly BaseService) into the YABI gem.
- Added BaseContract wrapper and global shims (BaseInteractor/BaseService/BaseContract).
- Switched contract attribute capture to `dry_initializer.attributes` with instance-variable fallback.
- Added optional `Yabi::Http::RequestInteractor` built on Faraday with validation and `safe_call`.
