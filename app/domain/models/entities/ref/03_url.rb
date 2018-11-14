module SeoAssistant
    module Entity
      class Url < Dry::Struct
        include Dry::Types.module
        
        attribute :first_pic, Strict::String
        attribute :random_1_pic, Strict::String
      end
    end
  end