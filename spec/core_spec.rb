require "notion_api"

describe Notion::Core do
  context "testing the Notion::Core public class methods" do
    describe "#get_page_errant" do
      it "should error due to incorrect URL/ID input." do
        expect { $Client.get_page($Core_spec_invalid_url_one) }.to raise_error(ArgumentError)
        expect { $Client.get_page($Core_spec_invalid_url_two) }.to raise_error(ArgumentError)
      end
    end

    describe "#get_page" do
      it "should return a PageBlock." do
        expect { $Client.get_page($Core_spec_page_id_no_dashes) }.not_to raise_error
        expect($Core_spec_page.title).to eq("CORE.RB TESTS")
        expect($Core_spec_page.type).to eq("page")
        expect($Core_spec_page.id).to eq($Core_spec_page_id)
        expect($Core_spec_page.parent_id.gsub("-", "")).to eq($Core_spec_page_parent_no_dashes)
        expect($Core_spec_page.id.gsub("-", "")).to eq($Core_spec_page_id_no_dashes)
      end
    end

    describe "#children" do
      it "should return an array of block classes relating to the children of the block this method is invoked on." do
        @children = $Core_spec_page.children
        expect(@children[0].title).to eq("first block for testing purposes...")
        expect(@children[0].type).to eq("bulleted_list")
        expect(@children[0].id).to eq($Test_core_block_id_one)
        expect(@children[0].parent_id).to eq($Core_spec_page.id)
      end
    end

    describe "#children_ids" do
      it "should return an array of children IDs relating to the children on the page." do
        @children = $Core_spec_page.children
        @children_ids = $Core_spec_page.children_ids
        expect(@children[0].type).to eq($Core_spec_page.get_block(@children_ids[0]).type)
        expect(@children[0].title).to eq($Core_spec_page.get_block(@children_ids[0]).title)

        expect(@children[-1].type).to eq($Core_spec_page.get_block(@children_ids[-1]).type)
        expect(@children[-1].title).to eq($Core_spec_page.get_block(@children_ids[-1]).title)
        expect(@children_ids.length).to eq(@children.length)
      end
    end
  end

  context "testing the Notion::Core private methods" do
    describe "#get_notion_id" do
      it "should return the User Notion ID sent from Notion in the response headers." do
        expect(Notion::Core.new.send("get_notion_id", $Body)).to eq(ENV["user_notion_id"])
      end
    end

    describe "#get_last_page_block_id" do
      it "should return the User Notion ID sent from Notion in the response headers." do
        @children_ids = $Core_spec_page.children_ids
        expect(Notion::Core.new.send("get_last_page_block_id", $Core_spec_page_id_no_dashes)).to eq(@children_ids[-1])
      end
    end

    describe "#get_all_block_info" do
      it "should return all record information pertaining to a Notion Block." do
        expect($Jsonified_core_page.keys).to eq(["block", "space"]).or(eq(["block", "space", "collection_view", "collection"])) # if collection view block...
      end
    end

    describe "#extract_title" do
      it "should extract the title of a block and return it" do
        expect(Notion::Core.new.send("extract_title", $Core_spec_page_id, $Jsonified_core_page)).to eq("CORE.RB TESTS")
        expect(Notion::Core.new.send("extract_title", $Test_core_block_id_one, $Jsonified_core_page)).to eq("first block for testing purposes...")
        expect(Notion::Core.new.send("extract_title", $Test_core_block_id_two, $Jsonified_core_page)).to eq("second block for testing purposes...")
      end
    end
    describe "#extract_collection_title" do
      it "should extract the title of a collection and return it" do
        @collection_one_id = $Core_spec_page.get_collection($Test_collection_block_id_one).collection_id
        @collection_two_id = $Core_spec_page.get_collection($Test_collection_block_id_two).collection_id
        expect(Notion::Core.new.send("extract_collection_title", $Test_collection_block_id_one, @collection_one_id, $Jsonified_core_page)).to eq("Test Emoji Data")
        expect(Notion::Core.new.send("extract_collection_title", $Test_collection_block_id_two, @collection_two_id, $Jsonified_core_page)).to eq("Test Car Data")
      end
    end
    describe "#extract_type" do
      it "should extract the type of a block and return it" do
        expect(Notion::Core.new.send("extract_type", $Core_spec_page_id, $Jsonified_core_page)).to eq("page")
        expect(Notion::Core.new.send("extract_type", $Test_core_block_id_one, $Jsonified_core_page)).to eq("bulleted_list")
        expect(Notion::Core.new.send("extract_type", $Test_core_block_id_two, $Jsonified_core_page)).to eq("text")
      end
    end
    describe "#extract_parent_id" do
      it "should return the parent id of the object the method is invoked on." do
        expect(Notion::Core.new.send("extract_parent_id", $Core_spec_page_id, $Jsonified_core_page).gsub("-", "")).to eq($Core_spec_page_parent_no_dashes)
        expect(Notion::Core.new.send("extract_parent_id", $Test_core_block_id_one, $Jsonified_response_block_one)).to eq($Core_spec_page_id)
        expect(Notion::Core.new.send("extract_parent_id", $Test_core_block_id_two, $Jsonified_response_block_two)).to eq($Core_spec_page_id)
      end
    end
    describe "#extract_collection_id" do
      it "should return the collection id of the Collection View object the method is invoked on." do
        expect(Notion::Core.new.send("extract_collection_id", $Test_collection_block_id_one, $Jsonified_core_page)).to eq($Test_collection_id_one)
        expect(Notion::Core.new.send("extract_collection_id", $Test_collection_block_id_two, $Jsonified_core_page)).to eq($Test_collection_id_two)
      end
    end
    describe "#extract_view_ids" do
      it "should return the view ids of the Collection View object the method is invoked on." do
        expect(Notion::Core.new.send("extract_view_ids", $Test_collection_block_id_one, $Jsonified_core_page)).to be_an_instance_of(Array)
        expect(Notion::Core.new.send("extract_view_ids", $Test_collection_block_id_two, $Jsonified_core_page)).to be_an_instance_of(Array)
      end
    end
    describe "#extract_id" do
      it "should return the cleaned ID of the URL or ID passed." do
        expect(Notion::Core.new.send("extract_id", $Core_spec_page_id)).to eq($Core_spec_page_id)
        expect(Notion::Core.new.send("extract_id", $Core_spec_page_id).gsub("-", "")).to eq($Core_spec_page_id_no_dashes)
        expect(Notion::Core.new.send("extract_id", $Core_spec_url)).to eq($Core_spec_page_id)
      end
    end
  end
end
