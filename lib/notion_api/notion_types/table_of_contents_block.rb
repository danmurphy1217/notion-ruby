module NotionAPI
  # maps out the headers - sub-headers - sub-sub-headers on the page
  class TableOfContentsBlock < BlockTemplate
    @notion_type = 'table_of_contents'
    @type = 'table_of_contents'

    def type
      NotionAPI::TableOfContentsBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end