# frozen_string_literal: true

require 'dry/transaction'
require 'uri'
require 'json'

module SeoAssistant
  module Service
    # Analyzes contributions to a project
    class ShowText
      include Dry::Transaction

			step :decode_article
			step :request_text
			step :depresent_text
			
			private

			def decode_article(input)
				if input[:article_encoding].empty?
					Failure('Nothing pass to this page')
				else
					Success(text_encoding: input[:article_encoding])
				end
			end
			
			def request_text(input)
				result = Gateway::Api.new(SeoAssistant::App.config).show_text(input[:text_encoding])
				result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Cannot show information right now; please try again later')
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