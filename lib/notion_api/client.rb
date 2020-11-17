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


heart = Emoji.find_by_alias("heart").raw

@client = Notion::Client.new("44c8fae922d1f47f7485f26e96e95a35db7e3cb39af7416ea26422ce043b08789c0b04a61573cecb09db54000c501afff8e14c7a536d3c3c0a9a5ce45c599ac31f4c2d1c67445d0d4f46d6ec96df")

#! get a page (referred to as a root-level block)
@block = @client.get_block("https://www.notion.so/stacauto/Check-in-Meeting-Notes-8c6ac2dc771a4bf5985acdbab25d4ae2")
p @block

# styles = {
#   #! you can only set text color of background color. They are mutually exclusive.
#   #! one way around this is to change the default block color, and then mess with the background.
#   :color => "teal", # the text color
#   :text_styles => ["b", "i", "_", "c"],
#   :background => true,
#   :coding_language => "ruby",
#   :emoji => heart,
#   :code => "p 'hello world!'"
# }

# # p CLASSES.each { |cls| @block.create("heeyyy", Notion.const_get(cls.to_s), styles) }

# @block = @client.get_block("ace2589f-4897-52db-0091-5e9ec3a0b3b2")




# # @block.create("Hello", Notion::TodoBlock, styles=styles)
# #! create a subpage with stles


# =begin
# POSSIBLE STYLES: ["_", "b", "s", "i", "c"]
# Takeaways:
# 1. The following block types act in a very similar way AND should accept similar styles:
#   - to-do, header, sub-header, sub-sub-header, toggle, bulleted_list, numbered_list, quote, text, table of contents [styling should be applied differently though]
# 2. The following block types act a bit differently than above but are similar to one another in design and style:
#   - page, callout [callout accepts same styles as above and can also have an icon, page can have an icon too]
# 3. The following block types are relatively unique in their creation and styling:
#   - divider (accepts no styles)
#   - image : No need for a title. looks like I'll need to send the image to S3 first, then retrieve it and create the block.
#   - code: needs a language specified
#   - equation: exact same as text but the args are a bit diff: ["⁍", [["e", "x = x^2"]]]
#   - 
# =end