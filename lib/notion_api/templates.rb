#TODO: move payloads for diff operations here as opposed to in types.rb.

class OperationTemplates
  def title_and_styles_payload(id, operations)
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
    {
        "requestId": "09568227-bf79-4563-af8b-a3825058d3d9",
        "transactions": [
          {
            "id": "5cd68079-4b35-4545-b481-b72967b81c40",
            "shardId": 955090,
            "spaceId": "f687f7de-7f4c-4a86-b109-941a8dae92d2",
            "operations": operations
          },
        ],
      }
  end
end
