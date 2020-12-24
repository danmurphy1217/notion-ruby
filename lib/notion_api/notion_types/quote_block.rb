module NotionAPI

  # best for memorable information
  class QuoteBlock < BlockTemplate
    @notion_type = "quote"
    @type = "quote"

    def type
      NotionAPI::QuoteBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end
