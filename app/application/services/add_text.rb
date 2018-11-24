# frozen_string_literal: true
#not finished

require 'dry/transaction'

module SeoAssistant
  module Service
    # Transaction to store project from Github API to database
    class AddText
      include Dry::Transaction

      step :validate_input
      step :find_text
      step :store_text

      private

      def validate_input(input)
        if input.success?
          article = input[:article_check].to_s
          Success(article: article)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def find_text(input)
        if (project = project_in_database(input))
          input[:local_project] = project
        else
          input[:remote_project] = project_from_github(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_text(input)
        project =
          if (new_proj = input[:remote_project])
            Repository::For.entity(new_proj).create(new_proj)
          else
            input[:local_project]
          end
        Success(project)
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def project_from_github(input)
        Github::ProjectMapper
          .new(App.config.GITHUB_TOKEN)
          .find(input[:owner_name], input[:project_name])
      rescue StandardError
        raise 'Could not find that project on Github'
      end

      def project_in_database(input)
        Repository::For.klass(Entity::Project)
          .find_full_name(input[:owner_name], input[:project_name])
      end
    end
  end
end
