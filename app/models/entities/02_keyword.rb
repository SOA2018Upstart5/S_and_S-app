require_relative '03_url.rb'

module SeoAssistant
  module Entity
    class Keyword < Dry::Struct
      include Dry::Types.module

      attribute :id,  Integer.optional
      attribute :word, Strict::String
      attribute :eng_word, Strict::String
      attribute :type, Strict::String
      attribute :importance, Strict::Float
      attribute :url, Url

      def to_attr_hash
        to_hash.reject { |key, _| [:id, :word, :eng_word, :type, :importance, :url].include? key }
      end
    end
  end
end
