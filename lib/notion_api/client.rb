require_relative "types"
require_relative "block"
require "gemoji"

module Notion
  class Client < Block
    attr_reader :token_v2
    def initialize(token_v2, active_user_header=nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      Block.token_v2 = @token_v2
      Block.active_user_header = @active_user_header
    end
  end
end


heart = Emoji.find_by_alias("heart").raw

@client = Notion::Client.new(ENV["token_v2"])
@block = @client.get_block("c514520d-b597-47c8-ac01-06882a3ef172")
@block_to_move_to = @client.get_block("7375d19c-f163-453e-bb87-2ad863934f8c")
@moved_block = @block.move(@block_to_move_to, "before")
p @moved_block
#TODO: allow for different `position` inputs into the move method. Right now it only supports list After
# p Classes.each { |cls| @block.create(Notion.const_get(cls.to_s), DateTime.now.strftime("%H:%M:%S on %B %d %Y"), loc="df9a4bf7-0e0d-78d9-fa13-c5df01df033b") }