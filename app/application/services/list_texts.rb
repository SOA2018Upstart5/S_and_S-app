# frozen_string_literal: true

require 'dry/monads'

module SeoAssistant
  module Service
    # Retrieves array of all listed project entities
    class ListTexts
      include Dry::Transaction

      step :get_api_list
      step :reify_list

      private

      def get_api_list(texts_list)
        Gateway::Api.new(SeoAssistant::App.config)
          .texts_list(texts_list)
          .yield_self do |result|
            result.success? ? Success(result.payload) : Failure(result.message)
          end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(texts_json)
        Representer::TextsList.new(OpenStruct.new)
          .from_json(texts_json)
          .yield_self { |texts| Success(texts) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end