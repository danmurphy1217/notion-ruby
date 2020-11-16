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


dog = Emoji.find_by_alias("eyes").raw

@client = Notion::Client.new(ENV["token_v2"])
#! get a page (referred to as a root-level block)
# @block = @client.get_block("https://www.notion.so/danmurphy/Econometrics-7375d19cf163453ebb872ad863934f8c")
@block = @client.get_block("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66")
#! create a subpage with stles
# p @block.get_block_children_ids(@block.id)
# p @block.get_block_children_ids(@block.parent_id)
p @block
styles = {
  #! you can only set text color of background color. They are mutually exclusive.
  #! one way around this is to change the default block color, and then mess with the background.
  :color => "red", # the text color
  :text_styles => ["b", "i", "_", "c"],
  :background => true,
  :coding_language => "ruby",
  :emoji => dog,
  :code => "p 'hello world'"
}

# @block.create("I should work", Notion::PageBlock, styles)

# p @block.create_page("heuyyy", "page", styles= styles)
# @block.update(styles)
# p @block.create("heuyyy", Notion::CodeBlock, styles= styles)


=begin
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

# @block = @block.convert(Notion::CalloutBlock)
# POSSIBLE STYLES: ["_", "b", "s", "i", "c"]
# styles = {
#   #! you can only set text color of background color. They are mutually exclusive.
#   #! one way around this is to change the default block color, and then mess with the background.
#   :text_color => "teal", # the text color
#   :text_styles => ["b", "i", "_"],
#   :background => true,
# }
# p @block.update(styles = styles)

# USE CASE: create subpage, dump meta-data from API requests.
