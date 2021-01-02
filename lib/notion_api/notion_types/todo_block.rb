module NotionAPI

  # To-Do block: best for checklists and tracking to-dos.
  class TodoBlock < BlockTemplate
    @notion_type = "to_do"
    @type = "to_do"

    def type
      NotionAPI::TodoBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end

    def checked=(checked_value)
      # ! change the checked property of the Todo Block.
      # ! checked_value -> boolean value used to determine whether the block should be checked [yes] or not [no] : ``str``
      # set static variables for request
      cookies = Core.options["cookies"]
      headers = Core.options["headers"]
      request_url = URLS[:UPDATE_BLOCK]

      # set unique values for request
      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))
      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id,
      }

      if %w[yes no].include?(checked_value.downcase)
        checked_hash = Utils::BlockComponents.checked_todo(@id, checked_value.downcase)
        last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)

        operations = [
          checked_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash,
        ]
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers,
        )
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
             Please try again, and if issues persist open an issue in GitHub.";         end

        true
      else
        false
      end
    end
  end
end
