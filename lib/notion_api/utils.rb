module Utils
  URLS = {
    :GET_BLOCK => "https://www.notion.so/api/v3/loadPageChunk",
    :UPDATE_BLOCK => "https://www.notion.so/api/v3/saveTransactions",
    :GET_USER_ANALYTICS => "https://www.notion.so/api/v3/"
  }

  def build_operations(title, styles)
    timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i

    update_title_payload = [
      # UPDATE BLOCK TITLE
      {
        :id => @id,
        :table => "block",
        :path => ["properties", "title"],
        :command => "set",
        :args => [[title, styles.each { |style| [style] }]],
      },
      # UPDATE BLOCK ID LAST EDITED TIME
      {
        :table => "block",
        :id => @id,
        :path => [
          "last_edited_time",
        ],
        :command => "set",
        :args => timestamp,
      },
      # UPDATE PARENT IDs LAST EDITED TIME
      {
        :table => "block",
        :id => @parent_id,
        :path => [
          "last_edited_time",
        ],
        :command => "set",
        :args => timestamp,
      },
    ]

    convert_title_payload = [
      {
        "id": @id,
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "type" => block_class_to_convert_to.notion_type,
        },
      },
      {
        "table": "block",
        "id": @id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
      {
        "table": "block",
        "id": @parent_id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
    ]

    update_style_payload = [
      {
        "id": @id,
        "table": "block",
        "path": [
          "properties",
          "title",
        ],
        "command": "set",
        "args": style_args,
      },
      {
        "table": "block",
        "id": @id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
      {
        "table": "block",
        "id": @parent_id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
    ]

    duplicate_payload = [
      {
        "id": new_block_id,
        "table": "block",
        "path": [],
        "command": "update",
        "args": {
          "id": new_block_id,
          "version": 10,
          "type": block.type,
          "properties": {
            "title": [
              [
                @title,
                [
                  [
                    "h",
                    "red_background",
                  ],
                  [
                    "b",
                  ],
                  [
                    "i",
                  ],
                  [
                    "_",
                  ],
                  [
                    "c",
                  ],
                ],
              ],
            ],
          },
          "created_time": timestamp,
          "last_edited_time": timestamp,
          "created_by_table": "notion_user",
          "created_by_id": user_notion_id,
          "last_edited_by_table": "notion_user",
          "last_edited_by_id": user_notion_id,
          "copied_from": block.id,
        },
      },
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
      {
        "table": "block",
        "id": block.parent_id,
        "path": [
          "content",
        ],
        "command": "listAfter",
        "args": {
          "after": location.nil? ? block.id : location,
          "id": new_block_id,
        },
      },
      {
        "table": "block",
        "id": new_block_id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": 1605556440000,
      },
      {
        "table": "block",
        "id": block.parent_id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": 1605556440000,
      },
    ]
    create_block_payload = [
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
          "after": @parent_id, #TODO: SPECIFIED ID OR LAST ID ON PAGE
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
        "args": [[block_title]], # ["b", "_", ["h", "teal_background"]]
      },
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
        "args": [[block_title]], # ["b", "_", ["h", "teal_background"]]
      },
    ]

    cross_off_todo_payload = [
      {
        "id": @id,
        "table": "block",
        "path": [
          "properties",
        ],
        "command": "update",
        "args": {
          "checked": [
            [
              standardized_check_val,
            ],
          ],
        },
      },
      {
        "table": "block",
        "id": @id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
      {
        "table": "block",
        "id": @parent_id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
    ]

    update_bodeblock_payload = [
      {
        "id": @id,
        "table": "block",
        "path": [
          "properties",
        ],
        "command": "update",
        "args": {
          "language": [[coding_language]],
        },
      },
      {
        "table": "block",
        "id": @id,
        "path": [
          "properties", "title",
        ],
        "command": "set",
        "args": [[styles[:code]]],
      },
    ]

    table_of_contents_update = [
      {
        "id": @id,
        "table": "block",
        "path": [
          "format",
        ],
        "command": "update",
        "args": style_args,
      },
      {
        "table": "block",
        "id": @id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
      {
        "table": "block",
        "id": @parent_id,
        "path": [
          "last_edited_time",
        ],
        "command": "set",
        "args": timestamp,
      },
    ]
  end

  def build_payload()
    $Payloads = {
      :UPDATE_TITLE => "",
    }
  end

  def title_payload(new_block_id, operations)
    $Title_and_styles = {
      :requestId => new_block_id, #TODO: thiis should be dynamically created
      :transactions => [
        {
          :id => new_block_id, #TODO: this should be dynamically created
          :operations => operations,
        },
      ],
    }
    return $Title_and_styles
  end # title_and_styles_payload

  def update_block_payload(operations)
    $Update_block = {
      :requestId => "09568227-bf79-4563-af8b-a3825058d3d9", #TODO: this should be unique
      :transactions => [

        :id => "5cd68079-4b35-4545-b481-b72967b81c40",
        :shardId => 955090,
        :spaceId => "f687f7de-7f4c-4a86-b109-941a8dae92d2",
        :operations => operations,
      ],
    }
    return $Update_block
  end

  def convert_block_payload(operations)
    $Convert_block = {
      :requestId => "09568227-bf79-4563-af8b-a3825058d3d9",
      :transactions => [
        {
          :id => "5cd68079-4b35-4545-b481-b72967b81c40",
          :shardId => 955090,
          :spaceId => "f687f7de-7f4c-4a86-b109-941a8dae92d2",
          :operations => operations,
        },
      ],
    }
    return $Convert_block
  end

  def create_block_payload(operations, request_ids)
    request_id = request_ids[:request_id]
    transaction_id = request_ids[:transaction_id]
    space_id = request_ids[:space_id]
    $Create_block = {
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
    return $Create_block
  end
end
