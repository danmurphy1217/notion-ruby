require "notion_api"

describe NotionAPI::Client do
  context "testing the NotionAPI::Client class" do
    describe "#new with only token_v2" do
      before(:context){
        @client_one = NotionAPI::Client.new(ENV["token_v2"])
      }
      subject { @client_one }
      it "should create a new Client instance" do
        expect(@client_one).to be_an_instance_of(NotionAPI::Client)
      end
      it "should have a token_v2 attribute that is not nil" do 
        expect(@client_one.token_v2).to eq(ENV["token_v2"])
      end
      it "should have a nil active user header" do 
        expect(@client_one.active_user_header).to be_nil
      end
    end
    describe "#new with both parameters specified." do 
      before(:context){
        @client_two = NotionAPI::Client.new(ENV["token_v2"], "test_active_user_header")
      }
      subject { @client_two }
      it "should be a new Client instance" do 
        expect(@client_two).to be_an_instance_of(NotionAPI::Client)
      end
      it "should have a token_v2 attribute that is not nil" do 
        expect(@client_two.token_v2).to eq(ENV['token_v2'])
      end
      it "should have a non-nil active_user_header attribute" do
        expect(@client_two.active_user_header).to eq("test_active_user_header")
      end
    end
  end
end
