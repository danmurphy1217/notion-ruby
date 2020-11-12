require_relative "utils"
require "httparty"
require "date"

module Notion
  class BlockTemplate
    include Utils

    @@method_urls = URLS
    attr_reader :type, :id, :title, :parent_id
    #! Base Template for all blocks. When a request is sent for a block,
    #! a specific block class instance is returned. The type of
    #! block class instance that is returned defines the methods
    #! and available functionality for the developer. Given this,
    #! many core methods surrounding updating data and accessing
    #! block attributes are defined here.
    def initialize(type, id, title, parent_id, options = {})
      @type = type
      @id = id
      @title = title
      @parent_id = parent_id
      @options = options
    end # initialize

    def title=(new_title)
      update_title(new_title)
      p "Title changed from #{self.title} to #{new_title}."
    end # title=

    def update_title(new_title)
      # options are propagated from the initial get_block call.
      cookies = !@options["cookies"].nil? ? @options["cookies"] : { :token_v2.to_s => token_v2 }
      headers = !@options["headers"].nil? ? @options["headers"] : { "Content-Type" => "application/json" }
      request_url = @@method_urls[:UPDATE_BLOCK]
      timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i

      #! when updating a block, notion does three things:
      #! 1. If updating a title, notion will update the properties and title paths and set a new title
      #! 2. Then, Notion will update the last time that block was updated by accessing the last_edited_time path (this is done with the UNIX timestamp multiplied by 1000 [since they're using JS, and JS using the number of MS since epoch])
      #! 3. Then, Notion will update the last time the page that contains that block was updated (same UNIX timestamp x 1000).
      request_body = {
        :requestId => @id,
        :transactions => [
          {
            :id => @id,
            :operations => [
              # UPDATE BLOCK TITLE
              {
                :id => @id,
                :table => "block",
                :path => ["properties", "title"],
                :command => "set",
                :args => [[new_title]],
              },
              # UPDATE BLOCK ID LAST EDITED TIME
              {
                :table => "block",
                :id => @id,
                :path => [
                  "last_edited_time",
                ],
                :command => "set",
                :args => timestamp,
              },
              # UPDATE PARENT ID LAST EDITED TIME
              {
                :table => "block",
                :id => @parent_id,
                :path => [
                  "last_edited_time",
                ],
                :command => "set",
                :args => timestamp,
              },
            ],
          },
        ],
      }

      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return response.body
    end # update_title

    def build_update_title_payload
    end # build_update_title_payload
  end # BlockTemplate
end # Notion
