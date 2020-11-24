# frozen_string_literal: true

require_relative 'blocks'
require_relative 'core'
require 'csv'
# require "gemoji"

module Notion
  class Client < Core
    attr_reader :token_v2, :active_user_header

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
# @page = @client.get_page("https://www.notion.so/danmurphy/CORE-RB-TESTS-9c50a7b39ad74f2baa08b3c95f1f19e7")
# p @page.children
# ! Pick up with private methods in Core.rb for unit tests
# p Notion::Core.new.send("get_notion_id", {:pageId => "66447bc8-17f0-44bc-81ed-3cf4802e9b00",:chunkNumber => 0,:limit => 100,:verticalColumns => false})
# ! 38x46 seems to be max [total of ~1748 cells]
# p Classes.each { |cls| @block.create(Notion.const_get(cls.to_s), DateTime.now.strftime("%H:%M:%S on %B %d %Y"), loc="df9a4bf7-0e0d-78d9-fa13-c5df01df033b") }
