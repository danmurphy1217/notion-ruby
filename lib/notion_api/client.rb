# frozen_string_literal: true

require_relative 'core'
require_relative 'blocks'

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


@client = NotionAPI::Client.new(ENV['token_v2'])

@page = @client.get_page("https://www.notion.so/danmurphy/tutorials-69d5c69d287f402c9ea28934f890adc1")
@page.create(NotionAPI::ImageBlock, "Title", options: {url: "/Users/danielmurphy/Desktop/Screen Shot 2020-10-19 at 12.06.01 PM.png"})
# @page.create(NotionAPI::ImageBlock, "https://images.unsplash.com/photo-1467348733814-f93fc480bec6?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb")