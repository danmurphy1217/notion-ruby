module NotionAPI

    # no use case for this yet.
    class ColumnListBlock < BlockTemplate
      @notion_type = 'column_list'
      @type = 'column_list'
  
      def type
        NotionAPI::ColumnListBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end