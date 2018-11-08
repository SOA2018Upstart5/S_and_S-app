require_relative '03_url_mapper.rb'

module SeoAssistant
  module OutAPI
    class KeywordMapper
      def initialize(google_config, unsplash_access_key)
        @google_config = google_config
        @unsplash_key = unsplash_access_key
      end

      def load_several(results)
        results.map do |each_result|
          KeywordMapper.build_entity(@google_config, @unsplash_key, each_result)
        end
      end

      def self.build_entity(google_config, unsplash_access_key, each_result)
        DataMapper.new(google_config, unsplash_access_key, each_result).build_entity
      end

      class DataMapper
        def initialize(google_config, unsplash_access_key, each_result)
          @google_config = google_config
          @unsplash_key = unsplash_access_key
          @word = each_result.name
          @type = each_result.type
          @importance = each_result.salience
          @translate_class = SeoAssistant::OutAPI::Translate
          @eng_word = @translate_class.new(@google_config, @word).process
        end

        def build_entity()
          SeoAssistant::Entity::Keyword.new(
            id: nil,
            word: @word,
            eng_word: @eng_word,
            type: @type,
            importance: @importance,
            url: url
          )
        end

        def url()
          UrlMapper.new(@unsplash_key).process(@eng_word)
        end
      end
    end
  end
end