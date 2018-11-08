require_relative '02_keyword.rb'

module SeoAssistant
  module Entity
    class Script < Dry::Struct
      include Dry::Types.module

      attribute :id,  Integer.optional
      attribute :text, Strict::String
      attribute :keywords, Strict::Array.of(Keyword)
      attribute :each_keyword, Strict::Array
      attribute :num_keyword, Strict::Integer

      def to_attr_hash
        to_hash.reject { |key, _| [:id, :keywords].include? key }
      end
    end
  end
end
