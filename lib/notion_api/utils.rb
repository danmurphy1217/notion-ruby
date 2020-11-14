module Utils
  URLS = {
    :GET_BLOCK => "https://www.notion.so/api/v3/loadPageChunk",
    :UPDATE_BLOCK => "https://www.notion.so/api/v3/saveTransactions",
  }

  def title_payload(id, operations)
    $Title_and_styles = {
      :requestId => id, #TODO: thiis should be dynamically created
      :transactions => [
        {
              :id => id, #TODO: this should be dynamically created
              :operations => operations,
            },
      ],
    }
    return $Title_and_styles
  end # title_and_styles_payload

  def update_block_payload(operations)
    $Update_block = {
      :requestId => "09568227-bf79-4563-af8b-a3825058d3d9",
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
                :operations => operations
            },
        ],
    }
    return $Convert_block
  end
  def create_block_payload(operations)
    $Create_block = {
        :requestId => "216198e7-3203-4c25-8a00-e03802e396d7",
        :transactions => [
            {
                :id => "065e0ab1-4022-449a-8b99-e505de4bfe29",
                :shardId => 955090,
                :spaceId => "f687f7de-7f4c-4a86-b109-941a8dae92d2",
                :operations => operations
            }
        ]
    }
    return $Create_block
  end
end
