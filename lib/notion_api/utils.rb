module Utils
  #! defines utility functions and static variables for this application.
  URLS = {
    :GET_BLOCK => "https://www.notion.so/api/v3/loadPageChunk",
    :UPDATE_BLOCK => "https://www.notion.so/api/v3/saveTransactions",
  }

  class Components
    #! Each function defined here builds one component that is included in each request sent to Notions backend.
    #! Each request sent will contain multiple components.
    def create(block_id, block_type)
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

    def title(id, title)
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

    def last_edited_time(id)
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

    def convert_type(id, block_class_to_convert_to)
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

    def set_parent_to_alive(block_parent_id, new_block_id)
      table = "block"
      path = []
      command = "update"
      parent_table = "block"
      alive = true
      return {
               "id": new_block_id,
               "table": table,
               "path": path,
               "command": command,
               "args": {
                 "parent_id": block_parent_id,
                 "parent_table": parent_table,
                 "alive": alive,
               },
             }
    end

    def duplicate(block_type, block_title, block_id, new_block_id, user_notion_id, contents)
      #! payload for duplicating a block. Most properties should be
      #! inherited from the block class the method is invoked on.
      #! block_type -> type of block that is being duplicated : ``cls``
      #! block_title -> title of block : ``str``
      #! block_id -> id of block: ``str``
      #! new_block_id -> id of new block : ``str``
      #! user_notion_id -> ID of notion user : ``str``
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

    def block_location(block_parent_id, block_id, new_block_id, after)
      #! payload for duplicating a block. Most properties should be
      #! inherited from the block class the method is invoked on.
      #! block_parent_id -> id of parent block : ``str``
      #! block_id -> id of block: ``str``
      #! after -> location of ID to place the new block after : ``str``
      table = "block"
      path = ["content"]
      command = "listAfter"
      return {
               :table => table,
               :id => block_parent_id,
               :path => path,
               :command => command,
               :args => {
                 :after => after ? after : block_id,
                 :id => new_block_id,
               },
             }
    end
  end

  def checked(block_id, standardized_check_val)
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

  def update_codeblock_language(block_id, coding_language)
    #! update the language for a codeblock
    #! block_id -> id of the code block
    #! new_language -> language to change the block to.
    table = "block"
    path = ["properties"]
    command = "update"

    {
      :id => block_id,
      :table => table,
      :path => path,
      :command => command,
      :args => {
        :language => [[coding_language]],
      },
    }
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
