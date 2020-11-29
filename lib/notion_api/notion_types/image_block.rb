module NotionAPI

    # good for visual information
    class ImageBlock < BlockTemplate
      @notion_type = 'image'
      @type = 'image'
  
      def type
        NotionAPI::ImageBlock.notion_type
      end
  
      class << self
        attr_reader :notion_type, :type
      end
    end
end