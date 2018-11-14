module Views
    # View for a single project entity
    class Text
      def initialize(text, index = nil)
        @text = text
        @index = index
      end
  
      def entity
        @text
      end
  
      def praise_link
        "/answer/#{article}"
      end
  
      def index_str
        "text[#{@index}]"
      end
  
      def article
        @text.text
      end
    end
  end
  