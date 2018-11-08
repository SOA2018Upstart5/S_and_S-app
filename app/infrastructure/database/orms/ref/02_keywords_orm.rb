# frozen_string_literal: true

require 'sequel'

module SeoAssistant
  module Database
    # Object Relational Mapper for Project Entities
    class KeywordOrm < Sequel::Model(:keywords)
      one_to_many :contained_urls,
                  class: :'SeoAssistant::Database::UrlOrm',
                  key: :word_id

      many_to_one :script,
                  class: :'SeoAssistant::Database::ScriptOrm'

      many_to_many :contributors,
                   class: :'CodePraise::Database::MemberOrm',
                   join_table: :projects_members,
                   left_key: :project_id, right_key: :member_id

      plugin :timestamps, update_on_create: true
    end
  end
end