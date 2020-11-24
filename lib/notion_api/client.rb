# frozen_string_literal: true

require_relative 'blocks'
require_relative 'core'
require 'csv'

module Notion
  # acts as the 'gateway interface' to the methods of this package.
  class Client < Core
    attr_reader :token_v2, :active_user_header

    def initialize(token_v2, active_user_header = nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      super(token_v2, active_user_header)
    end
  end
end

# json = JSON.parse(File.read("test_data.json"))
# test_add_row = JSON.parse(File.read("new_row.json"))
# body = File.open("./vauto_inventory.csv")
# csv = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => :all)
# rows = []
# csv.to_a.map {|row|  rows.push(row.to_hash) }

# @client = Notion::Client.new(ENV["token_v2"])
# @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
# @cv = @page.get_collection("34d03794-ecdd-e42d-bb76-7e4aa77b6503")
# cdcc3283-953f-451c-de89-3b57978a26ce
# @page.create(Notion::LatexBlock, "y = x^2 + 3*x + 100", "97dcdfef-c085-f5b7-09a9-240a715a0871", "before")

# p @page.get_collection("f1664a99-165b-49cc-811c-84f37655908a").add_row({"emoji" => 'hi', 'aliases' => "NONE", 'category' => 'Smileys'})
# @block = @page.get_block("f86323b9-8b79-74a7-f268-b1a25ff4a892")
# @target = @page.get_block("f3354390-896b-4102-a9e5-321ac1ef7421")
# p @block.move(@target, 'before')
# p @page.create(Notion::TextBlock, "blah")
# ! Pick up with private methods in Core.rb for unit tests
# p Notion::Core.new.send("get_notion_id", {:pageId => "66447bc8-17f0-44bc-81ed-3cf4802e9b00",:chunkNumber => 0,:limit => 100,:verticalColumns => false})
# ! 38x46 seems to be max [total of ~1748 cells]
# p Classes.each { |cls| @block.create(Notion.const_get(cls.to_s), DateTime.now.strftime("%H:%M:%S on %B %d %Y"), loc="df9a4bf7-0e0d-78d9-fa13-c5df01df033b") }
