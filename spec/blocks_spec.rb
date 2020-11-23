require "notion_api"

describe Notion::BlockTemplate do
  context "testing the Notion::BlockTemplate public class methods" do
    describe "#title=" do
        it "should update the title of the block the method is invoked on." do 
            @block = @page.get_block($Test_block_randomized_title)
            old_title = @block.title
            new_title = SecureRandom.hex(n = 16)
            expect(@block).not_to eq(new_title)
            expect(@block.title).to eq(old_title)
            @block.title= new_title
            expect(@block.title).to eq(new_title)
            expect(@block.title).not_to eq(old_title)
        end
    end
    describe "#convert" do
        it "should convert the block to a different type and return the new block." do 
            @block = @page.get_block($Test_block_to_convert)
            filtered_classes = Classes.select {|cls| cls != :CollectionView}
            number_of_classes = filtered_classes.length 
            class_for_conversion = filtered_classes[rand(0...number_of_classes)]
            notion_class_object = Notion.const_get(class_for_conversion.to_s)
            @converted_block = @block.convert(notion_class_object)

            expect(@converted_block.type).to eq(notion_class_object.notion_type)
            expect(@converted_block.title).to eq(@block.title)
            expect(@converted_block.id).to eq(@block.id)
            expect(@converted_block.parent_id).to eq(@block.parent_id)
        end
    end
    describe "#duplicate" do
        it "should duplicate the block the method is invoked on." do 
            @children = @page.children_ids
            @block = @page.get_block(@children[rand(0...@children.length - 2)]) # select a random block to duplicate minus the two collection views
            @duplicated_block = @block.duplicate
            
            expect(@duplicated_block.type).to eq(@block.type)
            expect(@duplicated_block.title).to eq(@block.title)
            expect(@duplicated_block.id).not_to eq(@block.id)
            expect(@duplicated_block.parent_id).to eq(@block.parent_id)
        end
    end
    describe "#move" do
        it "should move the block the method is invoked on to a new location after or before the target_block." do 
            @children = @page.children_ids
            @block = @page.get_block(@children[rand(0...@children.length - 2)]) # select a random block to duplicate minus the two collection views
            initialize_parent_id = @block.parent_id
            @target_block_one = @page.get_block("c30f098a-c8c5-41bd-933a-04d0774a8e6b") # moves block to new page
            
            @block.move(@target_block_one) # new block with new parent ID
            expect(@block.parent_id).not_to eq(initialize_parent_id)
        end
    end
  end
  context "testing the Notion::BlockTemplate private class methods" do
  end
end
