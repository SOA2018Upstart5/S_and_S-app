module Views
    # View for a single project entity
  class Text_Keywords
    def initialize(text)
        @keywords = text.keywords.map.with_index { |kw, i| Keyword.new(kw, i) }
    end

    def keywords_num()
        text.keywords.map(&:word).length
    end

    def text_content
        @text.text
    end

  end
end