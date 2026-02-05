# YABI — Yet Another Base Interactor

A tiny base class for service objects/interactors built on `dry-monads`, `dry-initializer`, and `dry-validation`, plus a minimal base contract.

## Installation

Add to your Gemfile:

```ruby
gem 'yabi', git: 'https://example.com/yabi.git'
```

Require the gem (Rails autoloading works too):

```ruby
require 'yabi'
```

By default the gem exposes `Yabi::BaseInteractor` plus shims `BaseInteractor` and `BaseService` (only defined if missing) to ease migration of existing code.

## Usage

```ruby
class Users::Questions::Create < BaseInteractor
  option :question_text

  class ValidationContract < BaseContract
    params { required(:question_text).filled(:string) }
  end

  def call
    Success(question_text.upcase)
  end
end

Users::Questions::Create.call(question_text: 'hello')
# => Success(\"HELLO\")
```

### Contracts

Pass a contract via the `contract:` keyword when calling, or define an inner `ValidationContract` constant. Validation runs before `call`; failures return `Failure(errors)`.

YABI ships with `Yabi::BaseContract` (also available as `BaseContract`) which is a light wrapper around `Dry::Validation::Contract`. It uses the `:i18n` messages backend by default and loads the built‑in dry-validation translations. Customize it in your app if you want different load paths or locales:

```ruby
class ApplicationContract < Yabi::BaseContract
  config.messages.default_locale = :es
  config.messages.load_paths << Rails.root.join('config/locales/es.yml')
end
```

### Error messages & I18n

The gem ships an English locale file at `config/locales/en.yml` and loads it automatically. Errors raised inside YABI (e.g., for unexpected positional arguments) are translated via `I18n.t('yabi.errors.*')`. Override translations by adding your own locale files earlier in `I18n.load_path` or by setting `I18n.locale`.

### Helpers

- `safe_call { ... }` wraps a block into `Try` and returns a Result.
- `in_transaction { ... }` delegates to `ActiveRecord::Base.transaction` when ActiveRecord is available.

### Attribute capture

`Yabi::BaseInteractor` uses `dry_initializer.attributes(self)` to collect declared options/params for validation instead of scraping every instance variable. This avoids leaking internal state while keeping compatibility with dry-initializer defaults. A fallback to the previous instance-variable scan remains for non-dry objects.

## Example: HTTP request interactor (not included in the gem)

The gem no longer ships an HTTP interactor to avoid adding Faraday as a runtime
dependency. If you want one, you can copy/paste or adapt the example below.
Remember to add Faraday (or your preferred adapter) to your own Gemfile.

```ruby
require 'faraday'
require 'uri'

class Integrations::Http::Requests::Make < BaseInteractor
  option :http_method
  option :url
  option :request_params, default: -> { {} }
  option :request_headers, default: -> { {} }
  option :options, default: -> { {} }

  class ValidationContract < BaseContract
    params do
      required(:http_method).filled(:string)
      required(:url).filled(:string)
      optional(:request_params)
      optional(:request_headers)
      optional(:options)
    end

    rule(:http_method) do
      key.failure('is not a supported HTTP method') unless %w[get post put patch delete].include?(value.to_s.downcase)
    end

    rule(:url) do
      key.failure('is not a valid URL') unless value.to_s.match?(URI::DEFAULT_PARSER.make_regexp)
    end
  end

  def call
    response = yield safe_call { faraday_client.public_send(http_method.to_sym, '', prepared_request_params) }
    Success(response)
  end

  private

  def faraday_client
    Faraday.new(url:, headers: request_headers, **options) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  def prepared_request_params
    request_params.respond_to?(:to_h) ? request_params.to_h : request_params
  end
end

Integrations::Http::Requests::Make.call(
  http_method: 'get',
  url: 'https://jsonplaceholder.typicode.com/posts/1'
).either(
  ->(response) { puts \"Success: #{response.status}\" },
  ->(error)    { puts \"Error: #{error}\" }
)
```
This interactor is only an example; include it in your own app if desired and add
Faraday (or another HTTP client) to your dependencies.

## Development

```sh
bundle install
bundle exec rspec
```

## License

MIT
