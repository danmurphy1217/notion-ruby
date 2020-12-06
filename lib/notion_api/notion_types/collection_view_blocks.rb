module NotionAPI
  # collection views such as tables and timelines.
  class CollectionView < Core
    attr_reader :id, :title, :parent_id, :collection_id, :view_id

    @notion_type = "collection_view"
    @type = "collection_view"

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

      cookies = Core.options["cookies"]
      headers = Core.options["headers"]

      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))
      new_block_id = extract_id(SecureRandom.hex(16))
      collection_data = extract_collection_data(collection_id, view_id)
      last_row_id = collection_data["collection_view"][@view_id]["value"]["page_sort"][-1]
      schema = collection_data['collection'][collection_id]['value']['schema']
      keys = schema.keys
      col_map = {}
      keys.map { |key| col_map[schema[key]["name"]] = key }

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id,
      }

      instantiate_row = Utils::CollectionViewComponents.add_new_row(new_block_id)
      set_block_alive = Utils::CollectionViewComponents.set_collection_blocks_alive(new_block_id, @collection_id)
      new_block_edited_time = Utils::BlockComponents.last_edited_time(new_block_id)
      page_sort = Utils::BlockComponents.row_location_add(last_row_id, new_block_id, @view_id)

      operations = [
        instantiate_row,
        set_block_alive,
        new_block_edited_time,
        page_sort
      ]

      data.keys.each_with_index do |col_name, j|
        unless col_map.keys.include?(col_name.to_s); raise ArgumentError, "Column '#{col_name.to_s}' does not exist." end
        if %q[select multi_select].include?(schema[col_map[col_name.to_s]]["type"])
          options = schema[col_map[col_name.to_s]]["options"].nil? ? [] : schema[col_map[col_name.to_s]]["options"].map {|option| option["value"]}
          if !options.include?(data[col_name])
            create_new_option = Utils::CollectionViewComponents.add_new_option(col_map[col_name.to_s], data[col_name], @collection_id)
            operations.push(create_new_option)
          end
        end
        child_component = Utils::CollectionViewComponents.insert_data(new_block_id, col_map[col_name.to_s], data[col_name], schema[col_map[col_name.to_s]]["type"])
        operations.push(child_component)
      end

      request_url = URLS[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers,
      )

      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub.";       end

      NotionAPI::CollectionViewRow.new(new_block_id, @parent_id, @collection_id, @view_id)
    end

    def add_property(name, type)
      # ! add a property (column) to the table.
      # ! name -> name of the property : ``str``
      # ! type -> type of the property : ``str``
      cookies = Core.options["cookies"]
      headers = Core.options["headers"]

      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id,
      }

      # create updated schema
      schema = extract_collection_schema(@collection_id, @view_id)
      schema[name] = {
        name: name,
        type: type,
      }
      new_schema = {
        schema: schema,
      }

      add_collection_property = Utils::CollectionViewComponents.add_collection_property(@collection_id, new_schema)

      operations = [
        add_collection_property,
      ]

      request_url = URLS[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers,
      )
      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub.";       end

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
        verticalColumns: false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)

      i = 0
      while jsonified_record_response.empty? || jsonified_record_response["block"].empty?
        return {} if i >= 10

        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i += 1
      end

      collection_data = extract_collection_data(@collection_id, @view_id)
      schema = collection_data["collection"][collection_id]["value"]["schema"]
      column_mappings = schema.keys
      column_names = column_mappings.map { |mapping| schema[mapping]["name"] }

      collection_row = CollectionViewRow.new(row_id, @parent_id, @collection_id, @view_id)
      collection_row.instance_variable_set(:@column_names, column_names)
      CollectionViewRow.class_eval { attr_reader :column_names }

      row_data = collection_data["block"][collection_row.id]
      create_singleton_methods_and_instance_variables(collection_row, row_data)

      collection_row
    end

    def row_ids
      # ! retrieve all Collection View table rows.
      clean_id = extract_id(@id)

      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false,
      }

      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response["block"].empty?
        return {} if i >= 10

        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i += 1
      end

      jsonified_record_response["collection_view"][@view_id]["value"]["page_sort"]
    end

    def rows
      # ! returns all rows as instantiated class instances.
      row_id_array = row_ids
      parent_id = @parent_id
      collection_id = @collection_id
      view_id = @view_id
      collection_data = extract_collection_data(@collection_id, @view_id)
      schema = collection_data["collection"][collection_id]["value"]["schema"]
      column_mappings = schema.keys
      column_names = column_mappings.map { |mapping| schema[mapping]["name"] }

      row_instances = row_id_array.map { |row_id| NotionAPI::CollectionViewRow.new(row_id, parent_id, collection_id, view_id) }
      clean_row_instances = row_instances.filter { |row| collection_data["block"][row.id] }
      clean_row_instances.each { |row| row.instance_variable_set(:@column_names, column_names) }
      CollectionViewRow.class_eval { attr_reader :column_names }

      clean_row_instances.each do |collection_row|
        row_data = collection_data["block"][collection_row.id]
        create_singleton_methods_and_instance_variables(collection_row, row_data)
      end
      clean_row_instances
    end
    def create_singleton_methods_and_instance_variables(row, row_data)
      # ! creates singleton methods for each property in a CollectionView.
      # ! row -> the block ID of the 'row' to retrieve: ``str``
      # ! row_data -> the data corresponding to that row, should be key-value pairs where the keys are the columns: ``hash``
      collection_data = extract_collection_data(@collection_id, @view_id)
      schema = collection_data["collection"][collection_id]["value"]["schema"]
      column_mappings = schema.keys
      column_hash = {}
      column_names = column_mappings.map { |mapping| column_hash[mapping] = schema[mapping]["name"].downcase }
      
      column_hash.keys.each_with_index do |column, i|
        # loop over the column names...
        # set instance variables for each column, allowing the dev to 'read' the column value
        cleaned_column = column_hash[column].split(" ").join("_").downcase.to_sym

        # p row_data["value"]["properties"][column_mappings[i]], !(row_data["value"]["properties"][column] or row_data["value"]["properties"][column_mappings[i]])
        if row_data["value"]["properties"].nil? or row_data["value"]["properties"][column].nil?
          value = ""
        else
          value = row_data["value"]["properties"][column][0][0]  
        end

        row.instance_variable_set("@#{cleaned_column}", value)
        CollectionViewRow.class_eval { attr_reader cleaned_column }
        # then, define singleton methods for each column that are used to update the table cell 
        row.define_singleton_method("#{cleaned_column}=") do |new_value|
          # neat way to get the name of the currently invoked method...
          parsed_method = __method__.to_s[0...-1].split("_").join(" ")
          cookies = Core.options["cookies"]
          headers = Core.options["headers"]

          request_id = extract_id(SecureRandom.hex(16))
          transaction_id = extract_id(SecureRandom.hex(16))
          space_id = extract_id(SecureRandom.hex(16))

          request_ids = {
            request_id: request_id,
            transaction_id: transaction_id,
            space_id: space_id,
          }

          update_property_value = Utils::CollectionViewComponents.update_property_value(@id, column_hash.key(parsed_method), new_value)

          operations = [
            update_property_value,
          ]

          request_url = URLS[:UPDATE_BLOCK]
          request_body = build_payload(operations, request_ids)
          response = HTTParty.post(
            request_url,
            body: request_body.to_json,
            cookies: cookies,
            headers: headers,
          )
          unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
               Please try again, and if issues persist open an issue in GitHub.";end
          
          # set the instance variable to the updated value!
          _ = row.instance_variable_set("@#{__method__.to_s[0...-1]}", new_value)
          row
        end
      end
    end
  end

  # class that represents each row in a CollectionView
  class CollectionViewRow < Core
    @notion_type = "table_row"
    @type = "table_row"

    def type
      NotionAPI::CollectionViewRow.notion_type
    end

    def inspect
      "CollectionViewRow - id: #{self.id} - parent id: #{self.parent_id}"
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

  # class that represents a CollectionViewPage, inheriting all properties from CollectionView
  class CollectionViewPage < CollectionView
    @notion_type = "collection_view_page"
    @type = "collection_view_page"

    def type
      NotionAPI::CollectionViewRow.notion_type
    end

    class << self
      attr_reader :notion_type, :type, :parent_id
    end

    attr_reader :parent_id, :id
  end
end
