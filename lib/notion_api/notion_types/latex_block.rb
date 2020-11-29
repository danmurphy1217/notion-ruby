module NotionAPI

    # simiilar to code block but for mathematical functions.
    class LatexBlock < BlockTemplate
      @notion_type = 'equation'
      @type = 'equation'
  
      def type
        NotionAPI::LatexBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end