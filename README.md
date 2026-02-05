# YABI — Yet Another Base Interactor

A tiny base class for service objects/interactors built on `dry-monads`, `dry-initializer`, and `dry-validation`, plus a minimal base contract.

## Installation

Add to your Gemfile (choose one):

- Core/lightweight (no HTTP interactor auto-required)
  ```ruby
  gem 'yabi', git: 'https://example.com/yabi.git'
  ```

- Full (explicitly include HTTP interactor and Faraday adapter choice)
  ```ruby
  gem 'yabi', git: 'https://example.com/yabi.git'
  # optional: pin your adapter stack; faraday is already a runtime dep of yabi
  gem 'faraday', '~> 2.9'
  ```

Require the gem (Rails autoloading works too):

```ruby
require 'yabi'
# and when you need HTTP interactor
require 'yabi/http/request_interactor'
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

YABI ships with `Yabi::BaseContract` (also available as `BaseContract`) which is a light wrapper around `Dry::Validation::Contract`. Customize it in your app if you want message backends, load paths, or locale tweaks:

```ruby
class ApplicationContract < Yabi::BaseContract
  config.messages.backend = :i18n
  config.messages.load_paths << Rails.root.join('config/locales/en.yml')
end
```

### Helpers

- `safe_call { ... }` wraps a block into `Try` and returns a Result.
- `in_transaction { ... }` delegates to `ActiveRecord::Base.transaction` when ActiveRecord is available.

### Attribute capture

`Yabi::BaseInteractor` uses `dry_initializer.attributes(self)` to collect declared options/params for validation instead of scraping every instance variable. This avoids leaking internal state while keeping compatibility with dry-initializer defaults. A fallback to the previous instance-variable scan remains for non-dry objects.

## Example: HTTP request interactor

```ruby
# optional: require 'yabi/http/request_interactor'

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
      key.failure(:invalid_http_method) unless %w[get post put patch delete].include?(value.to_s.downcase)
    end

    rule(:url) do
      key.failure(:invalid_url) unless value.to_s.match?(URI::DEFAULT_PARSER.make_regexp)
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
    request_params.is_a?(Hash) ? request_params.as_json : request_params
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

This interactor is available in the gem as `Yabi::Http::RequestInteractor` (require it explicitly). Faraday (~> 2.x) is used under the hood; configure adapters/options as needed via the `options` argument.

## Development

```sh
bundle install
bundle exec rspec
```

## License

MIT
