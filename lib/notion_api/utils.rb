module Utils
  URLS = {
    :GET_BLOCK => "https://www.notion.so/api/v3/loadPageChunk",
    :UPDATE_BLOCK => "https://www.notion.so/api/v3/saveTransactions",
  }

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
                :operations => operations
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
                :operations => operations
            }
        ]
    }
    return $Create_block
  end
end
