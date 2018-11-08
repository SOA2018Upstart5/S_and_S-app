require 'google/cloud/translate'

module SeoAssistant
  module OutAPI
    # Library of Google Translate API
    class Translate
      def initialize(chinese_str)
        @project_id = 'My Project'
        @text = chinese_str
        @target = 'eng'
      end

      def process
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = './config/google_credential.json'
        translate = Google::Cloud::Translate.new project_id: @project_id
        translation = translate.translate @text, to: @target
        translation.to_s
      end
    end
  end
end

include SeoAssistant::OutAPI
translate_word = Translate.new("狗,貓,公車")
puts translate_word.process #string