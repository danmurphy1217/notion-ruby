module Utils
  #! defines utility functions and static variables for this application.
  URLS = {
    :GET_BLOCK => "https://www.notion.so/api/v3/loadPageChunk",
    :UPDATE_BLOCK => "https://www.notion.so/api/v3/saveTransactions",
  }

  class Components

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
            :last_edited_time => timestamp
        }
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

    def duplicate(block_type, block_title, block_id, new_block_id, user_notion_id)
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

    def block_location(block_parent_id, block_id, location = nil)
      #! payload for duplicating a block. Most properties should be
      #! inherited from the block class the method is invoked on.
      #! block_parent_id -> id of parent block : ``str``
      #! block_id -> id of block: ``str``
      #! location -> location of ID to place the new block after : ``str``
      table = "block"
      path = ["content"]
      command = "listAfter"
      return {
               :table => table,
               :id => block_parent_id,
               :path => path,
               :command => command,
               :args => {
                 :after => location ? location : block.id,
                 :id => block_id,
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

  def build_operations(title, styles)
    timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i

    update_style_payload = [
 # {
           #   "id": @id,
           #   "table": "block",
           #   "path": [
           #     "properties",
           #     "title",
           #   ],
           #   "command": "set",
           #   "args": style_args,
           # },
           # {
           #   "table": "block",
           #   "id": @id,
           #   "path": [
           #     "last_edited_time",
           #   ],
           #   "command": "set",
           #   "args": timestamp,
           # },
           # {
           #   "table": "block",
           #   "id": @parent_id,
           #   "path": [
           #     "last_edited_time",
           #   ],
           #   "command": "set",
           #   "args": timestamp,
           # },
      ]

    duplicate_payload = [
      # {
      #   "id": new_block_id,
      #   "table": "block",
      #   "path": [],
      #   "command": "update",
      #   "args": {
      #     "id": new_block_id,
      #     "version": 10,
      #     "type": block.type,
      #     "properties": {
      #       "title": [[@title]],
      #     },
      #     "created_time": timestamp,
      #     "last_edited_time": timestamp,
      #     "created_by_table": "notion_user",
      #     "created_by_id": user_notion_id,
      #     "last_edited_by_table": "notion_user",
      #     "last_edited_by_id": user_notion_id,
      #     "copied_from": block.id,
      #   },
      # },
      {
        "id": new_block_id,
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "parent_id": block.parent_id,
          "parent_table": "block",
          "alive": true,
        },
      },
    # {
    #   "table": "block",
    #   "id": block.parent_id,
    #   "path": [
    #     "content",
    #   ],
    #   "command": "listAfter",
    #   "args": {
    #     "after": location.nil? ? block.id : location,
    #     "id": new_block_id,
    #   },
    # },
    # {
    #   "table": "block",
    #   "id": new_block_id,
    #   "path": [
    #     "last_edited_time",
    #   ],
    #   "command": "set",
    #   "args": 1605556440000,
    # },
    # {
    #   "table": "block",
    #   "id": block.parent_id,
    #   "path": [
    #     "last_edited_time",
    #   ],
    #   "command": "set",
    #   "args": 1605556440000,
    # },
    ]
    create_block_payload = [
    #   {
    #     "id": new_block_id, #TODO: NEW ID
    #     "table": "block",
    #     "path": [],
    #     "command": "update",
    #     "args": {
    #       "id": new_block_id, #TODO: NEW ID
    #       "type": block_type.notion_type,
    #       "properties": {},
    #       "created_time": timestamp,
    #       "last_edited_time": timestamp,
    #     },
    #   },
    #   {
    #     "id": new_block_id, #TODO: NEW ID
    #     "table": "block",
    #     "path": [],
    #     "command": "update",
    #     "args": {
    #       "parent_id": @id, #TODO: PARENT ID
    #       "parent_table": "block",
    #       "alive": true,
    #     },
    #   },
    #   {
    #     "table": "block",
    #     "id": @id, #TODO: PARENT ID
    #     "path": [
    #       "content",
    #     ],
    #     "command": "listAfter",
    #     "args": {
    #       "after": @parent_id, #TODO: SPECIFIED ID OR LAST ID ON PAGE
    #       "id": new_block_id, #TODO: NEW ID
    #     },
    #   },
    #   {
    #     "table": "block",
    #     "id": new_block_id, #TODO: NEW ID
    #     "path": [
    #       "created_by_id",
    #     ],
    #     "command": "set",
    #     "args": user_notion_id, #TODO: USER ID, stored in cooks
    #   },
    #   {
    #     "table": "block",
    #     "id": new_block_id, #TODO: NEW ID
    #     "path": [
    #       "created_by_table",
    #     ],
    #     "command": "set",
    #     "args": "notion_user",
    #   },
    #   {
    #     "table": "block",
    #     "id": new_block_id, #TODO: NEW ID
    #     "path": [
    #       "last_edited_time",
    #     ],
    #     "command": "set",
    #     "args": timestamp,
    #   },
    #   {
    #     "table": "block",
    #     "id": new_block_id, #TODO: NEW ID
    #     "path": [
    #       "last_edited_by_id",
    #     ],
    #     "command": "set",
    #     "args": user_notion_id, #TODO: USER ID STORED IN COOKS
    #   },
    #   {
    #     "table": "block",
    #     "id": new_block_id, #TODO: NEW ID
    #     "path": [
    #       "last_edited_by_table",
    #     ],
    #     "command": "set",
    #     "args": "notion_user",
    #   },
    #   {
    #     "table": "block",
    #     "id": new_block_id, #TODO: NEW ID
    #     "path": [
    #       "properties", "title",
    #     ],
    #     "command": "set",
    #     "args": [[block_title]], # ["b", "_", ["h", "teal_background"]]
    #   },
    ]

    create_page_payload_nonpage = [
      {
        "id": new_block_id, #TODO: NEW ID
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "id": new_block_id, #TODO: NEW ID
          "type": block_type.notion_type,
          "properties": {},
          "created_time": timestamp,
          "last_edited_time": timestamp,
        },
      },
      {
        "id": new_block_id, #TODO: NEW ID
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "parent_id": @id, #TODO: PARENT ID
          "parent_table": "block",
          "alive": true,
        },
      },
      {
        "table": "block",
        "id": @id, #TODO: PARENT ID
        "path": [
          "content",
        ],
        "command": "listAfter",
        "args": {
          "after": page_last_id, #TODO: SPECIFIED ID OR LAST ID ON PAGE
          "id": new_block_id, #TODO: NEW ID
        },
      },
      {
        "table": "block",
        "id": new_block_id, #TODO: NEW ID
        "path": [
          "created_by_id",
        ],
        "command": "set",
        "args": user_notion_id, #TODO: USER ID, stored in cooks
      },
      {
        "table": "block",
        "id": new_block_id, #TODO: NEW ID
        "path": [
          "created_by_table",
        ],
        "command": "set",
        "args": "notion_user",
      },
      {
        "table": "block",
        "id": new_block_id, #TODO: NEW ID
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
      {
        "table": "block",
        "id": new_block_id, #TODO: NEW ID
        "path": [
          "last_edited_by_id",
        ],
        "command": "set",
        "args": user_notion_id, #TODO: USER ID STORED IN COOKS
      },
      {
        "table": "block",
        "id": new_block_id, #TODO: NEW ID
        "path": [
          "last_edited_by_table",
        ],
        "command": "set",
        "args": "notion_user",
      },
      {
        "table": "block",
        "id": new_block_id, #TODO: NEW ID
        "path": [
          "properties", "title",
        ],
        "command": "set",
        "args": [[block_title]],
      },
      {
        "id": new_block_id,
        "table": "block",
        "path": [
          "format",
          "page_icon",
        ],
        "command": "set",
        "args": styles[:emoji],
      },
    ]

    create_page_payload_page = [
      {
        "id": new_block_id, #TODO: NEW ID
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "id": new_block_id, #TODO: NEW ID
          "type": block_type.notion_type,
          "properties": {},
          "created_time": timestamp,
          "last_edited_time": timestamp,
        },
      },
      {
        "id": new_block_id, #TODO: NEW ID
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "parent_id": @id, #TODO: PARENT ID
          "parent_table": "block",
          "alive": true,
        },
      },
      {
        "table": "block",
        "id": @id, #TODO: PARENT ID
        "path": [
          "content",
        ],
        "command": "listAfter",
        "args": {
          "after": page_last_id, #TODO: SPECIFIED ID OR LAST ID ON PAGE
          "id": new_block_id, #TODO: NEW ID
        },
      },
      # {
      #   "table": "block",
      #   "id": new_block_id, #TODO: NEW ID
      #   "path": [
      #     "last_edited_time",
      #   ],
      #   "command": "set",
      #   "args": timestamp,
      # },
      # {
      #   "table": "block",
      #   "id": new_block_id, #TODO: NEW ID
      #   "path": [
      #     "properties", "title",
      #   ],
      #   "command": "set",
      #   "args": [[block_title]], # ["b", "_", ["h", "teal_background"]]
      # },
    ]

    cross_off_todo_payload = [
 # {
           #   "id": @id,
           #   "table": "block",
           #   "path": [
           #     "properties",
           #   ],
           #   "command": "update",
           #   "args": {
           #     "checked": [
           #       [
           #         standardized_check_val,
           #       ],
           #     ],
           #   },
           # },
           # {
           #   "table": "block",
           #   "id": @id,
           #   "path": [
           #     "last_edited_time",
           #   ],
           #   "command": "set",
           #   "args": timestamp,
           # },
           # {
           #   "table": "block",
           #   "id": @parent_id,
           #   "path": [
           #     "last_edited_time",
           #   ],
           #   "command": "set",
           #   "args": timestamp,
           # },
      ]

    update_codeblock_payload = [
      # {
      #   "id": @id,
      #   "table": "block",
      #   "path": [
      #     "properties",
      #   ],
      #   "command": "update",
      #   "args": {
      #     "language": [[coding_language]],
      #   },
      # },
      # {
      #   "table": "block",
      #   "id": @id,
      #   "path": [
      #     "properties", "title",
      #   ],
      #   "command": "set",
      #   "args": [[styles[:code]]],
      # },
    ]

    table_of_contents_update = [
      # {
      #   "id": @id,
      #   "table": "block",
      #   "path": [
      #     "format",
      #   ],
      #   "command": "update",
      #   "args": style_args,
      # },
      # {
      #   "table": "block",
      #   "id": @id,
      #   "path": [
      #     "last_edited_time",
      #   ],
      #   "command": "set",
      #   "args": timestamp,
      # },
      # {
      #   "table": "block",
      #   "id": @parent_id,
      #   "path": [
      #     "last_edited_time",
      #   ],
      #   "command": "set",
      #   "args": timestamp,
      # },
    ]
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
