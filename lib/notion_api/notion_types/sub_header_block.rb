module NotionAPI

    # SubHeader Block: H2
    class SubHeaderBlock < BlockTemplate
      @notion_type = 'sub_header'
      @type = 'sub_header'
  
      def type
        NotionAPI::SubHeaderBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end