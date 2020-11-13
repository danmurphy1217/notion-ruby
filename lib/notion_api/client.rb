require_relative "block"
require_relative "types"
module Notion
    attr_reader :token_v2
    class Client < Block
        def initialize(token_v2)
            @token_v2 = token_v2
        end
    end
end


@client = Notion::Client.new(ENV["token_v2"])
# options for request
options = {}
options["cookies"] = {:token_v2 => ENV["token_v2"]}
options["headers"] = {'Content-Type' => 'application/json'}

@block = @client.get_block(url_or_id="a5816e1d-b6e8-4b7d-bbb6-fdc779f889e8", options)
# @block.title = "hi!"

styles = {
    #! you can only set text color of background color. They are mutually exclusive.
    #! one way around this is to change the default block color, and then mess with the background.
    :block_color => "gray",
    :text_color => "black", # the text color
    :text_styles => ["b", "i", "_"]
}
p @block
@block = @block.convert(Notion::QuoteBlock, styles)
p @block
# @block.checked=true

# children_ids = @client.get_block_children_ids(url_or_id="https://www.notion.so/danmurphy/Generic-Linux-CLI-24bb8c43a6c44561a5f5919d4bd86013", options)
# p children_ids
# all_page_ids = []
# children_ids.each do |id|
#     block = @client.get_block(id, options=options)[0]
#     all_page_ids.push(@client.get_block_children_ids(block, options=options))
# end

# all_page_ids.flatten.each do |id|
#     p @client.get_block(id, options=options)
# end