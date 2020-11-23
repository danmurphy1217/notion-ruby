require "notion_api"

describe Notion::Core do
  context "testing the Notion::Core public class methods" do
    describe "#get_page_errant" do
      it "should error due to incorrect URL/ID input or return a PageBlock." do
        expect { @client.get_page("66447bc817f044bc81ed3cf4802e9b0") }.to raise_error(ArgumentError)
        expect { @client.get_page("66447bc817f044bc81ed3cf4802e9b001") }.to raise_error(ArgumentError)
      end
    end

    describe "#get_page" do
      it "should error due to incorrect URL/ID input or return a PageBlock." do
        expect { @client.get_page($Test_page_id_no_dashes) }.not_to raise_error
        @page = @client.get_page($Test_page_id_no_dashes)
        expect(@page.title).to eq("Notion API Testing")
        expect(@page.type).to eq("page")
        expect(@page.id).to eq($Test_page_id)
        expect(@page.parent_id).to eq("f687f7de-7f4c-4a86-b109-941a8dae92d2")
        expect(@page.id.gsub("-", "")).to eq($Test_page_id_no_dashes)
      end
    end

    describe "#children" do
      it "should return an array of instantiated blocks relating to the children on the page." do
        @page = @client.get_page($Test_page_id)
        @children = @page.children
        expect(@children[0].title).to eq("16:22:06 on November 20 2020")
        expect(@children[0].type).to eq("bulleted_list")
        expect(@children[0].id).to eq("1f5ae85f-f89f-4779-9fa4-b30c3b229cdb")
        expect(@children[0].parent_id).to eq($Test_page_id)
      end
    end

    describe "#children_ids" do
      it "should return an array of children IDs relating to the children on the page." do
        @page = @client.get_page($Test_page_id)
        @children = @page.children
        @children_ids = @page.children_ids
        expect(@children[0].type).to eq(@page.get_block(@children_ids[0]).type)
        expect(@children[0].title).to eq(@page.get_block(@children_ids[0]).title)

        expect(@children[-1].type).to eq(@page.get_block(@children_ids[-1]).type)
        expect(@children[-1].title).to eq(@page.get_block(@children_ids[-1]).title)
        expect(@children_ids.length).to eq(@children.length)
      end
    end
  end
  context "testing the Notion::Core private methods" do
    describe "#get_notion_id" do
      it "should return the User Notion ID sent from Notion in the response headers." do
        expect(Notion::Core.new.send("get_notion_id", @body)).to eq(ENV["user_notion_id"])
      end
    end

    describe "#get_last_page_block_id" do
      it "should return the User Notion ID sent from Notion in the response headers." do
        @page = @client.get_page($Test_page_id)
        @children_ids = @page.children_ids
        expect(Notion::Core.new.send("get_last_page_block_id", $Test_page_id_no_dashes)).to eq(@children_ids[-1])
      end
    end

    describe "#get_all_block_info" do
      it "should return all record information pertaining to a Notion Block." do
        expect(@jsonified_response_page.keys).to eq(["block", "space", "collection_view", "collection"]).or(eq([]))
      end
    end

    describe "#extract_title" do
      it "should extract the title of a block and return it" do
        expect(Notion::Core.new.send("extract_title", $Test_page_id, @jsonified_response_page)).to eq("Notion API Testing").or(eq(nil))
        expect(Notion::Core.new.send("extract_title", $Test_block_id_one, @jsonified_response_page)).to eq("16:22:08 on November 20 2020").or(eq(nil))
        expect(Notion::Core.new.send("extract_title", $Test_block_id_two, @jsonified_response_page)).to eq("16:22:15 on November 20 2020").or(eq(nil))
      end
    end
    describe "#extract_collection_title" do
      it "should extract the title of a collection and return it" do
        @page = @client.get_page($Test_page_id)
        @collection_one_id = @page.get_collection($Test_collection_id_one).collection_id
        @collection_two_id = @page.get_collection($Test_collection_id_two).collection_id
        expect(Notion::Core.new.send("extract_collection_title", $Test_collection_id_one, @collection_one_id, @jsonified_response_page)).to eq("Test Emoji Data")
        expect(Notion::Core.new.send("extract_collection_title", $Test_collection_id_two, @collection_two_id, @jsonified_response_page)).to eq("Test Car Data")
      end
    end
    describe "#extract_type" do
      it "should extract the type of a block and return it" do
        expect(Notion::Core.new.send("extract_type", $Test_page_id, @jsonified_response_page)).to eq("page").or(eq(nil))
        expect(Notion::Core.new.send("extract_type", $Test_block_id_one, @jsonified_response_page)).to eq("numbered_list").or(eq(nil))
        expect(Notion::Core.new.send("extract_type", $Test_block_id_two, @jsonified_response_page)).to eq("code").or(eq(nil))
      end
    end
    describe "#extract_children_ids" do
      it "should extract the children IDs of a block and return it. If a block has no children, returns {}." do
        @page = @client.get_page($Test_page_id)
        @children_ids = @page.children_ids
        expect(Notion::Core.new.send("extract_children_ids", $Test_page_id, @jsonified_response_page).length).to eq(@children_ids.length).or(eq(0)) # backup in case get_block returns {}
        expect(Notion::Core.new.send("extract_children_ids", $Test_block_id_one, @jsonified_response_block_one).length).to eq(@page.get_block($Test_block_id_one).children_ids.length).or(eq(0)) # backup in case get_block returns {}
        expect(Notion::Core.new.send("extract_children_ids", $Test_block_id_two, @jsonified_response_block_two)).to be_nil.or(be_an_instance_of(Array))
      end
    end
    describe "#extract_parent_id" do
      it "should return the parent id of the object the method is invoked on." do
        @page = @client.get_page($Test_page_id)
        @parent_id = @page.parent_id
        @id = @page.id
        expect(Notion::Core.new.send("extract_parent_id", $Test_page_id, @jsonified_response_page)).to eq($Root_id).or(eq({}))
        expect(Notion::Core.new.send("extract_parent_id", $Test_block_id_one, @jsonified_response_block_one)).to eq(@id).or(eq({}))
        expect(Notion::Core.new.send("extract_parent_id", $Test_block_id_two, @jsonified_response_block_two)).to eq(@id).or(eq({}))
      end
    end
    describe "#extract_collection_id" do
      it "should return the collection id of the Collection View object the method is invoked on." do
        @page = @client.get_page($Test_page_id)
        @collection_one_id = @page.get_collection($Test_collection_id_one).collection_id
        @collection_two_id = @page.get_collection($Test_collection_id_two).collection_id
        expect(Notion::Core.new.send("extract_collection_id", $Test_collection_id_one, @jsonified_response_collection_one)).to eq(@collection_one_id).or(eq({}))
        expect(Notion::Core.new.send("extract_collection_id", $Test_collection_id_two, @jsonified_response_collection_two)).to eq(@collection_two_id).or(eq({}))
      end
    end
    describe "#extract_view_ids" do
      it "should return the view ids of the Collection View object the method is invoked on." do
        @page = @client.get_page($Test_page_id)
        @collection_one_id = @page.get_collection($Test_collection_id_one).collection_id
        @collection_two_id = @page.get_collection($Test_collection_id_two).collection_id
        expect(Notion::Core.new.send("extract_view_ids", $Test_collection_id_one, @jsonified_response_collection_one)).to be_an_instance_of(Array)
        expect(Notion::Core.new.send("extract_view_ids", $Test_collection_id_two, @jsonified_response_collection_two)).to be_an_instance_of(Array)
      end
    end
    describe "#extract_id" do
      it "should return the cleaned ID of the URL or ID passed." do
        expect(Notion::Core.new.send("extract_id", $Test_page_id)).to eq($Test_page_id)
        expect(Notion::Core.new.send("extract_id", $Test_page_id.gsub("-", ""))).to eq($Test_page_id)
        expect(Notion::Core.new.send("extract_id", $Test_page_url)).to eq($Test_page_id)
      end
    end
  end
end
