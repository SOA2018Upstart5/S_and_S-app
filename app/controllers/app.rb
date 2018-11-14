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

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS

      # GET /
      #make sure database have no nil data
      #or it will not get into home page.
      routing.root do
        # Get cookie viewer's previously seen projects
        #session[:watching] ||= []

        # Load previously viewed texts
        #texts = Repository::For.klass(Entity::Text).find_text(session[:watching])

        #session[:watching] = texts.map(&:text)

        #if texts.none?
        #  flash.now[:notice] = 'Add an article to get started'
        #end

        #viewable_texts = Views::TextsList.new(texts)
        #view 'home', locals: { texts: viewable_texts }

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

            # Add text to database
            new_text = Repository::For.klass(Entity::Text).find_text(article)

            unless new_text
              begin
                # Get text from API (SeoAssistant::Entity::Text)
                new_text = OutAPI::TextMapper
                  .new(JSON.parse(App.config.GOOGLE_CREDS), App.config.UNSPLASH_ACCESS_KEY)
                  .process(article)
              rescue StandardError => error
                flash[:error] = 'Could not analysize the article'
                routing.redirect '/'
              end

              begin
                # Add script to database = SeoAssistant::Repository::Texts.create(text)
                Repository::For.entity(new_text).create(new_text)
              rescue StandardError => error
                puts error.backtrace.join("\n")
                flash[:error] = 'Having trouble accessing the database'
              end
            end

            # Add new text to watched set in cookies
            #session[:watching].insert(0, new_text.text).uniq!
            
            routing.redirect "answer/#{new_text.text}"
          end
        end

        routing.on String do |article|
          # DELETE /project/{owner_name}/{project_name}
          routing.delete do
            content = "#{article}"
            session[:watching].delete(content)

            routing.redirect '/'
          end

          # GET /answer/text
          routing.get do
            article_encoded = article.encode('UTF-8', invalid: :replace, undef: :replace)
            article_unescaped = URI.unescape(article_encoded).to_s

            begin
              text = Repository::For.klass(Entity::Text).find_text(article_unescaped)

              if text.nil?
                flash[:error] = 'Article not found'
                routing.redirect '/'
              end
            rescue StandardError
              flash[:error] = 'Having trouble accessing the database'
              routing.redirect '/'
            end

            view 'answer', locals: { answer: text }
          end
        end
      end
    end
  end
end
