require "notion_api"

describe NotionAPI::Client do
  context "testing the NotionAPI::Client class" do
    describe "#new" do
      it "should create a new Client instance with token_v2 and active_user_header attributes." do
        @client = NotionAPI::Client.new(ENV["token_v2"])
        expect(@client).to be_an_instance_of(NotionAPI::Client)
        expect(@client.token_v2).to eq(ENV["token_v2"])
        expect(@client.active_user_header).to be_nil
      end
    end
  end
end
