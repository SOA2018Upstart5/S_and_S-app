# frozen_string_literal: true
#Not finished yet

module SeoAssistant
    module Repository
      # Repository for Keywords
      class Keywords
        def self.find_id(id)
          rebuild_entity Database::KeywordOrm.first(id: id)
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
          db_records.map do |db_word|
            Members.rebuild_entity(db_word)
          end
        end

        def self.db_find_or_create(entity)
          Database::KeywordOrm.find_or_create(entity.to_attr_hash)
        end
      end
    end
  end
