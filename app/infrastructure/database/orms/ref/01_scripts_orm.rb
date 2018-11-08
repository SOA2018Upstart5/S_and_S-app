# frozen_string_literal: true

require 'sequel'

module SeoAssistant
  module Database
    # Object-Relational Mapper for Members
    class ScriptOrm < Sequel::Model(:scripts)
      one_to_many :contained_keywords,
                  class: :'SeoAssistant::Database::KeywordOrm',
                  key: :script_id

      many_to_many :contributed_keywords,
                   class: :'SeoAssistant::Database::KeywordOrm',
                   join_table: :scripts_keywords,
                   left_key: :script_id, right_key: :keyword_id

      plugin :timestamps, update_on_create: true
    end
  end
end