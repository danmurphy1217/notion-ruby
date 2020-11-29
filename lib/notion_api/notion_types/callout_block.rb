module NotionAPI

    # same as quote... works similarly to page block
    class CalloutBlock < BlockTemplate
      @notion_type = 'callout'
      @type = 'callout'
  
      def type
        NotionAPI::CalloutBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end