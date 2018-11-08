# frozen_string_literal: true
#Not finished yet

module SeoAssistant
    module Repository
      # Repository for Keywords
      class Keywords
        def self.find_id(id)
          rebuild_entity Database::KeywordOrm.first(id: id)
        end
  
        def self.find_text(text)
          rebuild_entity Database::KeywordOrm.first(text: text)
        end
  
        private
  
        def self.rebuild_entity(db_record)
          return nil unless db_record
  
          Entity::Member.new(
            id:           db_record.id,
            keyword:      db_record.keyword,
            eng_keyword:  db_record.eng_keyword,
            type:         db_record.type,
            importance:   db_record.importance,
            url:          db_record.url
          )
        end
  
        def self.rebuild_many(db_records)
          db_records.map do |db_member|
            Members.rebuild_entity(db_member)
          end
        end
  
        def self.db_find_or_create(entity)
          Database::KeywordOrm.find_or_create(entity.to_attr_hash)
        end
      end
    end
  end
  