require_relative '../core'
require 'httparty'

module NotionAPI
    # Base Template for all blocks. Inherits core methods from the Block class defined in block.rb
    class BlockTemplate < Core
      include Utils
  
      attr_reader :id, :title, :parent_id
  
      def initialize(id, title, parent_id)
        @id = id
        @title = title
        @parent_id = parent_id
      end
  
      def title=(new_title)
        # ! Change the title of a block.
        # ! new_title -> new title for the block : ``str``
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
        update_title(new_title.to_s, request_id, transaction_id, space_id)
        @title = new_title
      end
  
      def convert(block_class_to_convert_to)
        # ! convert a block from its current type to another.
        # ! block_class_to_convert_to -> the type of block to convert to : ``cls``
        if type == block_class_to_convert_to.notion_type
          # if converting to same type, skip and return self
          self
        else
          # setup cookies, headers, and grab/create static vars for request
          cookies = Core.options['cookies']
          headers = Core.options['headers']
          request_url = URLS[:UPDATE_BLOCK]
  
          # set random IDs for request
          request_id = extract_id(SecureRandom.hex(16))
          transaction_id = extract_id(SecureRandom.hex(16))
          space_id = extract_id(SecureRandom.hex(16))
          request_ids = {
            request_id: request_id,
            transaction_id: transaction_id,
            space_id: space_id
          }
  
          # build hash's that contain the operations to send to Notions backend
          convert_type_hash = Utils::BlockComponents.convert_type(@id, block_class_to_convert_to)
          last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)
          last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
  
          operations = [
            convert_type_hash,
            last_edited_time_parent_hash,
            last_edited_time_child_hash
          ]
  
          request_body = build_payload(operations, request_ids)
          response = HTTParty.post(
            request_url,
            body: request_body.to_json,
            cookies: cookies,
            headers: headers
          )
          unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
             Please try again, and if issues persist open an issue in GitHub."; end
  
          block_class_to_convert_to.new(@id, @title, @parent_id)
  
        end
      end
  
      def duplicate(target_block = nil)
        # ! duplicate the block that this method is invoked upon.
        # ! target_block -> the block to place the duplicated block after. Can be any valid Block ID! : ``str``
        cookies = Core.options['cookies']
        headers = Core.options['headers']
        request_url = URLS[:UPDATE_BLOCK]
  
        new_block_id = extract_id(SecureRandom.hex(16))
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
  
        root_children = children_ids(@id)
        sub_children = []
        root_children.each { |root_id| sub_children.push(children_ids(root_id)) }
  
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
        body = {
          pageId: @id,
          chunkNumber: 0,
          limit: 100,
          verticalColumns: false
        }
  
        user_notion_id = get_notion_id(body)
  
        block = target_block ? get(target_block) : self # allows dev to place block anywhere!

        props_and_formatting = get_block_props_and_format(@id, @title)
        props = props_and_formatting[:properties]
        formats = props_and_formatting[:format]
        duplicate_hash = Utils::BlockComponents.duplicate(type, @title, block.id, new_block_id, user_notion_id, root_children, props, formats)
        set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(block.parent_id, new_block_id)
        block_location_hash = Utils::BlockComponents.block_location_add(block.parent_id, block.id, new_block_id, target_block, 'listAfter')
        last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(block.parent_id)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(block.id)
  
        operations = [
          duplicate_hash,
          set_parent_alive_hash,
          block_location_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash
        ]
  
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub."; end
  
        class_to_return = NotionAPI.const_get(Classes.select { |cls| NotionAPI.const_get(cls).notion_type == type }.join.to_s)
        class_to_return.new(new_block_id, @title, block.parent_id)
      end
  
      def move(target_block, position = 'after')
        # ! move the block to a new location.
        # ! target_block -> the targetted block to move to. : ``str``
        # ! position -> where the block should be listed, in positions relative to the target_block [before, after, top-child, last-child]
        positions_hash = {
          'after' => 'listAfter',
          'before' => 'listBefore'
        }
  
        unless positions_hash.keys.include?(position); raise ArgumentError, "Invalid position. You said: #{position}, valid options are: #{positions_hash.keys.join(', ')}"; end
  
        position_command = positions_hash[position]
        cookies = Core.options['cookies']
        headers = Core.options['headers']
        request_url = URLS[:UPDATE_BLOCK]
  
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
  
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
  
        check_parents = (@parent_id == target_block.parent_id)
        set_block_dead_hash = Utils::BlockComponents.set_block_to_dead(@id) # kill the block this method is invoked on...
        block_location_remove_hash = Utils::BlockComponents.block_location_remove(@parent_id, @id) # remove the block this method is invoked on...
        parent_location_hash = Utils::BlockComponents.parent_location_add(check_parents ? @parent_id : target_block.parent_id, @id) # set parent location to alive
        block_location_add_hash = Utils::BlockComponents.block_location_add(check_parents ? @parent_id : target_block.parent_id, @id, target_block.id, position_command)
        last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)
  
        if check_parents
          last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
          operations = [
            set_block_dead_hash,
            block_location_remove_hash,
            parent_location_hash,
            block_location_add_hash,
            last_edited_time_parent_hash,
            last_edited_time_child_hash
          ]
        else
          last_edited_time_new_parent_hash = Utils::BlockComponents.last_edited_time(target_block.parent_id)
          last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
          @parent_id = target_block.parent_id
          operations = [
            set_block_dead_hash,
            block_location_remove_hash,
            parent_location_hash,
            block_location_add_hash,
            last_edited_time_parent_hash,
            last_edited_time_new_parent_hash,
            last_edited_time_child_hash
          ]
        end
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub."; end
  
        self
      end
  
      def create(block_type, block_title, target = nil, position = 'after')
        # ! create a new block
        # ! block_type -> the type of block to create : ``cls``
        # ! block_title -> the title of the new block : ``str``
        # ! target -> the block_id that the new block should be placed after. ``str`` 
        # ! position -> 'after' or 'before'
        positions_hash = {
          'after' => 'listAfter',
          'before' => 'listBefore'
        }
        unless positions_hash.keys.include?(position); raise "Invalid position. You said: #{position}, valid options are: #{positions_hash.keys.join(', ')}"; end
  
        position_command = positions_hash[position]
        blocks_with_emojis = [NotionAPI::PageBlock, NotionAPI::CalloutBlock]
  
        cookies = Core.options['cookies']
        headers = Core.options['headers']
  
        new_block_id = extract_id(SecureRandom.hex(16))
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
  
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
  
        create_hash = Utils::BlockComponents.create(new_block_id, block_type.notion_type)
        set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(@id, new_block_id)
        block_location_hash = Utils::BlockComponents.block_location_add(@id, @id, new_block_id, target, position_command)
        last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@id)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
        title_hash = Utils::BlockComponents.title(new_block_id, block_title)

        operations = [
          create_hash,
          set_parent_alive_hash,
          block_location_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash,
          title_hash
        ]

        if blocks_with_emojis.include?(block_type)
          emoji_choices = ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "😀", "😃"]
          emoji = emoji_choices[rand(0...emoji_choices.length)]
          emoji_icon_hash = Utils::BlockComponents.add_emoji_icon(new_block_id, emoji)
          operations.push(emoji_icon_hash)
        end
  
  
        request_url = URLS[:UPDATE_BLOCK]
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub."; end
  
        block_type.new(new_block_id, block_title, @id)
      end
  
      private
  
      def get(url_or_id)
        # ! retrieve a Notion Block and return its instantiated class object.
        # ! url_or_id -> the block ID or URL : ``str``
        clean_id = extract_id(url_or_id)
  
        request_body = {
          pageId: clean_id,
          chunkNumber: 0,
          limit: 100,
          verticalColumns: false
        }
        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i = 0
        while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
          return {} if i >= 10
  
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
        block_type = extract_type(clean_id, jsonified_record_response)
        block_parent_id = extract_parent_id(clean_id, jsonified_record_response)
  
        if block_type.nil?
          {}
        else
          block_class = NotionAPI.const_get(BLOCK_TYPES[block_type].to_s)
          if block_class == NotionAPI::CollectionView
            block_collection_id = extract_collection_id(clean_id, jsonified_record_response)
            block_view_id = extract_view_ids(clean_id, jsonified_record_response)
            collection_title = extract_collection_title(clean_id, block_collection_id, jsonified_record_response)
            block_class.new(clean_id, collection_title, block_parent_id, block_collection_id, block_view_id.join)
          else
            block_title = extract_title(clean_id, jsonified_record_response)
            block_class.new(clean_id, block_title, block_parent_id)
          end
        end
      end
  
      def update_title(new_title, request_id, transaction_id, space_id)
        # ! Helper method for sending POST request to change title of block.
        # ! new_title -> new title for the block : ``str``
        # ! request_id -> the unique ID for the request key. Generated using SecureRandom : ``str``
        # ! transaction_id -> the unique ID for the transaction key. Generated using SecureRandom: ``str``
        # ! transaction_id -> the unique ID for the space key. Generated using SecureRandom: ``str``
        # setup cookies, headers, and grab/create static vars for request
        cookies = Core.options['cookies']
        headers = Core.options['headers']
        request_url = URLS[:UPDATE_BLOCK]
  
        # set unique IDs for request
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
  
        # build and set operations to send to Notion
        title_hash = Utils::BlockComponents.title(@id, new_title)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
        operations = [
          title_hash,
          last_edited_time_child_hash
        ]
  
        request_body = build_payload(operations, request_ids) # defined in utils.rb
  
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
        response.body
      end
    end
end