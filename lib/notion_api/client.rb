require_relative "blocks"
require_relative "core"
require "csv"
# require "gemoji"

module Notion
  class Client < Core
    attr_reader :token_v2

    def initialize(token_v2, active_user_header = nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      Core.token_v2 = @token_v2
      Core.active_user_header = @active_user_header
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
# @page = @client.get_page("https://www.notion.so/danmurphy/Testing-66447bc817f044bc81ed3cf4802e9b00")
# @block = @page.get_collection("f1664a99-165b-49cc-811c-84f37655908a")
# p @block.add_property("hiya there", "checkbox")
# p @page.create_collection("table", "Test Car Data", rows)
# p @page.get_collection("f1664a99-165b-49cc-811c-84f37655908a")
#! 38x46 seems to be max [total of ~1748 cells]
# p Classes.each { |cls| @block.create(Notion.const_get(cls.to_s), DateTime.now.strftime("%H:%M:%S on %B %d %Y"), loc="df9a4bf7-0e0d-78d9-fa13-c5df01df033b") }
