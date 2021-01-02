module NotionAPI

  # Toggle block: best for storing children blocks
  class ToggleBlock < BlockTemplate
    @notion_type = "toggle"
    @type = "toggle"

    def type
      NotionAPI::ToggleBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end
