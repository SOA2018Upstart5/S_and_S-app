# frozen_string_literal: true

require 'sequel'

module SeoAssistant
  module Database
    # Object Relational Mapper for Project Entities
    class KeywordOrm < Sequel::Model(:keywords)
      many_to_one :script,
                  class: :'SeoAssistant::Database::ScriptOrm',
                  key: :script_id

      plugin :timestamps, update_on_create: true


      def self.find_or_create(keyword_info)
        first(keyword: keyword_info[:keyword]) || create(keyword_info)
      end
    end
  end
end
