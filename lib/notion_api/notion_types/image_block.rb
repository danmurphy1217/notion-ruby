module NotionAPI

  # good for visual information
  class ImageBlock < BlockTemplate
    @notion_type = "image"
    @type = "image"

    def type
      NotionAPI::ImageBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end

    private

    def self.create(block_id, new_block_id, block_title, target, position_command, request_ids, options)
      if !(options[:image])
        raise ArgumentError, "Must specify image as an option. For example: .create(\"block type\", \"block title\", options: {image: \"https://image-domain.com\"})"
      else
        cookies = Core.options["cookies"]
        headers = Core.options["headers"]
        if options[:image].match(/^http:\/\/|^https:\/\//)
          create_hash = Utils::BlockComponents.create(new_block_id, self.notion_type)
          set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(block_id, new_block_id)
          block_location_hash = Utils::BlockComponents.block_location_add(block_id, block_id, new_block_id, target, position_command)
          last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(block_id)
          last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(block_id)
          title_hash = Utils::BlockComponents.title(new_block_id, block_title)
          source_url_hash = Utils::BlockComponents.source(new_block_id, options[:image])
          display_source_url_hash = Utils::BlockComponents.display_source(new_block_id, options[:image])

          operations = [
            create_hash,
            set_parent_alive_hash,
            block_location_hash,
            last_edited_time_parent_hash,
            last_edited_time_child_hash,
            title_hash,
            source_url_hash,
            display_source_url_hash,
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
              Please try again, and if issues persist open an issue in GitHub.";           end

          self.new(new_block_id, block_title, block_id)
        else
          raise ArgumentError, "Currently, images can only be created through a public image URL."
        end
      end
    end
  end
end
