require_relative "types"
require_relative "utils"
require "httparty"

module Notion
  class Block
    include Utils

    @@method_urls = URLS # defined in Utils
    attr_reader :token_v2, :clean_id, :cookies, :headers

    def get_all_block_info(clean_id, body, options = {})
      cookies = !options["cookies"].nil? ? options["cookies"] : { :token_v2.to_s => token_v2 }
      headers = !options["headers"].nil? ? options["headers"] : { "Content-Type" => "application/json" }
      request_url = @@method_urls[:GET_BLOCK]

      response = HTTParty.post(
        request_url,
        :body => body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      jsonified_record_response = JSON.parse(response.body)["recordMap"]

      return jsonified_record_response
    end
    def filter_nil_blocks(jsonified_record_response)
      return jsonified_record_response["block"].empty? ? nil : jsonified_record_response["block"]
    end

    def extract_title(clean_id, jsonified_record_response)
      # extract title from core JSON response body.
      filter_nil_blocks =  filter_nil_blocks(jsonified_record_response)
      if filter_nil_blocks.nil?
        return nil
      else
        filter_nil_titles = filter_nil_blocks[clean_id]["value"]["properties"].nil? ? nil : jsonified_record_response["block"][clean_id]["value"]["properties"]["title"].flatten.join(" ")
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
      return !jsonified_record_response.empty? ? jsonified_record_response["block"][clean_id]["value"]["parent_id"] : {}
    end
    def extract_id(url_or_id)
      begin
        if (url_or_id.length == 36) or (url_or_id.split("-").length == 5)
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

    def get_block(url_or_id, options = {})
      # retrieve the title, type, and ID of a block
      clean_id = extract_id(url_or_id)

      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body, options)
      i = 0
      while jsonified_record_response.empty?
        if i >= 20
          return {}
        else
          jsonified_record_response = get_all_block_info(clean_id, request_body, options)
          i += 1
        end
      end
      block_id = clean_id
      #TODO: figure out how to best translate notions markdown formatting into plaintext for content delivery.
      # p jsonified_record_response["block"][clean_id]
      block_title = extract_title(clean_id, jsonified_record_response)
      block_parent_id = extract_parent_id(clean_id, jsonified_record_response)
      block_type = extract_type(clean_id, jsonified_record_response)
      block_class = Notion.const_get(BLOCK_TYPES[block_type].to_s)
      return block_class.new(block_type, block_id, block_title, block_parent_id, options)
    end

    def get_block_children_ids(url_or_id, options = {})
      clean_id = extract_id(url_or_id)
      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body, options)
      children_ids = extract_children_ids(clean_id, jsonified_record_response)
      return children_ids
    end
    def check_id_length(id)
      if id.length != 32
        return false
      end
      return true
    end
  end
end
