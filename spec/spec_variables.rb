module Helpers
    $Body = { :pageId => $Test_page_id, :chunkNumber => 0, :limit => 100, :verticalColumns => false }

    #! CORE_SPEC.RB HELPERS
    $Client = Notion::Client.new(ENV["token_v2"])
    $Core_spec_url = "https://www.notion.so/danmurphy/CORE-RB-TESTS-9c50a7b39ad74f2baa08b3c95f1f19e7"
    # errant data...
    $Core_spec_invalid_url_one = "https://www.notion.so/danmurphy/CORE-RB-TESTS-9c50a7b39ad74f2baa08b3c95f1f19e71" # one too many chars
    $Core_spec_invalid_url_two = "9c50a7b39ad74f2baa08b3c95f1f19e" # one too few chars
    # ids of various types...
    $Core_spec_page_id_no_dashes = "9c50a7b39ad74f2baa08b3c95f1f19e7"
    $Core_spec_page_id = "9c50a7b3-9ad7-4f2b-aa08-b3c95f1f19e7"
    $Core_spec_page_parent_no_dashes = "66447bc817f044bc81ed3cf4802e9b00"
    # PageBlock instance...
    $Core_spec_page = $Client.get_page($Core_spec_url)
    # json data for the page...
    $Jsonified_core_page = JSON.parse(File.read("./spec/fixtures/notion_page_response.json"))
    $Jsonified_response_block_one = JSON.parse(File.read("./spec/fixtures/notion_block_one_response.json"))
    $Jsonified_response_block_two = JSON.parse(File.read("./spec/fixtures/notion_block_two_response.json"))
    $Jsonified_response_collection_one = JSON.parse(File.read("./spec/fixtures/notion_collection_view_one_response.json"))
    $Jsonified_response_collection_one = JSON.parse(File.read("./spec/fixtures/notion_collection_view_two_response.json"))
    # test collection_view block IDs...
    $Test_collection_block_id_one = "f1664a99-165b-49cc-811c-84f37655908a"
    $Test_collection_block_id_two = "34d03794-ecdd-e42d-bb76-7e4aa77b6503"
    # test collection_view collection IDs...
    $Test_collection_id_one = "a83a6cc0-ce7a-a14e-4483-4bfea6756922"
    $Test_collection_id_two = "5ea0fa7c-00cd-4ee0-1915-8b5c423f8f3a"
    # test block IDs
    $Test_core_block_id_one = "1f5ae85f-f89f-4779-9fa4-b30c3b229cdb"
    $Test_core_block_id_two = "d7407d2c-adbb-497c-b99f-9f9d426d2b18"


    #! BLOCKS_SPEC.RB HELPERS
    

    #! constant IDs for the tests
    # $Page = $Client.get_page($Test_page_url)
    # $Test_page_id = "66447bc8-17f0-44bc-81ed-3cf4802e9b00"
    # $Test_page_url = "https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00"
    # $Test_page_id_two = "58614350-f17e-47b6-81d2-da757754eef3"
    # $Test_block_id_one = "ba87b719-9207-49a7-b646-de042b266ba8"
    # $Test_block_id_two = "9e0578f3-d4d7-4ed9-bda3-f050a6eb6dca"
    # $Test_block_randomized_title = "2488189f-2c91-4882-8bfe-6e1cc6f3be95"
    # $Test_block_to_convert = "bf9892b8-8c39-47a5-9d03-2dfab5e69179"
    # $Root_id = "f687f7de-7f4c-4a86-b109-941a8dae92d2"

    # #! constant JSON / data for the tests
    # @jsonified_response_page = Notion::Core.new.send("get_all_block_info", $Test_page_id, @body)
    # @jsonified_response_block_one = Notion::Core.new.send("get_all_block_info", $Test_block_id_one, @body)
    # @jsonified_response_block_two = Notion::Core.new.send("get_all_block_info", $Test_block_id_two, @body)
    # @jsonified_response_collection_one = Notion::Core.new.send("get_all_block_info", $Test_collection_id_one, @body)
    # @jsonified_response_collection_two = Notion::Core.new.send("get_all_block_info", $Test_collection_id_two, @body)
end