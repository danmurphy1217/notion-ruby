require_relative "blocks"
require_relative "core"
require "gemoji"

module Notion
  class Client < Block
    attr_reader :token_v2

    def initialize(token_v2, active_user_header = nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      Block.token_v2 = @token_v2
      Block.active_user_header = @active_user_header
    end
  end
end

f = File.read("test_data.json")
json = JSON.parse(f)
@client = Notion::Client.new(ENV["token_v2"])
@block = @client.get_block("https://www.notion.so/danmurphy/Testing-c632fa6c9e8a4b0f945553f3dda1dc53")
new_block = @block.create_collection("table", "Hiya 2.0!", json)

# p Classes.each { |cls| @block.create(Notion.const_get(cls.to_s), DateTime.now.strftime("%H:%M:%S on %B %d %Y"), loc="df9a4bf7-0e0d-78d9-fa13-c5df01df033b") }
