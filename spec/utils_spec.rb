require "notion_api"


describe Utils do
    context "testing the NotionAPI::Utils class" do
        describe "#create(block_id, block_type)" do 
            before(:context){
                @test_create = Utils::BlockComponents.create("1234", "page")
            }
            subject { @test_create }
            it "Should have an :id key set to 1234." do 
                expect(@test_create[:id]).to eq("1234")
            end
            it "Should have a :type key set to page." do 
                expect(@test_create[:args][:type]).to eq("page")
            end
            it "Should have a total of 5 keys." do 
                expect(@test_create.keys.length).to eq(5)
            end
            it "Should have a total of 5 keys that belong to args." do 
                expect(@test_create[:args].keys.length).to eq(5)
            end
        end
        describe "#title(id, title)" do
            before(:context){
                @test_title = Utils::BlockComponents.title("1234", "this is the title")
            }
            subject { @test_title }
            it "should have an :id key set to 1234" do 
                expect(@test_title[:id]).to eq("1234")
            end
            it "should have a :title key set to 'this is the title'" do
                expect(@test_title[:args]).to eq([["this is the title"]])
            end
            it "should have a total of 5 keys." do
                expect(@test_title.keys.length).to eq(5)
            end
        end
        describe "#last_edited_time(id)" do 
            before(:context){
                @test_last_edited_time = Utils::BlockComponents.last_edited_time("1234")
            }
            subject { @test_last_edited_time }
            it "should have a total of 5 keys" do
                expect(@test_last_edited_time.keys.length).to eq(5)
            end
            it "should have a :id key set to 1234" do
                expect(@test_last_edited_time[:id]).to eq("1234")
            end
        end
    end
end