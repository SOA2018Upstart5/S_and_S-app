require_relative '03_url.rb'

module SeoAssistant
  module Entity
    class Keyword < Dry::Struct
      include Dry::Types.module

      attribute :id,  Integer.optional
      attribute :keyword, Strict::String
      attribute :eng_keyword, Strict::String
      attribute :type, Strict::Symbol
      attribute :importance, Strict::Float
      attribute :url, Url

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
