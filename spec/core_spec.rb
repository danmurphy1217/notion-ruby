require "notion_api"

describe Notion::Core do
  context "testing the Notion::Core class" do
    describe "#get_page_errant" do
      it "should error due to incorrect URL/ID input or return a PageBlock." do
        expect { @client.get_page("66447bc817f044bc81ed3cf4802e9b0") }.to raise_error(ArgumentError)
        expect { @client.get_page("66447bc817f044bc81ed3cf4802e9b001") }.to raise_error(ArgumentError)
      end
    end

    describe "#get_page" do
      it "should error due to incorrect URL/ID input or return a PageBlock." do
        expect { @client.get_page("66447bc817f044bc81ed3cf4802e9b00") }.not_to raise_error
        @page = @client.get_page("66447bc817f044bc81ed3cf4802e9b00")
        expect(@page.title).to eq("Notion API Testing")
        expect(@page.type).to eq("page")
        expect(@page.id).to eq("66447bc8-17f0-44bc-81ed-3cf4802e9b00")
        expect(@page.parent_id).to eq("f687f7de-7f4c-4a86-b109-941a8dae92d2")
        expect(@page.id.gsub("-", "")).to eq("66447bc817f044bc81ed3cf4802e9b00")
      end
    end

    describe "#children" do
      it "should return an array of instantiated blocks relating to the children on the page." do
        @page = @client.get_page("66447bc8-17f0-44bc-81ed-3cf4802e9b00")
        @children = @page.children
        expect(@children[0].title).to eq("16:22:06 on November 20 2020")
        expect(@children[0].type).to eq("bulleted_list")
        expect(@children[0].id).to eq("1f5ae85f-f89f-4779-9fa4-b30c3b229cdb")
        expect(@children[0].parent_id).to eq("66447bc8-17f0-44bc-81ed-3cf4802e9b00")
      end
    end

    describe "#children_ids" do
        it "should return an array of children IDs relating to the children on the page." do
          @page = @client.get_page("66447bc8-17f0-44bc-81ed-3cf4802e9b00")
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
end
