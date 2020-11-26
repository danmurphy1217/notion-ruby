module Helpers
    #! CONSTANTS
    $Client = NotionAPI::Client.new(ENV["token_v2"])
    
    #! CORE_SPEC.RB HELPERS
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
    $Body = { :pageId => $Core_spec_page_id, :chunkNumber => 0, :limit => 100, :verticalColumns => false }


    #! BLOCKS_SPEC.RB HELPERS
    $Block_spec_url = "https://www.notion.so/danmurphy/BLOCKS-RB-TESTS-b94758d4e7df4af8863fb90c11b35fff"
    $Block_spec_sub_url = "https://www.notion.so/danmurphy/sub-blocks-37f78a617d8b47988869368a18bcb791"
    $Block_spec_page_url = "https://www.notion.so/danmurphy/Page-for-move-dc6febdbefac4fbc8eed70232e20454e"
    $Block_spec_get_url = "https://www.notion.so/danmurphy/Page-for-gets-b8d4eb9b27634044863b544ff2d542e9"
    $Block_spec_create_url = "https://www.notion.so/danmurphy/Page-for-creates-4518d1fce157451f937827605dd1fbe4"
    $Block_spec_add_url = "https://www.notion.so/danmurphy/Page-for-add-rows-15fd6f2e99014f869ecc5b059a69da79"
    $Block_spec_page = $Client.get_page($Block_spec_url)
    $Block_spec_sub_page = $Client.get_page($Block_spec_sub_url)
    $Block_spec_move_page = $Client.get_page($Block_spec_page_url)
    $Block_spec_get_page = $Client.get_page($Block_spec_get_url)
    $Block_spec_create_page = $Client.get_page($Block_spec_create_url)
    $Block_spec_add_page = $Client.get_page($Block_spec_add_url)

    $Block_spec_title_id = "5e5f1ec2-8af4-429e-bcb2-bac6d6f49798"
    $Block_spec_convert_id = "5f363f19-3dc6-4458-9c20-f2202d749729"
    $Block_spec_duplicate_id_one = "b240e279-df40-4d36-b3b1-dbc419abbcd8"
    $Block_spec_duplicate_id_target = "b61f8da8-7bf4-4149-891a-5a043d83fc46"
    $Block_spec_move_id_target = "45cd1ef1-7130-427e-99e2-f49ba558222a"
    $Block_spec_get_id = "d2580628-2e93-4a0c-a23a-1efb116b4a99"
    $Block_spec_get_collection_id = "3224c94f-e660-4092-9dba-d26b69b68d40"
    $Block_spec_add_row_id = "eaa144ab-d91b-4640-b13a-a0ba1c8dd450"
    $Vehicle_data_csv = File.read("./spec/fixtures/vauto_inventory.csv")
    $Json = JSON.parse(File.read("./spec/fixtures/emoji_data.json"))
end