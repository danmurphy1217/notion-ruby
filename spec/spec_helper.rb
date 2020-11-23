require "notion_api"

RSpec.configure do |conf|
  conf.before(:example) do
    @client = Notion::Client.new(ENV["token_v2"])
    #! constant IDs for the tests
    $Test_page_id = "66447bc8-17f0-44bc-81ed-3cf4802e9b00"
    $Test_page_url = "https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00"
    $Test_block_id_one = "ba87b719-9207-49a7-b646-de042b266ba8"
    $Test_block_id_two = "9e0578f3-d4d7-4ed9-bda3-f050a6eb6dca"
    $Test_collection_id_one = "f1664a99-165b-49cc-811c-84f37655908a"
    $Test_collection_id_two = "34d03794-ecdd-e42d-bb76-7e4aa77b6503"
    $Test_page_id_no_dashes = "66447bc817f044bc81ed3cf4802e9b00"
    $Root_id = "f687f7de-7f4c-4a86-b109-941a8dae92d2"

    #! constant JSON / data for the tests
    @body = { :pageId => $Test_page_id, :chunkNumber => 0, :limit => 100, :verticalColumns => false }
    @jsonified_response_page = Notion::Core.new.send("get_all_block_info", $Test_page_id, @body)
    @jsonified_response_block_one = Notion::Core.new.send("get_all_block_info", $Test_block_id_one, @body)
    @jsonified_response_block_two = Notion::Core.new.send("get_all_block_info", $Test_block_id_two, @body)
    @jsonified_response_collection_one = Notion::Core.new.send("get_all_block_info", $Test_collection_id_one, @body)
    @jsonified_response_collection_two = Notion::Core.new.send("get_all_block_info", $Test_collection_id_two, @body)
  end
end