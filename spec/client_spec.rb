require "notion_api"

describe Notion::Client do
  context "testing the Notion::Client class" do
    describe "#new" do
      it "should create a new Client instance with token_v2 and active_user_header attributes." do
        @client = Notion::Client.new(ENV["token_v2"])
        expect(@client).to be_an_instance_of(Notion::Client)
        expect(@client.token_v2).to eq(ENV["token_v2"])
        expect(@client.active_user_header).to be_nil
      end
    end
    
    describe "#get_page" do
      it "should retrieve a Notion page." do
          @client = Notion::Client.new(ENV["token_v2"])
          @page = @client.get_page("https://www.notion.so/danmurphy/Testing-66447bc817f044bc81ed3cf4802e9b00")
          expect(@page.title).to eq("Notion API Testing")
          expect(@page.children_ids).to be_an_instance_of(Array)
          # expect(@page.children).to be_an_instance_of(Array)
          expect(@page).to be_an_instance_of(Notion::PageBlock)
      end
    end
  end
end
