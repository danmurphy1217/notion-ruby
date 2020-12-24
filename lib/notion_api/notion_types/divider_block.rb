module NotionAPI
  # divider block: ---------
  class DividerBlock < BlockTemplate
    @notion_type = "divider"
    @type = "divider"

    def type
      NotionAPI::DividerBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end
