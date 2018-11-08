%w[config app]
.each do |folder|
    require_relative "#{folder}/init.rb"
end

script = SeoAssistant::OutAPI::ScriptMapper
            .new(JSON.parse(SeoAssistant::App.config.GOOGLE_CREDS), SeoAssistant::App.config.UNSPLASH_ACCESS_KEY)
            .process("狗是最好的朋友")

puts script.each_keyword