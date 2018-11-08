#Not finished yet

module SeoAssistant
    module Repository
      # Repository for Project Entities
      class Scripts
        def self.all
          Database::ScriptOrm.all.map { |db_script| rebuild_entity(db_script) }
        end
  
        def self.find_text(text)
          # SELECT * FROM `projects` LEFT JOIN `members`
          # ON (`members`.`id` = `projects`.`owner_id`)
          # WHERE ((`username` = 'owner_name') AND (`name` = 'project_name'))
         
          ###############
          db_record = Database::ScriptOrm.find(text: text)
          ###############
          db_script = Database::ScriptOrm
            .left_join(:keywords, script_id: :id)
            .where(text: text)
            .first
          rebuild_entity(db_script)
        end
  
        def self.find(entity)
          find_origin_id(entity.origin_id)
        end
  
        def self.find_id(id)
          db_record = Database::ProjectOrm.first(id: id)
          rebuild_entity(db_record)
        end
  
        def self.find_origin_id(origin_id)
          db_record = Database::ProjectOrm.first(origin_id: origin_id)
          rebuild_entity(db_record)
        end
  
        def self.create(entity)
          raise 'Script already exists' if find(entity)
  
          db_script = PersistProject.new(entity).call
          rebuild_entity(db_script)
        end
  
        private
  
        def self.rebuild_entity(db_record)
          return nil unless db_record
  
          Entity::Script.new(
            db_record.to_hash.merge(
              keywords: Keywords.rebuild_many(db_record.keywords)
            )
          )
        end
  
        # Helper class to persist project and its members to database
        class PersistProject
          def initialize(entity)
            @entity = entity
          end
          
          def create_script
            Database::ScriptOrm.create(@entity.to_attr_hash)
          end
  
          def call
            create_script.tap do |db_script|
              @entity.keywords.each do |keyword|
                db_script.add_keyword(Keywords.db_find_or_create(contributor))
              end
            end
          end
        end
      end
    end
  end
  