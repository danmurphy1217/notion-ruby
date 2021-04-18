# frozen_string_literal: true

require_relative "utils"
require "httparty"

module NotionAPI
  # the initial methods available to an instantiated Cloent object are defined
  class Core
    include Utils
    @options = { "cookies" => { :token_v2 => nil, "x-active-user-header" => nil }, "headers" => { "Content-Type" => "application/json" } }
    @type_whitelist = "divider"

    class << self
      attr_reader :options, :type_whitelist, :token_v2, :active_user_header
    end

    attr_reader :clean_id, :cookies, :headers

    def initialize(token_v2, active_user_header)
      @@token_v2 = token_v2
      @@active_user_header = active_user_header
    end

    def get_page(url_or_id)
      # ! retrieve a Notion Page Block and return its instantiated class object.
      # ! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)

      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false,
      }
      jsonified_record_response = get_all_block_info(request_body)

      block_type = extract_type(clean_id, jsonified_record_response)
      block_parent_id = extract_parent_id(clean_id, jsonified_record_response)

      raise ArgumentError, "the URL or ID passed to the get_page method must be that of a Page Block." if !["collection_view_page", "page"].include?(block_type)

      get_instantiated_instance_for(url_or_id, block_type, clean_id, block_parent_id, jsonified_record_response)
    end

    def children(url_or_id = @id)
      # ! retrieve the children of a block. If the block has no children, return []. If it does, return the instantiated class objects associated with each child.
      # ! url_or_id -> the block ID or URL : ``str``

      children_ids = children_ids(url_or_id)
      if children_ids.empty?
        []
      else
        children_class_instances = []
        children_ids.each { |child| children_class_instances.push(get(child)) }
        children_class_instances
      end
    end

    def children_ids(url_or_id = @id)
      # ! retrieve the children IDs of a block.
      # ! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)
      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false,
      }
      jsonified_record_response = get_all_block_info(request_body)

      # if no content, returns empty list
      jsonified_record_response["block"][clean_id]["value"]["content"] || []
    end

    def extract_id(url_or_id)
      # ! parse and clean the URL or ID object provided.
      # ! url_or_id -> the block ID or URL : ``str``
      http_or_https = url_or_id.match(/^(http|https)/) # true if http or https in url_or_id...
      collection_view_match = url_or_id.match(/(\?v=)/)

      if (url_or_id.length == 36) && ((url_or_id.split("-").length == 5) && !http_or_https)
        # passes if url_or_id is perfectly formatted already...
        url_or_id
      elsif (http_or_https && (url_or_id.split("-").last.length == 32)) || (!http_or_https && (url_or_id.length == 32)) || (collection_view_match)
        # passes if either:
        # 1. a URL is passed as url_or_id and the ID at the end is 32 characters long or
        # 2. a URL is not passed and the ID length is 32 [aka unformatted]
        pattern = [8, 13, 18, 23]
        if collection_view_match
          id_without_view = url_or_id.split("?")[0]
          clean_id = id_without_view.split("/").last
          pattern.each { |index| clean_id.insert(index, "-") }
          clean_id
        else
          id = url_or_id.split("-").last
          pattern.each { |index| id.insert(index, "-") }
          id
        end
      else
        raise ArgumentError, "Expected a Notion page URL or a page ID. Please consult the documentation for further information."
      end
    end

    private

    def get_notion_id(body)
      # ! retrieves a users ID from the headers of a Notion response object.
      # ! body -> the body to send in the request : ``Hash``
      Core.options["cookies"][:token_v2] = @@token_v2
      Core.options["headers"]["x-notion-active-user-header"] = @@active_user_header
      cookies = Core.options["cookies"]
      headers = Core.options["headers"]
      request_url = URLS[:GET_BLOCK]

      response = HTTParty.post(
        request_url,
        body: body.to_json,
        cookies: cookies,
        headers: headers,
      )
      response.headers["x-notion-user-id"]
    end

    def get_last_page_block_id(url_or_id)
      # ! retrieve and return the last child ID of a block.
      # ! url_or_id -> the block ID or URL : ``str``
      children_ids(url_or_id).empty? ? [] : children_ids(url_or_id)[-1]
    end

    def get_block_props_and_format(clean_id, block_title)
      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false,
      }
      jsonified_record_response = get_all_block_info(request_body)

      properties = jsonified_record_response["block"][clean_id]["value"]["properties"]
      formats = jsonified_record_response["block"][clean_id]["value"]["format"]
      return {
               :properties => properties,
               :format => formats,
             }
    end

    def get_all_block_info(body, i = 0)
      # ! retrieves all info pertaining to a block Id.
      # ! clean_id -> the block ID or URL cleaned : ``str``
      Core.options["cookies"][:token_v2] = @@token_v2
      Core.options["headers"]["x-notion-active-user-header"] = @@active_user_header
      cookies = Core.options["cookies"]
      headers = Core.options["headers"]
      request_url = URLS[:GET_BLOCK]

      response = HTTParty.post(
        request_url,
        body: body.to_json,
        cookies: cookies,
        headers: headers,
      )

      jsonified_record_response = JSON.parse(response.body)["recordMap"]
      response_invalid = (!jsonified_record_response || jsonified_record_response.empty? || jsonified_record_response["block"].empty?)

      if i < 10 && response_invalid
        i = i + 1
        return get_all_block_info(body, i)
      else
        if i == 10 && response_invalid
          raise InvalidClientInstantiationError, "Attempted to retrieve block 10 times and received an empty response each time. Please make sure you have a valid token_v2 value set. If you do, then try setting the 'active_user_header' variable as well."
        else
          return jsonified_record_response
        end
      end
    end

    def filter_nil_blocks(jsonified_record_response)
      # ! removes any blocks that are empty [i.e. have no title / content]
      # ! jsonified_record_responses -> parsed JSON representation of a notion response object : ``Json``
      jsonified_record_response.empty? || jsonified_record_response["block"].empty? ? nil : jsonified_record_response["block"]
    end

    def extract_title(clean_id, jsonified_record_response)
      # ! extract title from core JSON Notion response object.
      # ! clean_id -> the cleaned block ID: ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      filter_nil_blocks = filter_nil_blocks(jsonified_record_response)
      if filter_nil_blocks.nil? || filter_nil_blocks[clean_id].nil? || filter_nil_blocks[clean_id]["value"]["properties"].nil?
        nil
      else
        # titles for images are called source, while titles for text-based blocks are called title, so lets dynamically grab it
        # https://stackoverflow.com/questions/23765996/get-all-keys-from-ruby-hash/23766007
        title_value = filter_nil_blocks[clean_id]["value"]["properties"].keys[0]
        Core.type_whitelist.include?(filter_nil_blocks[clean_id]["value"]["type"]) ? nil : jsonified_record_response["block"][clean_id]["value"]["properties"][title_value].flatten[0]
      end
    end

    def extract_collection_title(_clean_id, collection_id, jsonified_record_response)
      # ! extract title from core JSON Notion response object.
      # ! clean_id -> the cleaned block ID: ``str``
      # ! collection_id -> the collection ID: ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      jsonified_record_response["collection"][collection_id]["value"]["name"].flatten.join if jsonified_record_response["collection"] and jsonified_record_response["collection"][collection_id]["value"]["name"]
    end

    def extract_type(clean_id, jsonified_record_response)
      # ! extract type from core JSON response object.
      # ! clean_id -> the block ID or URL cleaned : ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      filter_nil_blocks = filter_nil_blocks(jsonified_record_response)
      if filter_nil_blocks.nil?
        nil
      else
        filter_nil_blocks[clean_id]["value"]["type"]
      end
    end

    def extract_parent_id(clean_id, jsonified_record_response)
      # ! extract parent ID from core JSON response object.
      # ! clean_id -> the block ID or URL cleaned : ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      jsonified_record_response.empty? || jsonified_record_response["block"].empty? ? {} : jsonified_record_response["block"][clean_id]["value"]["parent_id"]
    end

    def extract_collection_id(clean_id, jsonified_record_response)
      # ! extract the collection ID
      # ! clean_id -> the block ID or URL cleaned : ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      jsonified_record_response["block"][clean_id]["value"]["collection_id"]
    end

    def extract_view_ids(clean_id, jsonified_record_response)
      jsonified_record_response["block"][clean_id]["value"]["view_ids"] || []
    end

    def extract_view_id(url_or_id, clean_id, jsonified_record_response)
      # ! extract the view ID
      # ! clean_id -> the block ID or URL cleaned : ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      collection_view_match = /^https?:\/\/www.notion.so\/(.+\/)?(?<id>.+)\?v=(?<view_id>.+)$/i.match(url_or_id)
      view_ids = extract_view_ids(clean_id, jsonified_record_response)
      view_id = view_ids[0]

      if collection_view_match && collection_view_match[:id] && collection_view_match[:view_id]
        clean_match_id = extract_id(collection_view_match[:id])
        clean_match_view_id = extract_id(collection_view_match[:view_id])

        if clean_id == clean_match_id && view_ids.include?(clean_match_view_id)
          view_id = clean_match_view_id
        end
      end

      view_id
    end

    def extract_query(view_id, schema, jsonified_record_response)
      # ! extract the query
      # ! view_id -> the view ID : ``str``
      # ! jsonified_record_response -> parsed JSON representation of a notion response object : ``Json``
      query = jsonified_record_response["collection_view"][view_id]["value"]["query2"] || {}
      return query unless query.dig("filter", "filters")

      properties = schema.keys
      query["filter"]["filters"] = query.dig("filter", "filters").filter do |filter|
        properties.include?(filter["property"])
      end

      query
    end

    # def extract_id(url_or_id)
    #   # ! parse and clean the URL or ID object provided.
    #   # ! url_or_id -> the block ID or URL : ``str``
    #   http_or_https = url_or_id.match(/^(http|https)/) # true if http or https in url_or_id...
    #   collection_view_match = url_or_id.match(/(\?v=)/)

    #   if (url_or_id.length == 36) && ((url_or_id.split("-").length == 5) && !http_or_https)
    #     # passes if url_or_id is perfectly formatted already...
    #     url_or_id
    #   elsif (http_or_https && (url_or_id.split("-").last.length == 32)) || (!http_or_https && (url_or_id.length == 32)) || (collection_view_match)
    #     # passes if either:
    #     # 1. a URL is passed as url_or_id and the ID at the end is 32 characters long or
    #     # 2. a URL is not passed and the ID length is 32 [aka unformatted]
    #     pattern = [8, 13, 18, 23]
    #     if collection_view_match
    #       id_without_view = url_or_id.split("?")[0]
    #       clean_id = id_without_view.split("/").last
    #       pattern.each { |index| clean_id.insert(index, "-") }
    #       clean_id
    #     else
    #       id = url_or_id.split("-").last
    #       pattern.each { |index| id.insert(index, "-") }
    #       id
    #     end
    #   else
    #     raise ArgumentError, "Expected a Notion page URL or a page ID. Please consult the documentation for further information."
    #   end
    # end

    def query_collection(collection_id, view_id, options: {})
      # ! retrieve the collection scehma. Useful for 'building' the backbone for a table.
      # ! collection_id -> the collection ID : ``str``
      # ! view_id -> the view ID : ``str``
      request_body = Utils::CollectionViewComponents.query_collection_body(
        collection_id, view_id, options: options
      )

      request_url = URLS[:GET_COLLECTION]
      cookies = Core.options["cookies"]
      headers = Core.options["headers"]

      HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers,
      )
    end

    def extract_collection_schema(collection_id, view_id, response = {})
      # ! retrieve the collection schema. Useful for 'building' the backbone for a table.
      # ! collection_id -> the collection ID : ``str``
      # ! view_id -> the view ID : ``str``
      if response.empty?
        response = query_collection(collection_id, view_id)
        response["recordMap"]["collection"][collection_id]["value"]["schema"]
      else
        response["collection"][collection_id]["value"]["schema"]
      end
    end

    def extract_collection_data(collection_id, view_id)
      # ! retrieve the collection schema. Useful for 'building' the backbone for a table.
      # ! collection_id -> the collection ID : ``str``
      # ! view_id -> the view ID : ``str``
      response = query_collection(collection_id, view_id)

      response["recordMap"]
    end

    def extract_page_information(page_meta = {})
      # ! helper method for extracting information about a page block
      # ! page_meta -> hash containing data points useful for the extraction of a page blocks information.
      # !           This should include clean_id, jsonified_record_response, and parent_id
      clean_id = page_meta.fetch(:clean_id)
      jsonified_record_response = page_meta.fetch(:jsonified_record_response)
      block_parent_id = page_meta.fetch(:parent_id)

      block_title = extract_title(clean_id, jsonified_record_response)
      PageBlock.new(clean_id, block_title, block_parent_id)
    end

    def extract_collection_view_page_information(page_meta = {})
      # ! helper method for extracting information about a Collection View page block
      # ! page_meta -> hash containing data points useful for the extraction of a page blocks information.
      # !           This should include clean_id, jsonified_record_response, and parent_id
      url_or_id = page_meta.fetch(:url_or_id)
      clean_id = page_meta.fetch(:clean_id)
      jsonified_record_response = page_meta.fetch(:jsonified_record_response)
      block_parent_id = page_meta.fetch(:parent_id)

      collection_id = extract_collection_id(clean_id, jsonified_record_response)
      block_title = extract_collection_title(clean_id, collection_id, jsonified_record_response)
      view_id = extract_view_id(url_or_id, clean_id, jsonified_record_response)
      schema = extract_collection_schema(collection_id, view_id, jsonified_record_response)
      query = extract_query(view_id, schema, jsonified_record_response)
      column_names = NotionAPI::CollectionView.extract_collection_view_column_names(schema)

      collection_view_page = CollectionViewPage.new(clean_id, block_title, block_parent_id, collection_id, view_id, query)
      collection_view_page.instance_variable_set(:@column_names, column_names)
      CollectionView.class_eval { attr_reader :column_names }
      collection_view_page
    end

    def get_instantiated_instance_for(url_or_id, block_type, clean_id, parent_id, jsonified_record_response)
      case block_type
      when "page" then extract_page_information(clean_id: clean_id, parent_id: parent_id, jsonified_record_response: jsonified_record_response)
      when "collection_view_page" then extract_collection_view_page_information(url_or_id: url_or_id, clean_id: clean_id, parent_id: parent_id, jsonified_record_response: jsonified_record_response)
      end
    end

    class InvalidClientInstantiationError < StandardError
      def initialize(msg = "Custom exception that is raised when an invalid property type is passed as a mapping.", exception_type = "instantiation_type")
        @exception_type = exception_type
        super(msg)
      end
    end
  end
end
