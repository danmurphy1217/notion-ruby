
module NotionAPI

    # Page Block, entrypoint for the application
    class PageBlock < BlockTemplate
      @notion_type = 'page'
      @type = 'page'
  
      def type
        NotionAPI::PageBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
  
      def get_block(url_or_id)
        # ! retrieve a Notion Block and return its instantiated class object.
        # ! url_or_id -> the block ID or URL : ``str``
        get(url_or_id)
      end
  
      def get_collection(url_or_id)
        # ! retrieve a Notion Collection and return its instantiated class object.
        # ! url_or_id -> the block ID or URL : ``str``
        clean_id = extract_id(url_or_id)
  
        request_body = {
          pageId: clean_id,
          chunkNumber: 0,
          limit: 100,
          verticalColumns: false
        }
        jsonified_record_response = get_all_block_info(request_body)
        i = 0
        while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
          return {} if i >= 10
  
          jsonified_record_response = get_all_block_info(request_body)
          i += 1
        end
        block_parent_id = extract_parent_id(clean_id, jsonified_record_response)
        block_collection_id = extract_collection_id(clean_id, jsonified_record_response)
        block_view_id = extract_view_ids(clean_id, jsonified_record_response).join
        block_title = extract_collection_title(clean_id, block_collection_id, jsonified_record_response)
  
        CollectionView.new(clean_id, block_title, block_parent_id, block_collection_id, block_view_id)
      end
  
      def create_collection(collection_type, collection_title, data)
        # ! create a Notion Collection View and return its instantiated class object.
        # ! _collection_type -> the type of collection to create : ``str``
        # ! collection_title -> the title of the collection view : ``str``
        # ! data -> JSON data to add to the table : ``str``
  
        valid_types = %w[table board list timeline calendar gallery]
        unless valid_types.include?(collection_type) ; raise ArgumentError, "That collection type is not yet supported. Try: #{valid_types.join}."; end
        cookies = Core.options['cookies']
        headers = Core.options['headers']
  
        new_block_id = extract_id(SecureRandom.hex(16))
        parent_id = extract_id(SecureRandom.hex(16))
        collection_id = extract_id(SecureRandom.hex(16))
        view_id = extract_id(SecureRandom.hex(16))
  
        children = []
        alive_blocks = []
        data.each do |_row|
          child = extract_id(SecureRandom.hex(16))
          children.push(child)
          alive_blocks.push(Utils::CollectionViewComponents.set_collection_blocks_alive(child, collection_id))
        end
  
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
  
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
  
        create_collection_view = Utils::CollectionViewComponents.create_collection_view(new_block_id, collection_id, view_id)
        configure_view = Utils::CollectionViewComponents.set_view_config(collection_type, new_block_id, view_id, children)
        
        # returns the JSON and some useful column mappings...
        column_data = Utils::CollectionViewComponents.set_collection_columns(collection_id, new_block_id, data)
        configure_columns_hash = column_data[0]
        column_mappings = column_data[1]
        set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(@id, new_block_id)
        add_block_hash = Utils::BlockComponents.block_location_add(@id, @id, new_block_id, nil, 'listAfter')
        new_block_edited_time = Utils::BlockComponents.last_edited_time(new_block_id)
        collection_title_hash = Utils::CollectionViewComponents.set_collection_title(collection_title, collection_id)
  
        operations = [
          create_collection_view,
          configure_view,
          configure_columns_hash,
          set_parent_alive_hash,
          add_block_hash,
          new_block_edited_time,
          collection_title_hash
        ]
        operations << alive_blocks
        all_ops = operations.flatten
        data.each_with_index do |row, i|
          child = children[i]
          row.keys.each_with_index do |col_name, j|
            child_component = Utils::CollectionViewComponents.insert_data(child, j.zero? ? 'title' : col_name, row[col_name], column_mappings[j])
            all_ops.push(child_component)
          end
        end
  
        request_url = URLS[:UPDATE_BLOCK]
        request_body = build_payload(all_ops, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
  
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub."; end
  
        CollectionView.new(new_block_id, collection_title, parent_id, collection_id, view_id)
      end
    end
end