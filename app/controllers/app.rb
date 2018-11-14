#finished but need confirmed
require 'roda'
require 'slim'
require 'slim/include'
require 'uri'
require 'json'

module SeoAssistant
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css'
    plugin :halt

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS

      # GET /
      #make sure database have no nil data
      #or it will not get into home page.
      routing.root do
        texts = Repository::For.klass(Entity::Text).all
        view 'home', locals: { texts: texts }
      end

      routing.on 'answer' do
        routing.is do
          # GET /answer/
          routing.post do
            article = routing.params['article'].to_s
            if (article.empty?)
              flash[:error] = 'Empty input'
              response.status = 400
              routing.redirect '/'
            end

            # Get text from API (SeoAssistant::Entity::Text)
            text = OutAPI::TextMapper
              .new(JSON.parse(App.config.GOOGLE_CREDS), App.config.UNSPLASH_ACCESS_KEY)
              .process(article)

            # Add script to database = SeoAssistant::Repository::Texts.create(text)
            Repository::For.entity(text).create(text)

            routing.redirect "answer/#{article}"
          end
        end

        routing.on String do |article|
          # GET /answer/text
          routing.get do
            article_encoded = article.encode('UTF-8', invalid: :replace, undef: :replace)
            article_unescaped = URI.unescape(article_encoded).to_s

            text = Repository::For.klass(Entity::Text)
            .find_text(article_unescaped)
            puts text

            view 'answer', locals: { answer: text }
          end
        end
      end
    end
  end
end
