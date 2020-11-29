module NotionAPI

    # Sub-Sub Header Block: H3
    class SubSubHeaderBlock < BlockTemplate
      @notion_type = 'sub_sub_header'
      @type = 'sub_sub_header'
  
      def type
        NotionAPI::SubSubHeaderBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end