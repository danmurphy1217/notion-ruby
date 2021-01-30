module NotionAPI

    # simiilar to code block but for mathematical functions.
    class LinkBlock < BlockTemplate
      @notion_type = "link_to_page"
      @type = "link_to_page"
  
      def type
        NotionAPI::LinkBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end

      def self.create(block_id, new_block_id, block_title, target, position_command, request_ids, options)
        block_title = super.extract_id(block_title)

        cookies = Core.options["cookies"]
        headers = Core.options["headers"]
  
        create_block_hash = Utils::BlockComponents.create(new_block_id, self.notion_type)
        block_location_hash = Utils::BlockComponents.block_location_add(block_id, block_id, block_title, new_block_id, position_command)
        last_edited_time_hash = Utils::BlockComponents.last_edited_time(block_id)
        remove_item_hash = Utils::BlockComponents.block_location_remove( super.parent_id, new_block_id)
  
        operations = [
          create_block_hash,
          block_location_hash,
          last_edited_time_hash,
          remove_item_hash
        ]
  
        request_url = URLS[:UPDATE_BLOCK]
        request_body = Utils::BlockComponents.build_payload(operations, request_ids)
        
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers,
        )

        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
             Please try again, and if issues persist open an issue in GitHub.";       end
  
        self.new(new_block_id, block_title, block_id)
      end
    end
  end
  