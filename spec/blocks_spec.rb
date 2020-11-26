require "notion_api"

describe NotionAPI::BlockTemplate do
  context "testing the NotionAPI::BlockTemplate public class methods" do
    describe "#title=" do
      it "should update the title of the block the method is invoked on." do
        @block = $Block_spec_page.get_block($Block_spec_title_id)
        old_title = @block.title
        new_title = SecureRandom.hex(n = 16)
        expect(old_title).not_to eq(new_title)
        expect(@block.title).to eq(old_title)
        @block.title = new_title # update title
        expect(@block.title).to eq(new_title)
        expect(@block.title).not_to eq(old_title)
      end
    end
    describe "#convert" do
      it "should convert the block to a different type and return the new block." do
        @block = $Block_spec_page.get_block($Block_spec_convert_id)
        filtered_classes = Classes.select { |cls| !%w[:CollectionView :CollectionViewRow].include?(cls)}
        number_of_classes = filtered_classes.length
        class_for_conversion = filtered_classes[rand(0...number_of_classes)]
        notion_class_object = NotionAPI.const_get(class_for_conversion.to_s)
        @converted_block = @block.convert(notion_class_object)

        expect(@converted_block.type).to eq(notion_class_object.notion_type)
        expect(@converted_block.title).to eq(@block.title)
        expect(@converted_block.id).to eq(@block.id)
        expect(@converted_block.parent_id).to eq(@block.parent_id)
      end
    end
    describe "#duplicate_no_target" do
      it "should duplicate the block the method is invoked on." do
        @block = $Block_spec_page.get_block($Block_spec_duplicate_id_one)
        @duplicated_block = @block.duplicate

        expect(@duplicated_block.type).to eq(@block.type)
        expect(@duplicated_block.title).to eq(@block.title)
        expect(@duplicated_block.id).not_to eq(@block.id)
        expect(@duplicated_block.parent_id).to eq(@block.parent_id)
      end
    end
    describe "#duplicate_with_target" do
      it "should duplicate the block the method is invoked on in the specified location." do
        @block = $Block_spec_page.get_block($Block_spec_duplicate_id_one)
        @target = $Block_spec_sub_page.get_block($Block_spec_duplicate_id_target)
        @duplicated_block = @block.duplicate(@target.id)

        expect(@duplicated_block.type).to eq(@block.type)
        expect(@duplicated_block.title).to eq(@block.title)
        expect(@duplicated_block.id).not_to eq(@block.id)
        expect(@duplicated_block.parent_id).not_to eq(@block.parent_id) # ! should not have same parent
      end
    end
    describe "#move" do
      it "should move the block the method is invoked on to a new location after or before the target_block." do
        @new_block = $Block_spec_move_page.create(NotionAPI::TextBlock, 'I\'ll be moved...')
        initial_parent_id = @new_block.parent_id
        initial_title = @new_block.title
        initial_id = @new_block.id
        initial_type = @new_block.type
        @target_block = $Block_spec_move_page.get_block($Block_spec_move_id_target) # moves block to new page

        @new_block.move(@target_block) # move to new page...
        expect(@new_block.parent_id).not_to eq(initial_parent_id)
        expect(@new_block.title).to eq(initial_title)
        expect(@new_block.id).to eq(initial_id)
        expect(@new_block.type).to eq(initial_type)
      end
    end
    describe "#get_collection" do
        it "should return a collection block." do
            @collection = $Block_spec_get_page.get_collection($Block_spec_get_collection_id)
            expect(@collection.title).to eq("Copy of Test Car Data")
            
            i = 0
            $Vehicle_data_csv.split("\n").each {|r| i += 1}

            @rows = @collection.rows

            expect(@collection.row_ids.length).to eq(45).and(eq(i - 1))
            expect(@rows.length).to eq(45).and(eq(i - 1))
            
            # ! row parent should == collection parent should == page ID
            expect(@rows[0].parent_id).to eq(@collection.parent_id)
            expect(@rows[0].parent_id).to eq($Block_spec_get_page.id)
        end
    end
    describe "#create_collection" do
        it "should create a collection view table and return it." do
          title = "Emoji Data: #{DateTime.now.strftime('%Q')}"  
          @collection = $Block_spec_create_page.create_collection("table", title, $Json)
          expect(@collection.title).to eq(title)
          expect(@collection.row_ids.length).to eq($Json.length)
          @rows = @collection.rows
          # ! ensure correct order of mapping...
          @rows.each_with_index do |row, i|
            expect(@collection.row(@rows[i].id)['emoji']).to eq([$Json[i]["emoji"]])
          end
        end
    end
    describe "#add_row" do
        it "should create a collection view table and return it." do
          @collection = $Block_spec_add_page.get_collection($Block_spec_add_row_id)
          
          # ! column values
          @col_one = "#{SecureRandom.hex(16)}"
          @col_two = "https://www.electronjs.org/"
          @col_three = "#{DateTime.now.strftime('%Q')}"
          @col_six = "danielmurph8@gmail.com"
          @col_seven = "3028934649"

          @json_data = {"Col One" => "#{SecureRandom.hex(16)}", "Col Two" => @col_two, "Col Three" => @col_three, "Col Four" => @col_three, "Col Five" => @col_two, "Col Six" => @col_six, "Col Seven" => @col_seven}
          @new_row = @collection.add_row(@json_data)
          @new_row_info = @collection.row(@new_row.id)
          
          @col_names = @json_data.keys

          @col_names.each do |col_name|
            expect(@new_row_info[col_name]).to eq([@json_data[col_name]])
          end
        end
    end
  end
  context "testing the Notion::BlockTemplate private class methods" do
    describe "#get" do
        it "should return a block instance." do
            $Blocks = $Block_spec_get_page.send('get', $Block_spec_get_id)
            expect($Blocks).to be_an_instance_of(NotionAPI::TodoBlock)
            expect($Blocks.id).to eq($Block_spec_get_id)
            expect($Blocks.parent_id).to eq($Block_spec_get_page.id)
            expect($Blocks.title).to eq("TODO Block")
        end
      end
  end
end