# frozen_string_literal: true
#not finished

require 'dry/transaction'
require 'uri'

module SeoAssistant
  module Service
    # Transaction to store project from Github API to database
    class AddText
      include Dry::Transaction

      step :validate_input
      step :request_text
      step :depresent_text

      private

      def validate_input(input)
        #encoding
        if input.success?
          article = input[:article].to_s
          text_encoding = URI.escape(article)
          Success(text_encoding: text_encoding)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def request_text(input)
        # API only receive encoding messenger
        result = Gateway::Api.new(SeoAssistant::App.config)
          .add_text(input[:text_encoding])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
        Failure('Cannot add text right now; please try again later')
      end

      def depresent_text(text_json)
        Representer::Text.new(OpenStruct.new)
          .from_json(text_json)
          .yield_self { |text| Success(text) }
      rescue StandardError
        Failure('Error in the text -- please try again')
      end
    end
  end
end
