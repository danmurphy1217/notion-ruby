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
@block = @client.get_block("3d17ba15-98bc-17e1-e68e-9e74062d485d")
# @block.checked= "yes"
# @block.title= "New new"
@block.duplicate
# p Classes.each { |cls| @block.create(Notion.const_get(cls.to_s), DateTime.now.strftime("%H:%M:%S on %B %d %Y"), loc="df9a4bf7-0e0d-78d9-fa13-c5df01df033b") }