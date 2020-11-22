require "notion_api"

RSpec.configure do |conf|
  conf.before(:example) do
    @client = Notion::Client.new(ENV["token_v2"])
  end
end