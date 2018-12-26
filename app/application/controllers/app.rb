#finished but need confirmed
require 'roda'
require 'slim'
require 'slim/include'
require 'uri'
require 'json'

#make sure database have no nil data or it will not get into home page.

module SeoAssistant
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :caching
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css', js: 'operation.js'

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS

      routing.root do
        # Get cookie viewer's previously seen texts without encoding
        session[:watching] ||= []
        # Load previously viewed texts
        result = Service::ListTexts.new.call(session[:watching])

        if result.failure?
          flash[:error] = result.failure
          texts = []
        else
          texts = result.value!.texts
          if texts.none?
            flash.now[:notice] = 'Add text to analysize !!'
          end
        end

        session[:watching] = texts.map(&:text)

        viewable_texts = Views::TextsList.new(texts)
        view 'home', locals: { texts: viewable_texts }
      end

      routing.on 'answer' do
        routing.is do
          # Add text
          # GET /answer/
          routing.post do
            # Get the input of article and check its form
            article_request = Forms::ArticleRequest.call(routing.params)
            # find if article exist or add it as new one
            text_made = Service::AddText.new.call(article_request)

            if text_made.failure?
              flash[:error] = text_made.failure
              routing.redirect '/'
            end

            # Add new text to watched set in cookies
            new_text = text_made.value!
            session[:watching].insert(0, new_text.text).uniq!
            
            # redirect with encoding text
            new_text_encoding = URI.escape(new_text.text)
            routing.redirect "answer/#{new_text_encoding}"
          end
        end

        routing.on String do |article|
          # article is encoding text
          # DELETE /project/{owner_name}/{project_name}
          routing.delete do
            # decode the article
            article_encoded = article.encode('UTF-8', invalid: :replace, undef: :replace)
            article_unescaped = URI.unescape(article_encoded).to_s

            canceled_article = "#{article_unescaped}"
            session[:watching].delete(canceled_article)

            routing.redirect '/'
          end
          # Show text
          # GET /answer/text
          routing.get do
            # find the text into database
            show_text = Service::ShowText.new.call(article_encoding: article)
            
            if show_text.failure?
              flash[:error] = show_text.failure
              routing.redirect '/'
            end

            text_info = show_text.value!
            viewable_text = Views::Text.new(text_info)

            response.expires 60, public: true
            view 'result', locals: { text: viewable_text }
          end
        end
      end
    end
  end
end
