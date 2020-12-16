lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "notion_api/version"

Gem::Specification.new do |spec|
    spec.name           = "notion"
    spec.version        = NotionAPI::VERSION
    spec.authors        = ["Dan Murphy"]
    spec.email          = ["danielmurph8@gmail.com"]
    spec.summary        = %q[A lightweight gem that allows you to easily read, write, and update Notion data with Ruby]
    spec.description    = <<~DESC
    The Notion API gem allows Ruby developers to programmatically access their Notion pages.
    They can add new blocks, move blocks to different locations, duplicate blocks, update 
    properties of blocks, create and update children blocks, and create and update tables.
    DESC
    spec.license        = "MIT"
    spec.homepage = "https://danmurphy1217.github.io/notion-ruby/"
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.files = Dir[
        "lib/**/*.rb",
    ]

    spec.extra_rdoc_files = [
      "LICENSE.md",
      "README.md",
    ]

    spec.required_ruby_version = ">= 2.5"

    spec.add_runtime_dependency('httparty', '~> 0.17')
    spec.add_runtime_dependency('json', '~> 2.2')

    spec.add_development_dependency("bundler")
    spec.add_development_dependency("rake", "~> 13.0.0")
    spec.add_development_dependency("rspec", "~> 3.9.0")
    spec.add_development_dependency("rubocop", "~> 1.4.0")
end