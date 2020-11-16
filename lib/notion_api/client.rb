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

@client = Notion::Client.new(ENV["token_v2"])

#! get a page (referred to as a root-level block)
@block = @client.get_block("https://www.notion.so/danmurphy/Tutorial-6c516b1009904d4da875c7e7af8329ba")


styles = {
  #! you can only set text color of background color. They are mutually exclusive.
  #! one way around this is to change the default block color, and then mess with the background.
  :color => "teal", # the text color
  :text_styles => ["b", "i", "_", "c"],
  :background => true,
  :coding_language => "ruby",
  :emoji => heart,
  :code => "p 'hello world!'"
}

# p CLASSES.each { |cls| @block.create("heeyyy", Notion.const_get(cls.to_s), styles) }

@block = @client.get_block("106050d8-7fcc-5fe5-a816-8158718c54f6")

@block.duplicate("652b350e-4561-df87-c919-25a0f76fca0e")




# @block.create("Hello", Notion::TodoBlock, styles=styles)
#! create a subpage with stles


=begin
POSSIBLE STYLES: ["_", "b", "s", "i", "c"]
Takeaways:
1. The following block types act in a very similar way AND should accept similar styles:
  - to-do, header, sub-header, sub-sub-header, toggle, bulleted_list, numbered_list, quote, text, table of contents [styling should be applied differently though]
2. The following block types act a bit differently than above but are similar to one another in design and style:
  - page, callout [callout accepts same styles as above and can also have an icon, page can have an icon too]
3. The following block types are relatively unique in their creation and styling:
  - divider (accepts no styles)
  - image : No need for a title. looks like I'll need to send the image to S3 first, then retrieve it and create the block.
  - code: needs a language specified
  - equation: exact same as text but the args are a bit diff: ["⁍", [["e", "x = x^2"]]]
  - 
=end