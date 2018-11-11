#finished but need confirmed
require 'roda'
require 'slim'
require 'uri'
require 'json'

module SeoAssistant
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt

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
            routing.halt 400 if (article.empty?)

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

            puts article_unescaped

            text = Repository::For.klass(Entity::Text)
            .find_text(article_unescaped)

            view 'answer', locals: { answer: text }
          end
        end
      end
    end
  end
end
