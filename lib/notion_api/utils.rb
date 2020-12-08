# frozen_string_literal: true

module Utils
  # ! defines utility functions and static variables for this application.
  URLS = {
    GET_BLOCK: "https://www.notion.so/api/v3/loadPageChunk",
    UPDATE_BLOCK: "https://www.notion.so/api/v3/saveTransactions",
    GET_COLLECTION: "https://www.notion.so/api/v3/queryCollection",
  }.freeze

  class BlockComponents
    # ! Each function defined here builds one component that is included in each request sent to Notions backend.
    # ! Each request sent will contain multiple components.
    def self.create(block_id, block_type)
      # ! payload for creating a block.
      # ! block_id -> id of the new block : ``str``
      # ! block_type -> type of block to create : ``cls``
      table = "block"
      path = []
      command = "update"
      timestamp = DateTime.now.strftime("%Q")
      {
        id: block_id,
        table: table,
        path: path,
        command: command,
        args: {
          id: block_id,
          type: block_type,
          properties: {},
          created_time: timestamp,
          last_edited_time: timestamp,
        },
      }
    end

    def self.title(id, title)
      # ! payload for updating the title of a block
      # ! id -> the ID to update the title of : ``str``
      table = "block"
      path = %w[properties title]
      command = "set"

      {
        id: id,
        table: table,
        path: path,
        command: command,
        args: [[title]],
      }
    end

    def self.last_edited_time(id)
      # ! payload for updating the last edited time
      # ! id -> either the block ID or parent ID : ``str``
      timestamp = DateTime.now.strftime("%Q")
      table = "block"
      path = ["last_edited_time"]
      command = "set"

      {
        table: table,
        id: id,
        path: path,
        command: command,
        args: timestamp,
      }
    end

    def self.convert_type(id, block_class_to_convert_to)
      # ! payload for converting a block to a different type.
      # ! id -> id of the block to convert : ``str``
      # ! block_class_to_convert_to -> type to convert to block to: ``NotionAPI::<Block_Type>``
      table = "block"
      path = []
      command = "update"

      {
        id: id,
        table: table,
        path: path,
        command: command,
        args: {
          type: block_class_to_convert_to.notion_type,
        },
      }
    end

    def self.set_parent_to_alive(block_parent_id, new_block_id)
      # ! payload for setting a blocks parent ID to 'alive'
      # ! block_parent_id -> the blocks parent ID : ``str``
      # ! new_block_id -> the new block ID, who is a child of the parent : ``str``
      table = "block"
      path = []
      command = "update"
      parent_table = "block"
      alive = true
      {
        id: new_block_id,
        table: table,
        path: path,
        command: command,
        args: {
          parent_id: block_parent_id,
          parent_table: parent_table,
          alive: alive,
        },
      }
    end

    def self.set_block_to_dead(block_id)
      # ! payload for setting a block to dead (alive == true)
      # ! block_id -> the block ID to 'kill' : ``str``
      table = "block"
      path = []
      command = "update"
      alive = false

      {
        id: block_id,
        table: table,
        path: path,
        command: command,
        args: {
          alive: alive,
        },
      }
    end

    def self.duplicate(block_type, block_title, block_id, new_block_id, user_notion_id, contents, properties, formatting)
      # ! payload for duplicating a block. Most properties should be
      # ! inherited from the block class the method is invoked on.
      # ! block_type -> type of block that is being duplicated : ``cls``
      # ! block_title -> title of block : ``str``
      # ! block_id -> id of block: ``str``
      # ! new_block_id -> id of new block : ``str``
      # ! user_notion_id -> ID of notion user : ``str``
      # ! contents -> The children of the block
      timestamp = DateTime.now.strftime("%Q")
      table = "block"
      path = []
      command = "update"

      {
        id: new_block_id,
        table: table,
        path: path,
        command: command,
        args: {
          id: new_block_id,
          version: 10,
          type: block_type,
          properties: properties,
          format: formatting,
          content: contents, # root-level blocks
          created_time: timestamp,
          last_edited_time: timestamp,
          created_by_table: "notion_user",
          created_by_id: user_notion_id,
          last_edited_by_table: "notion_user",
          last_edited_by_id: user_notion_id,
          copied_from: block_id,
        },
      }
    end

    def self.parent_location_add(block_parent_id, block_id)
      # ! payload for adding a parent
      # ! block_parent_id -> the parent id of the block : ``str``
      # ! block_id -> the id of the block : ``str``
      table = "block"
      path = []
      command = "update"
      parent_table = "block"
      alive = true

      {
        id: block_id,
        table: table,
        path: path,
        command: command,
        args: {
          parent_id: block_parent_id,
          parent_table: parent_table,
          alive: alive,
        },
      }
    end

    def self.block_location_add(block_parent_id, block_id, new_block_id = nil, target, command)
      # ! payload for duplicating a block. Most properties should be
      # ! inherited from the block class the method is invoked on.
      # ! block_parent_id -> id of parent block : ``str``
      # ! block_id -> id of block: ``str``
      # ! new_block_id -> id of the new block: ``str``
      # ! target -> the ID of the target block : ``str``
      # ! command -> the position of the block, before or after, in relation to the target : ``str``
      table = "block"
      path = ["content"]

      args = if command == "listAfter"
          {
            after: target || block_id,
            id: new_block_id || block_id,
          }
        else
          {
            before: target || block_id,
            id: new_block_id || block_id,
          }
        end

      {
        table: table,
        id: block_parent_id, # ID of the parent for the new block. It should be the block that the method is invoked on.
        path: path,
        command: command,
        args: args,
      }
    end

    def self.row_location_add(last_row_id, block_id, view_id)
      {
        "table": "collection_view",
        "id": view_id,
        "path": [
            "page_sort"
        ],
        "command": "listAfter",
        "args": {
            "after": last_row_id,
            "id": block_id
        }
    }
    end

    def self.block_location_remove(block_parent_id, block_id)
      # ! removes a notion block
      # ! block_parent_id -> the parent ID of the block to remove : ``str``
      # ! block_id -> the ID of the block to remove : ``str``
      table = "block"
      path = ["content"]
      command = "listRemove"
      {
        table: table,
        id: block_parent_id, # ID of the parent for the new block. It should be the block that the method is invoked on.
        path: path,
        command: command,
        args: {
          id: block_id,
        },
      }
    end

    def self.checked_todo(block_id, standardized_check_val)
      # ! payload for setting a "checked" value for TodoBlock.
      # ! block_id -> the ID of the block to remove : ``str``
      # ! standardized_check_val -> tyes/no value, determines the checked property of the block : ``str``
      table = "block"
      path = ["properties"]
      command = "update"
      {
        id: block_id,
        table: table,
        path: path,
        command: command,
        args: {
          checked: [[standardized_check_val]],
        },
      }
    end

    def self.update_codeblock_language(block_id, coding_language)
      # ! update the language for a codeblock
      # ! block_id -> id of the code block
      # ! coding_language -> language to change the block to.
      table = "block"
      path = ["properties"]
      command = "update"

      {
        id: block_id,
        table: table,
        path: path,
        command: command,
        args: {
          language: [[coding_language]],
        },
      }
    end
    def self.add_emoji_icon(block_id, icon)
      {
        id: block_id,
        table: "block",
        path: ["format", "page_icon"],
        command: "set", "args": icon,
      }
    end
  end

  class CollectionViewComponents
    def self.create_collection_view(new_block_id, collection_id, view_ids)
      # ! payload for creating a collection view
      # ! new_block_id -> id of the new block
      # ! collection_id -> ID of the collection.
      # ! view_ids -> id of the view
      table = "block"
      command = "update"
      path = []
      type = "collection_view"
      properties = {}
      timestamp = DateTime.now.strftime("%Q")

      {
        id: new_block_id,
        table: table,
        path: path,
        command: command,
        args: {
          id: new_block_id,
          type: type,
          collection_id: collection_id,
          view_ids: [
            view_ids,
          ],
          properties: properties,
          created_time: timestamp,
          last_edited_time: timestamp,
        },
      }
    end

    def self.set_collection_blocks_alive(new_block_id, collection_id)
      # ! payload for setting the collection blocks to alive.
      # ! new_block_id -> id of the new block
      # ! collection_id -> ID of the collection.
      table = "block"
      path = []
      command = "update"
      parent_table = "collection"
      alive = true
      type = "page"
      properties = {}
      timestamp = DateTime.now.strftime("%Q")

      {
        id: new_block_id,
        table: table,
        path: path,
        command: command,
        args: {
          id: new_block_id,
          type: type,
          parent_id: collection_id,
          parent_table: parent_table,
          alive: alive,
          properties: properties,
          created_time: timestamp,
          last_edited_time: timestamp,
        },
      }
    end

    def self.set_view_config(collection_type, new_block_id, view_id, children_ids)
      # ! payload for setting the configurations of the view.
      # ! new_block_id -> id of the new block
      # ! view_id -> id of the view
      # ! children_ids -> IDs for the children of the collection.
      table = "collection_view"
      path = []
      command = "update"
      version = 0
      name = "Default View"
      parent_table = "block"
      alive = true

      {
        id: view_id,
        table: table,
        path: path,
        command: command,
        args: {
          id: view_id,
          version: version,
          type: collection_type,
          name: name,
          page_sort: children_ids,
          parent_id: new_block_id,
          parent_table: parent_table,
          alive: alive,
        },
      }
    end

    def self.set_collection_columns(collection_id, new_block_id, data)
      # ! payload for setting the columns of the table.
      # ! collection_id -> ID of the collection.
      # ! new_block_id -> id of the new block
      # ! data -> json data to insert into table.
      col_names = data[0].keys
      data_mappings = { Integer => "number", String => "text", Array => "text", Float => "number", Date => "date" }
      exceptions = [ArgumentError, TypeError]
      data_types = col_names.map do |name|
        # TODO: this is a little hacky... should probably think about a better way or add a requirement for user input to match a certain criteria.
        begin
          DateTime.parse(data[0][name]) ? data_mappings[Date] : nil
        rescue *exceptions
          data_mappings[data[0][name].class]
        end
      end

      schema_conf = {}
      col_names.each_with_index do |_name, i|
        if i.zero?
          schema_conf[:title] = { name: col_names[i], type: "title" }
        else
          schema_conf[col_names[i]] = { name: col_names[i], type: data_types[i] }
        end
      end
      return {
               id: collection_id,
               table: "collection",
               path: [],
               command: "update",
               args: {
                 id: collection_id,
                 schema: schema_conf,
                 parent_id: new_block_id,
                 parent_table: "block",
                 alive: true,
               },
             }, data_types
    end

    def self.set_collection_title(collection_title, collection_id)
      # ! payload for setting the title of the collection.
      # ! collection_title -> title of the collection.
      # ! collection_id -> ID of the collection.
      table = "collection"
      path = ["name"]
      command = "set"

      {
        id: collection_id,
        table: table,
        path: path,
        command: command,
        args: [[collection_title]],
      }
    end

    def self.insert_data(block_id, column, value, mapping)
      # ! payload for inserting data into the table.
      # ! block_id -> the ID of the block : ``str``
      # ! column -> the name of the column to insert data into.
      # ! value -> the value to insert into the column.
      # ! mapping -> the column data type.
      simple_mappings = ["title", "text", "phone_number", "email", "url", "number", "checkbox", "select", "multi_select"]
      datetime_mappings = ["date"]
      media_mappings = ["file"]
      person_mappings = ["person"]

      table = "block"
      path = [
        "properties",
        column,
      ]
      command = "set"

      if simple_mappings.include?(mapping)
        args = [[value]]
      elsif media_mappings.include?(mapping)
        args = [[value, [["a", value]]]]
      elsif datetime_mappings.include?(mapping)
        args = [["‣", [["d", { "type": "date", "start_date": value }]]]]
      elsif person_mappings.include?(mapping)
        args = [["‣",
          [["u", value]]
        ]]
        else 
          raise SchemaTypeError, "Invalid property type: #{mapping}"
      end

      {
        table: table,
        id: block_id,
        command: command,
        path: path,
        args: args,
      }
    end

    def self.add_new_option(column, value, collection_id)
      table = "collection"
      path = ["schema", column, "options"]
      command = "keyedObjectListAfter"
      colors = ["default", "gray", "brown", "orange", "yellow", "green", "blue", "purple", "pink", "red"]
      random_color = colors[rand(0...colors.length)]

      args = {
        "value": {
            "id": SecureRandom.hex(16),
            "value": value,
            "color": random_color
        }
      }

      {
        table: table,
        id: collection_id,
        command: command,
        path: path,
        args: args,
      }
    end

    def self.add_new_row(new_block_id)
      # ! payload for adding a new row to the table.
      # ! new_block_id -> the ID of the new row : ``str``
      table = "block"
      path = []
      command = "set"
      type = "page"

      {
        id: new_block_id,
        table: table,
        path: path,
        command: command,
        args: {
          type: type,
          id: new_block_id,
          version: 1,
        },
      }
    end

    def self.query_collection(collection_id, view_id, search_query = "")
      # ! payload for querying the table for data.
      # ! collection_id -> the collection ID : ``str``
      # ! view_id -> the view ID : ``str``
      # ! search_query -> the query for searching the table : ``str``
      query = {}
      loader = {
        type: "table",
        limit: 100,
        searchQuery: search_query,
        loadContentCover: true,
      }

      {
        collectionId: collection_id,
        collectionViewId: view_id,
        query: query,
        loader: loader,
      }
    end

    def self.add_collection_property(collection_id, args)
      # ! payload for adding a column to the table.
      # ! collection_id -> the collection ID : ``str``
      # ! args -> the definition of the column : ``str``
      args["format"] = {
        "table_properties" => [
          {
            "property" => "title",
            "visible" => true,
            "width" => 280,
          },
          {
            "property" => "aliases",
            "visible" => true,
            "width" => 200,
          },
          {
            "property" => "category",
            "visible" => true,
            "width" => 200,
          },
          {
            "property" => "description",
            "visible" => true,
            "width" => 200,
          },
          {
            "property" => "ios_version",
            "visible" => true,
            "width" => 200,
          },
          {
            "property" => "tags",
            "visible" => true,
            "width" => 200,
          },
          {
                  "property" => "phone",
                  "visible" => true,
                  "width" => 200,
                },
          {
            "property" => "unicode_version",
            "visible" => true,
            "width" => 200,
          },
        ],
      }
      {
        id: collection_id,
        table: "collection",
        path: [],
        command: "update",
        args: args,
      }
    end

    def self.update_property_value(page_id, column_name, new_value)
      # ! update the specified column_name to new_value
      # ! page_id -> the ID of the page: ``str``
      # ! column_name -> the name of the column ["property"] to update: ``str``
      # ! new_value -> the new value to assign to that column ["property"]: ``str``
      table = "block"
      path = [
        "properties",
        column_name,
      ]
      command = "set"
      args = [[
        new_value,
      ]]

      {
        id: page_id,
        table: table,
        path: path,
        command: command,
        args: args,
      }
    end
  end

  class SchemaTypeError < StandardError
    def initialize(msg="Custom exception that is raised when an invalid property type is passed as a mapping.", exception_type="schema_type")
      @exception_type = exception_type
      super(msg)
    end
  end

  def build_payload(operations, request_ids)
    # ! properly formats the payload for Notions backend.
    # ! operations -> an array of hashes that define the operations to perform : ``Array[Hash]``
    # ! request_ids -> the unique IDs for the request : ``str``
    request_id = request_ids[:request_id]
    transaction_id = request_ids[:transaction_id]
    space_id = request_ids[:space_id]
    payload = {
      requestId: request_id,
      transactions: [
        {
          id: transaction_id,
          shardId: 955_090,
          spaceId: space_id,
          operations: operations,
        },
      ],
    }
    payload
  end
end