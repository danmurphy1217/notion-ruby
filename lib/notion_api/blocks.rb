require_relative "notion_types/template"
require_relative "notion_types/bulleted_block"
require_relative "notion_types/callout_block"
require_relative "notion_types/code_block"
require_relative "notion_types/collection_view_blocks"
require_relative "notion_types/column_list_block"
require_relative "notion_types/divider_block"
require_relative "notion_types/quote_block"
require_relative "notion_types/page_block"
require_relative "notion_types/image_block"
require_relative "notion_types/latex_block"
require_relative "notion_types/numbered_block"
require_relative "notion_types/header_block"
require_relative "notion_types/sub_header_block"
require_relative "notion_types/sub_sub_header"
require_relative "notion_types/table_of_contents_block"
require_relative "notion_types/text_block"
require_relative "notion_types/todo_block"
require_relative "notion_types/toggle_block"
require_relative "notion_types/link_block"

Classes = NotionAPI.constants.select { |c| NotionAPI.const_get(c).is_a? Class and c.to_s != 'BlockTemplate' and c.to_s != 'Core' and c.to_s !='Client' }
notion_types = []
Classes.each { |cls| notion_types.push(NotionAPI.const_get(cls).notion_type) }
BLOCK_TYPES = notion_types.zip(Classes).to_h