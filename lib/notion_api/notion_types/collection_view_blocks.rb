module NotionAPI
    # collection views such as tables and timelines.
    class CollectionView < Core
      attr_reader :id, :title, :parent_id, :collection_id, :view_id
  
      @notion_type = 'collection_view'
      @type = 'collection_view'
  
      def type
        NotionAPI::CollectionView.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
  
      def initialize(id, title, parent_id, collection_id, view_id)
        @id = id
        @title = title
        @parent_id = parent_id
        @collection_id = collection_id
        @view_id = view_id
      end
  
      def add_row(data)
        # ! add new row to Collection View table.
        # ! data -> data to add to table : ``hash``
  
        cookies = Core.options['cookies']
        headers = Core.options['headers']
  
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
        new_block_id = extract_id(SecureRandom.hex(16))
        schema = extract_collection_schema(@collection_id, @view_id)
        keys = schema.keys
        col_map = {}
        keys.map { |key| col_map[schema[key]['name']]  = key }
  
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
  
        instantiate_row = Utils::CollectionViewComponents.add_new_row(new_block_id)
        set_block_alive = Utils::CollectionViewComponents.set_collection_blocks_alive(new_block_id, @collection_id)
        new_block_edited_time = Utils::BlockComponents.last_edited_time(new_block_id)
        parent_edited_time = Utils::BlockComponents.last_edited_time(@parent_id)
  
        operations = [
          instantiate_row,
          set_block_alive,
          new_block_edited_time,
          parent_edited_time
        ]
  
        data.keys.each_with_index do |col_name, j|
          child_component = Utils::CollectionViewComponents.insert_data(new_block_id, j.zero? ? 'title' : col_map[col_name], data[col_name], j.zero? ? schema['title']["type"] : schema[col_map[col_name]]['type'])
          operations.push(child_component)
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
  
           NotionAPI::CollectionViewRow.new(new_block_id, @parent_id, @collection_id, @view_id)
      end
  
      def add_property(name, type)
        # ! add a property (column) to the table.
        # ! name -> name of the property : ``str``
        # ! type -> type of the property : ``str``
        cookies = Core.options['cookies']
        headers = Core.options['headers']
  
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
  
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }
  
        # create updated schema
        schema = extract_collection_schema(@collection_id, @view_id)
        schema[name] = {
          name: name,
          type: type
        }
        new_schema = {
          schema: schema
        }
  
        add_collection_property = Utils::CollectionViewComponents.add_collection_property(@collection_id, new_schema)
  
        operations = [
          add_collection_property
        ]
  
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
  
        true
      end
  
      def row(row_id)
        # ! retrieve a row from a CollectionView Table.
        # ! row_id -> the ID for the row to retrieve: ``str``
        clean_id = extract_id(row_id)
  
        request_body = {
          pageId: clean_id,
          chunkNumber: 0,
          limit: 100,
          verticalColumns: false
        }
        jsonified_record_response = get_all_block_info(clean_id, request_body)
        schema = extract_collection_schema(@collection_id, @view_id)
        keys = schema.keys
        column_names = keys.map { |key| schema[key]['name'] }
        i = 0
        while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
          return {} if i >= 10
  
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
        row_jsonified_response = jsonified_record_response['block'][clean_id]['value']['properties']
        row_data = {}
        keys.each_with_index { |key, idx| row_data[column_names[idx]] = row_jsonified_response[key] ? row_jsonified_response[key].flatten : [] }
        row_data
      end
  
      def row_ids
        # ! retrieve all Collection View table rows.
        clean_id = extract_id(@id)
  
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
  
        jsonified_record_response['collection_view'][@view_id]['value']['page_sort']
      end
  
      def rows
        # ! returns all rows as instantiated class instances.
        row_id_array = row_ids
        parent_id = @parent_id
        collection_id = @collection_id
        view_id = @view_id
  
        row_id_array.map { |row_id| NotionAPI::CollectionViewRow.new(row_id, parent_id, collection_id, view_id) }
      end
  
      private
  
      def extract_collection_schema(collection_id, view_id)
        # ! retrieve the collection scehma. Useful for 'building' the backbone for a table.
        # ! collection_id -> the collection ID : ``str``
        # ! view_id -> the view ID : ``str``
        cookies = Core.options['cookies']
        headers = Core.options['headers']
  
        query_collection_hash = Utils::CollectionViewComponents.query_collection(collection_id, view_id, '')
  
        request_url = URLS[:GET_COLLECTION]
        response = HTTParty.post(
          request_url,
          body: query_collection_hash.to_json,
          cookies: cookies,
          headers: headers
        )
        response['recordMap']['collection'][collection_id]['value']['schema']
      end
    end
    class CollectionViewRow < Core
      @notion_type = 'table_row'
      @type = 'table_row'
  
      def type
        NotionAPI::CollectionViewRow.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type, :parent_id
      end
  
      attr_reader :parent_id, :id
      def initialize(id, parent_id, collection_id, view_id)
        @id = id
        @parent_id = parent_id
        @collection_id = collection_id
        @view_id = view_id
      end
    end
end