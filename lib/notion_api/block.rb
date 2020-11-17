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
      return get_block_children_ids(url_or_id).empty? ? [] : get_block_children_ids(url_or_id)[-1]
    end

    def get_all_block_info(clean_id, body)
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

      p response.headers["x-notion-user-id"], "YOOO"

      headers["x-notion-active-user-header"] = "b22f2670-a643-49e1-bc49-05e8763f92e4"

      res_two = HTTParty.post(
      "https://www.notion.so/api/v3/loadUserContent",
        :body => {:platform => "web"}.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      p res_two.headers["x-notion-user-id"], "YERRR"
      jsonified_record_response = JSON.parse(response.body)["recordMap"]
      return jsonified_record_response
    end

    def filter_nil_blocks(jsonified_record_response)
      return jsonified_record_response["block"].empty? ? nil : jsonified_record_response["block"]
    end

    def extract_title(clean_id, jsonified_record_response)
      # extract title from core JSON response body.
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
      filter_nil_blocks = filter_nil_blocks(jsonified_record_response)
      if filter_nil_blocks.nil?
        return nil
      else
        block_type = filter_nil_blocks[clean_id]["value"]["type"]
        return block_type
      end
    end

    def extract_children_ids(clean_id, jsonified_record_response)
      return !jsonified_record_response.empty? ? jsonified_record_response["block"][clean_id]["value"]["content"] : {}
    end

    def extract_parent_id(clean_id, jsonified_record_response)
      return !jsonified_record_response["block"].empty? ? jsonified_record_response["block"][clean_id]["value"]["parent_id"] : {}
    end

    def extract_id(url_or_id)
      begin
        if (url_or_id.length == 36) or (url_or_id.split("-").length == 5 and !url_or_id.match(/^(http|https)/))
          return url_or_id
        else
          pattern = [8, 13, 18, 23]
          id = url_or_id.split("-").last
          pattern.each { |index| id.insert(index, "-") }
          return id
        end
      rescue
        raise "Expected a full page URL or a page ID. Please consult the documentation for further information."
      end
    end

    def get_block(url_or_id)
      # retrieve the title, type, and ID of a block
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
      # else
        # TODO: gotta fix this to find a way to check if the "page" is the top-level block.
        # $LOGGER.warn("Root block of page should be treated as parent ID.")
        # Notion::PageBlock.new(block_type, block_id, block_title, block_id, self.token_v2)
      # end
    end
    def get_block_children(url_or_id = @id)
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
        if i >= 20
          return {}
        else
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
      end
      if jsonified_record_response["block"][clean_id]["value"]["content"]
        children_ids = jsonified_record_response["block"][clean_id]["value"]["content"]
        children_class_instances = []
        children_ids.each {|child| children_class_instances.push(get_block(child))}
        return children_class_instances
      else
        return []
      end
    end

    def get_block_children_ids(url_or_id = @id)
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
        if i >= 20
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

    def check_id_length(id)
      if id.length != 32
        return false
      end
      return true
    end
  end
end
