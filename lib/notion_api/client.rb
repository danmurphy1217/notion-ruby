# frozen_string_literal: true

require_relative "core"
require_relative "blocks"

module NotionAPI
  # acts as the 'main interface' to the methods of this package.
  class Client < Core
    attr_reader :token_v2, :active_user_header

    def initialize(token_v2, active_user_header = nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      super(token_v2, active_user_header)
    end
  end
end

@client = NotionAPI::Client.new(ENV["token_v2"])
@page = @client.get_page("https://www.notion.so/danmurphy/d9d49ca64a2a4911ad6dffe898a468e5?v=28d7c1ea5fe347d8ae002eee11e10888")
p @page
# @block = @page.create(NotionAPI::TextBlock, "Title")
# @block.title="NEW"
# @img = @page.create(NotionAPI::ImageBlock, "https://images.unsplash.com/photo-1467348733814-f93fc480bec6?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb", options: { image: "https://images.unsplash.com/photo-1467348733814-f93fc480bec6?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb" })
# p @img.title