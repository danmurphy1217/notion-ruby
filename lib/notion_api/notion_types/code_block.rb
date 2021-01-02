module NotionAPI

  # Code block: used to store code, should be assigned a coding language.
  class CodeBlock < BlockTemplate
    @notion_type = "code"
    @type = "code"

    def type
      NotionAPI::CodeBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end
