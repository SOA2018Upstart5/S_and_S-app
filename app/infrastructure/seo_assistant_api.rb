# frozen_string_literal: true

require 'http'

module SeoAssistant
  module Gateway
    # Infrastructure to call SeoAssistant API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def texts_list(list)
        @request.texts_list(list)
      end

      def add_text(encoded_text)
        @request.add_text(encoded_text)
      end

      def show_text(encoded_text)
        @request.show_text(encoded_text)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = config.API_HOST + '/api/v1'
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def articles_list(list)
          call_api('get', ['answer'],
                   'list' => Value::ListRequest.to_encoded(list))
        end

        def add_text(text)
          call_api('post', ['answer', text])
        end

        def show_text(text)
          call_api('get', ['answer', text])
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
            .yield_self { |str| str ? '?' + str : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
            .yield_self { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_STATUS = (200..299).freeze

        def success?
          SUCCESS_STATUS.include? code
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
