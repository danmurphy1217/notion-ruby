module NotionAPI
    # Numbered list Block: best for an ordered list
    class NumberedBlock < BlockTemplate
      @notion_type = 'numbered_list'
      @type = 'numbered_list'
  
      def type
        NotionAPI::NumberedBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end