require_relative "types"
require_relative "block"
require "gemoji"

module Notion
  attr_reader :token_v2

  class Client < Block
    def initialize(token_v2)
      @token_v2 = token_v2
    end
  end
end


cat = Emoji.find_by_alias("heart").raw

@client = Notion::Client.new(ENV["token_v2"])
@block = @client.get_block("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66")
@block.create_page("Hi", cat)

# @block = @client.get_block(url_or_id = "17b49955-22d2-47c0-9164-431271fa441e")
# @block.title = "hey!!!!"
# @block = @block.convert(Notion::CalloutBlock)
# POSSIBLE STYLES: ["_", "b", "s", "i", "c"]
# styles = {
#   #! you can only set text color of background color. They are mutually exclusive.
#   #! one way around this is to change the default block color, and then mess with the background.
#   :text_color => "teal", # the text color
#   :text_styles => ["b", "c"],
#   :background => false,
# }
# p @block.update(styles = styles)

# USE CASE: create subpage, dump meta-data from API requests.
