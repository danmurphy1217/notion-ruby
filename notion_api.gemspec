lib = File.expand_path('../lib', __FILE__)
# p %Q[#{lib} is the abs path.]
# p $LOAD_PATH
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#TODO: what is $LOAD_PATH?
#TODO: what does unshify do?

Gem::Specification.new do |spec|
    spec.name           = "notion_api"
    spec.version        = "1.0.0"
    spec.authors        = ["Dan Murphy"]
    spec.email          = ["danielmurph8@gmail.com"]
    spec.summary        = %q[Easily connect to Notion data with Ruby]
    spec.description    = %q[Easily connect to and core features of Notion with Ruby]
    spec.license        = "MIT"
    spec.homepage = "https://github.com/danmurphy1217/notion-ruby"

    spec.files = Dir[
        "README.md",
        "lib/**/*.rb",
      ]

    spec.add_dependency "httparty"
    spec.add_dependency "json"

    spec.add_development_dependency "bundler"
    spec.add_development_dependency "rufo"
    spec.add_development_dependency "rake"
end