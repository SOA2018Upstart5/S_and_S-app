module SeoAssistant
    module OutAPI
      class UrlMapper
        def initialize(unsplash_access_key)
          @unsplash_key = unsplash_access_key
          @searchPic_class = SeoAssistant::OutAPI::Unsplash
        end

        def process(eng_keyword)
          pictures_data = @searchPic_class.new(@unsplash_key, eng_keyword).process
          build_entity(pictures_data)
        end

        def build_entity(pictures_data)
          DataMapper.new(pictures_data).build_entity
        end

        class DataMapper
          def initialize(pictures_data)
            @pictures_data = pictures_data['results']
          end

          def build_entity()
            SeoAssistant::Entity::Url.new(
              first_pic: first_pic,
              random_1_pic: random_1_pic
            )
          end

          def first_pic()
            @pictures_data[0]['urls']['raw'].to_s
          end

          def random_1_pic()
            num = rand(@pictures_data.length)
            @pictures_data[num]['urls']['raw'].to_s
          end
        end
      end
    end
  end