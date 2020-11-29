require_relative "template"

module NotionAPI
  # Bullet list block: best for an unordered list
  class BulletedBlock < BlockTemplate
    @notion_type = "bulleted_list"
    @type = "bulleted_list"

    def type
      NotionAPI::BulletedBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end
