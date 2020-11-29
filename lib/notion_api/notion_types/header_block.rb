module NotionAPI

    # Header block: H1
    class HeaderBlock < BlockTemplate
      @notion_type = 'header'
      @type = 'header'
  
      def type
        NotionAPI::HeaderBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end