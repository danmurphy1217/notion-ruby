module NotionAPI

    # good for just about anything (-:
    class TextBlock < BlockTemplate
      @notion_type = 'text'
      @type = 'text'
  
      def type
        NotionAPI::TextBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end