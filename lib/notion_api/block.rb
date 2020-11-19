require_relative "types"
require_relative "utils"
require "httparty"

module Notion
  class Block
    include Utils
    @@method_urls = URLS # defined in Utils
    @@options = { "cookies" => { :token_v2 => nil }, "headers" => { "Content-Type" => "application/json" } }
    @@type_whitelist = ("divider")
    attr_reader :token_v2, :clean_id, :cookies, :headers

    def get_notion_id(body)
      #! retrieves a users ID from the headers of a Notion response object.
      #! body -> the body to send in the request : ``Hash``
      @@options["cookies"][:token_v2] = self.token_v2
      cookies = !@@options["cookies"].nil? ? @@options["cookies"] : { :token_v2.to_s => token_v2 }
      headers = !@@options["headers"].nil? ? @@options["headers"] : { "Content-Type" => "application/json" }
      request_url = @@method_urls[:GET_BLOCK]

      response = HTTParty.post(
        request_url,
        :body => body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return response.headers["x-notion-user-id"]
    end

    def get_last_page_block_id(url_or_id)
      #! retrieve and return the last child ID of a block.
      #! url_or_id -> the block ID or URL : ``str``
      return children_ids(url_or_id).empty? ? [] : children_ids(url_or_id)[-1]
    end

    def get_all_block_info(clean_id, body)
      #! retrieves all info pertaining to a block Id.
      #! clean_id -> the block ID or URL cleaned : ``str``
      @@options["cookies"][:token_v2] = self.token_v2
      cookies = @@options["cookies"] ? @@options["cookies"] : { :token_v2.to_s => token_v2 }
      headers = @@options["headers"] ? @@options["headers"] : { "Content-Type" => "application/json" }

      # PATHSTREAM
      # headers["x-notion-active-user-header"] = "1dd05d38-b8ba-4b29-bde0-c4775b1eac77"
      # PERSONAL
      # headers["x-notion-active-user-header"] = "0c5f02f3-495d-4b73-b1c5-9f6fe03a8c26"
      # STACAUTO
      # headers["x-notion-active-user-header"] = "b22f2670-a643-49e1-bc49-05e8763f92e4"

      request_url = @@method_urls[:GET_BLOCK]

      response = HTTParty.post(
        request_url,
        :body => body.to_json,
        :cookies => cookies,
        :headers => headers,
      )

      # headers["x-notion-active-user-header"] = "b22f2670-a643-49e1-bc49-05e8763f92e4"

      res_two = HTTParty.post(
        "https://www.notion.so/api/v3/loadUserContent",
        :body => { :platform => "web" }.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      # p res_two.headers["x-notion-user-id"], "YERRR"
      jsonified_record_response = JSON.parse(response.body)["recordMap"]
      return jsonified_record_response
    end

    def filter_nil_blocks(jsonified_record_response)
      #! removes any blocks that are empty [i.e. have no title / content]
      #! jsonified_record_responses -> parsed JSON representation of a notion response object : ``Json``
      return jsonified_record_response["block"].empty? ? nil : jsonified_record_response["block"]
    end

    def extract_title(clean_id, jsonified_record_response)
      #! extract title from core JSON Notion response object.
      #! clean_id -> the cleaned block ID: ``str``
      #! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      filter_nil_blocks = filter_nil_blocks(jsonified_record_response)
      if filter_nil_blocks.nil?
        return nil
      else
        if !filter_nil_blocks[clean_id]["value"]["properties"].nil?
          # titles for images are called source, while titles for text-based blocks are called title, so lets dynamically grab it
          # https://stackoverflow.com/questions/23765996/get-all-keys-from-ruby-hash/23766007
          title_value = filter_nil_blocks[clean_id]["value"]["properties"].keys[0]
          filter_nil_titles = @@type_whitelist.include?(filter_nil_blocks[clean_id]["value"]["type"]) ? nil : jsonified_record_response["block"][clean_id]["value"]["properties"][title_value].flatten[0]
          return filter_nil_titles
        end
      end
    end

    def extract_type(clean_id, jsonified_record_response)
      #! extract type from core JSON response object.
      #! clean_id -> the block ID or URL cleaned : ``str``
      #! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      filter_nil_blocks = filter_nil_blocks(jsonified_record_response)
      if filter_nil_blocks.nil?
        return nil
      else
        block_type = filter_nil_blocks[clean_id]["value"]["type"]
        return block_type
      end
    end

    def extract_children_ids(clean_id, jsonified_record_response)
      #! extract children IDs from core JSON response object.
      #! clean_id -> the block ID or URL cleaned : ``str``
      #! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      return !jsonified_record_response.empty? ? jsonified_record_response["block"][clean_id]["value"]["content"] : {}
    end

    def extract_parent_id(clean_id, jsonified_record_response)
      #! extract parent ID from core JSON response object.
      #! clean_id -> the block ID or URL cleaned : ``str``
      #! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      return !jsonified_record_response["block"].empty? ? jsonified_record_response["block"][clean_id]["value"]["parent_id"] : {}
    end

    def extract_id(url_or_id)
      #! parse and clean the URL or ID object provided.
      #! url_or_id -> the block ID or URL : ``str``
      http_or_https = url_or_id.match(/^(http|https)/) # true if http or https in url_or_id...
      if (url_or_id.length == 36) and (url_or_id.split("-").length == 5 and !http_or_https)
        # passes if url_or_id is perfectly formatted already...
        return url_or_id
      elsif (http_or_https and url_or_id.split("-").last.length == 32) or (!http_or_https and url_or_id.length == 32)
        # passes if either:
        # 1. a URL is passed as url_or_id and the ID at the end is 32 characters long or 
        # 2. a URL is not passed and the ID length is 32 [aka unformatted]
        pattern = [8, 13, 18, 23]
        id = url_or_id.split("-").last
        pattern.each { |index| id.insert(index, "-") }
        return id
      else
        raise "Expected a Notion page URL or a page ID. Please consult the documentation for further information."
      end
    end

    def get_block(url_or_id)
      #! retrieve a Notion Block and return its instantiated class object.
      #! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)

      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response["block"].empty?
        if i >= 20
          return {}
        else
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
      end
      block_id = clean_id
      block_title = extract_title(clean_id, jsonified_record_response)
      block_type = extract_type(clean_id, jsonified_record_response)
      #TODO: figure out how to best translate notions markdown formatting into plaintext for content delivery.
      if jsonified_record_response["block"][clean_id]["value"]["parent_table"] == "space"
        # unique case for top-level page... top-level pages have the same ID and parent ID.
        block_parent_id = clean_id
        block_type = "page"
      else
        block_parent_id = extract_parent_id(clean_id, jsonified_record_response)
      end

      if block_type.nil?
        return {}
      else
        block_class = Notion.const_get(BLOCK_TYPES[block_type].to_s)
        return block_class.new(block_type, block_id, block_title, block_parent_id, self.token_v2)
      end
    end

    def children(url_or_id = @id)
      #! retrieve the children of a block. If the block has no children, return []. If it does, return the instantiated class objects associated with each child.
      #! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)
      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      children_ids = children_ids(url_or_id)
      if !children_ids.empty?
        children_class_instances = []
        children_ids.each { |child| children_class_instances.push(get_block(child)) }
        return children_class_instances
      else
        return []
      end
    end

    def children_ids(url_or_id = @id)
      #! retrieve the children IDs of a block.
      #! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)
      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty?
        if i >= 10
          return {}
        else
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
      end
      if jsonified_record_response["block"][clean_id]["value"]["content"]
        return jsonified_record_response["block"][clean_id]["value"]["content"]
      else
        return []
      end
    end
  end
end
