# frozen_string_literal: true
#not finished

require 'dry/transaction'

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
        if input.success?
          article = input[:article].to_s
          Success(text: article)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def request_text(input)
        result = Gateway::Api.new(SeoAssistant::App.config)
          .add_text(input[:article])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
        Failure('Cannot add text right now; please try again later')
      end

      def depresent_text(input)
        Representer::Text.new(OpenStruct.new)
          .from_json(text_json)
          .yield_self { |text| Success(text) }
      rescue StandardError
        Failure('Error in the text -- please try again')
      end
    end
  end
end
