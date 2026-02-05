# frozen_string_literal: true

require_relative '../base_interactor'

begin
  require 'faraday'
rescue LoadError => e
  warn 'Faraday is required for Yabi::Http::RequestInteractor. Please add gem "faraday" to your application.'
  raise e
end

module Yabi
  module Http
    # Interactor that performs an HTTP request via Faraday.
    class RequestInteractor < BaseInteractor
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
  end
end
