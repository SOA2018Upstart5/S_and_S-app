# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:keywords) do
      primary_key :id
      foreign_key :script_id, :scripts

      String      :keyword
      String      :eng_keyword
      String      :type
      Float       :importance
      String      :image_url

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
