module Utils
  #! defines utility functions and static variables for this application.
  URLS = {
    :GET_BLOCK => "https://www.notion.so/api/v3/loadPageChunk",
    :UPDATE_BLOCK => "https://www.notion.so/api/v3/saveTransactions",
  }

  class BlockComponents
    #! Each function defined here builds one component that is included in each request sent to Notions backend.
    #! Each request sent will contain multiple components.
    def self.create(block_id, block_type)
      #! payload for creating a block.
      #! block_id -> id of the new block : ``str``
      #! block_type -> type of block to create : ``cls``
      table = "block"
      path = []
      command = "update"
      timestamp = DateTime.now.strftime("%Q")
      return {
               :id => block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :id => block_id,
                 :type => block_type,
                 :properties => {},
                 :created_time => timestamp,
                 :last_edited_time => timestamp,
               },
             }
    end

    def self.title(id, title)
      #! payload for updating the title of a block
      #! id -> the ID to update the title of : ``str``
      table = "block"
      path = ["properties", "title"]
      command = "set"
      args = title
      return {
               :id => id,
               :table => table,
               :path => path,
               :command => command,
               :args => [[title]],
             }
    end

    def self.last_edited_time(id)
      #! payload for last edited time
      #! id -> either the block ID or parent ID : ``str``
      timestamp = DateTime.now.strftime("%Q")
      table = "block"
      path = ["last_edited_time"]
      command = "set"
      args = timestamp
      return {
               :table => table,
               :id => id,
               :path => path,
               :command => command,
               :args => timestamp,
             }
    end

    def self.convert_type(id, block_class_to_convert_to)
      #! payload for converting a block to a different type.
      #! id -> id of the block to convert : ``str``
      #! block_class_to_convert_to -> type to convert to block to: ``cls``
      table = "block"
      path = []
      command = "update"
      return {
               :id => id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :type => block_class_to_convert_to.notion_type,
               },
             }
    end

    def self.set_parent_to_alive(block_parent_id, new_block_id)
      table = "block"
      path = []
      command = "update"
      parent_table = "block"
      alive = true
      return {
               :id => new_block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :parent_id => block_parent_id,
                 :parent_table => parent_table,
                 :alive => alive,
               },
             }
    end

    def self.set_block_to_dead(block_id)
      table = "block"
      path = []
      command = "update"
      parent_table = "block"
      alive = false
      return {
               :id => block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :alive => false,
               },
             }
    end

    def self.duplicate(block_type, block_title, block_id, new_block_id, user_notion_id, contents)
      #! payload for duplicating a block. Most properties should be
      #! inherited from the block class the method is invoked on.
      #! block_type -> type of block that is being duplicated : ``cls``
      #! block_title -> title of block : ``str``
      #! block_id -> id of block: ``str``
      #! new_block_id -> id of new block : ``str``
      #! user_notion_id -> ID of notion user : ``str``
      p block_type
      timestamp = DateTime.now.strftime("%Q")
      table = "block"
      path = []
      command = "update"

      return {
               :id => new_block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :id => new_block_id,
                 :version => 10,
                 :type => block_type,
                 :properties => {
                   :title => [[block_title]],
                 },
                 :content => contents, # root-level blocks
                 :created_time => timestamp,
                 :last_edited_time => timestamp,
                 :created_by_table => "notion_user",
                 :created_by_id => user_notion_id,
                 :last_edited_by_table => "notion_user",
                 :last_edited_by_id => user_notion_id,
                 :copied_from => block_id,
               },
             }
    end

    def self.parent_location_add(block_parent_id, block_id)
      table = "block"
      path = []
      command = "update"
      parent_table = "block"
      alive = true

      return {
               :id => block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :parent_id => block_parent_id,
                 :parent_table => parent_table,
                 :alive => alive,
               },
             }
    end

    def self.block_location_add(block_parent_id, block_id, new_block_id = nil, targetted_block, command)
      #! payload for duplicating a block. Most properties should be
      #! inherited from the block class the method is invoked on.
      #! block_parent_id -> id of parent block : ``str``
      #! block_id -> id of block: ``str``
      #! after -> location of ID to place the new block after : ``str``
      table = "block"
      path = ["content"]

      return {
               :table => table,
               :id => block_parent_id, # ID of the parent for the new block. It should be the block that the method is invoked on.
               :path => path,
               :command => command,
               :args => {
                 :after => targetted_block ? targetted_block : block_id,
                 :id => new_block_id ? new_block_id : block_id,
               },
             }
    end

    def self.block_location_remove(block_parent_id, block_id)
      #! removes a notion block
      #! block_parent_id -> the parent ID of the block to remove : ``str``
      #! block_id -> the ID of the block to remove : ``str``
      table = "block"
      path = ["content"]
      command = "listRemove"
      return {
               :table => table,
               :id => block_parent_id, # ID of the parent for the new block. It should be the block that the method is invoked on.
               :path => path,
               :command => command,
               :args => {
                 :id => block_id,
               },
             }
    end

    def self.checked_todo(block_id, standardized_check_val)
      #! payload for setting a "checked" value for TodoBlock.
      #!
      table = "block"
      path = ["properties"]
      command = "update"
      return {
               :id => block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :checked => [[standardized_check_val]],
               },
             }
    end

    def self.update_codeblock_language(block_id, coding_language)
      #! update the language for a codeblock
      #! block_id -> id of the code block
      #! new_language -> language to change the block to.
      table = "block"
      path = ["properties"]
      command = "update"

      return {
               :id => block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :language => [[coding_language]],
               },
             }
    end
  end

  class CollectionViewComponents
    def self.create_collection_view(new_block_id, collection_id, view_ids)
      table = "block"
      command = "update"
      path = []
      type = "collection_view"
      properties = {}
      timestamp = DateTime.now.strftime("%Q")

      return {
               :id => new_block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :id => new_block_id,
                 :type => type,
                 :collection_id => collection_id,
                 :view_ids => [
                   view_ids,
                 ],
                 :properties => properties,
                 :created_time => timestamp,
                 :last_edited_time => timestamp,
               },
             }
    end

    def self.set_collection_blocks_alive(new_block_id, collection_id)
      table = "block"
      path = []
      command = "update"
      parent_table = "collection"
      alive = true
      type = "page"
      properties = {}
      timestamp = DateTime.now.strftime("%Q")

      return {
               :id => new_block_id,
               :table => table,
               :path => path,
               :command => command,
               :args => {
                 :id => new_block_id,
                 :type => type,
                 :parent_id => collection_id,
                 :parent_table => parent_table,
                 :alive => alive,
                 :properties => properties,
                 :created_time => timestamp,
                 :last_edited_time => timestamp,
               },
             }
    end

    def self.set_view_config(new_block_id, view_id, children_ids)

      table = "collection_view"
      path = []
      command = "update"
      version = 0
      type = "table"
      name = "Default View"
      parent_table = "block"
      alive = true

      return {
              :id => view_id,
              :table => table,
              :path => path,
              :command => command,
              :args => {
                :id => view_id,
                :version => version,
                :type => type,
                :name => name,
                :page_sort => children_ids,
                :parent_id => new_block_id,
                :parent_table => parent_table,
                :alive => alive,
               },
             }
    end

    def self.set_collection_columns(collection_id, new_block_id, data)
      col_names = data[0].keys
      col_types = data[0].values
      schema_conf = {}
      col_names.each_with_index do |name, i| 
        if i == 0
          schema_conf[:title] = {:name => col_names[i], :type => "title"}
        else
          schema_conf[col_names[i]] = {:name => col_names[i], :type => "text" }
        end
      end
      return {
        :id => collection_id,
        :table => "collection",
        :path => [],
        :command => "update",
        :args => {
            :id => collection_id,
            :schema => schema_conf,
            :parent_id => new_block_id,
            :parent_table => "block",
            :alive => true
        }
    }
    end

    def self.set_collection_title(collection_title, collection_id)
      table = "collection"
      path = ["name"]
      command = "set"

      return {
               :id => collection_id,
               :table => table,
               :path => path,
               :command => command,
               :args => [[collection_title]]
            }
    end

    def self.insert_data(block_id, column, value)
      table = "block"
      path = [
        "properties",
        column
      ]
      command = "set"
      
      return {
       :id => block_id,
       :table => table,
       :path => path,
       :command => command,
       :args => [[value]]
    }
  end
  end

  def build_payload(operations, request_ids)
    request_id = request_ids[:request_id]
    transaction_id = request_ids[:transaction_id]
    space_id = request_ids[:space_id]
    $Payload = {
      :requestId => request_id,
      :transactions => [
        {
          :id => transaction_id,
          :shardId => 955090,
          :spaceId => space_id,
          :operations => operations,
        },
      ],
    }
    return $Payload
  end
end
