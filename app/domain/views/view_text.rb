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
  
      def text_link
        "/answer/#{text_content}"
      end
  
      def index_str
        "text[#{@index}]"
      end
  
      def text_content
        @text.text
      end

      def each_keyword
        @text.keywords.map(&:word).join(', ')
      end
    end
  end
  