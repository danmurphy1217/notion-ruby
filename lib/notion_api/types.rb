require_relative "utils"
require "httparty"
require "date"
require "logger"
require_relative "payloads"

$LOGGER = Logger.new(STDOUT)
$LOGGER.level = Logger::INFO

module Notion
  class BlockTemplate < OperationTemplates
    include Utils

    @@method_urls = URLS
    attr_reader :type, :id, :title, :parent_id
    #! Base Template for all blocks. When a request is sent for a block,
    #! a specific block class instance is returned. The type of
    #! block class instance that is returned defines the methods
    #! and available functionality for the developer. Given this,
    #! many core methods surrounding updating data and accessing
    #! block attributes are defined here.
    def initialize(type, id, title, parent_id, options = {})
      @type = type
      @id = id
      @title = title
      @parent_id = parent_id
      @options = options
    end # initialize

    def title=(new_title)
      # TODO: add styling functionality that follows markdown guide...
      update_title(new_title)
      $LOGGER.info("Title changed from '#{self.title}' to '#{new_title}'")
      @title = new_title
    end # title=
    def self.notion_type
      @@notion_type
    end # self.notion_type
    
    def update_title(new_title, styles=[])
      # options are propagated from the initial get_block call.
      cookies = !@options["cookies"].nil? ? @options["cookies"] : { :token_v2.to_s => token_v2 }
      headers = !@options["headers"].nil? ? @options["headers"] : { "Content-Type" => "application/json" }
      request_url = @@method_urls[:UPDATE_BLOCK]
      timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i
      
      #! when updating a block, notion does three things:
      #! 1. If updating a title, notion will update the properties and title paths and set a new title
      #! 2. Then, Notion will update the last time that block was updated by accessing the last_edited_time path (this is done with the UNIX timestamp multiplied by 1000 [since they're using JS, and JS using the number of MS since epoch])
      #! 3. Then, Notion will update the last time the page that contains that block was updated (same UNIX timestamp x 1000).
      operations = [
        # UPDATE BLOCK TITLE
        {
          :id => @id,
          :table => "block",
          :path => ["properties", "title"],
          :command => "set",
          :args => [[new_title, styles.each {|style| [style]}]],
        },
        # UPDATE BLOCK ID LAST EDITED TIME
        {
          :table => "block",
          :id => @id,
          :path => [
            "last_edited_time",
          ],
          :command => "set",
          :args => timestamp,
        },
        # UPDATE PARENT IDs LAST EDITED TIME
        {
          :table => "block",
          :id => @parent_id,
          :path => [
            "last_edited_time",
          ],
          :command => "set",
          :args => timestamp,
        },
      ]
      
      request_body = title_and_styles_payload(@id, operations)
      
      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return response.body
    end # update_title
    def convert(block_class_to_convert_to, styles)
      #TODO: different blocks can take different params at the time of conversion, so there may be a better way to handle this.
      cookies = !@options["cookies"].nil? ? @options["cookies"] : { :token_v2.to_s => token_v2 } #TODO: fix this, this variable is undefined if they do not pass options
      headers = !@options["headers"].nil? ? @options["headers"] : { "Content-Type" => "application/json" }
      request_url = @@method_urls[:UPDATE_BLOCK]
      timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i
      operations = [
        {
            "id": @id,
            "table": "block",
            "path": [],
            "command": "update",
            "args": {
                "type" => block_class_to_convert_to.notion_type,
                # "block_color" => styles[:block_color] || "white"
            }
        },
        {
            "table": "block",
            "id": @id,
            "path": [
                "last_edited_time"
            ],
            "command": "set",
            "args": timestamp
        },
        {
            "table": "block",
            "id": @parent_id,
            "path": [
                "last_edited_time"
            ],
            "command": "set",
            "args": timestamp
        }
    ]

    request_body = convert_block_payload(operations)
    response = HTTParty.post(
      request_url,
      :body => request_body.to_json,
      :cookies => cookies,
      :headers => headers,
    )

    return block_class_to_convert_to.new(block_class_to_convert_to.notion_type, @id, @title, @parent_id, options={:cookies=>cookies, :headers=> headers})
    end
    def revert_most_recent_change
      #TODO: how can I store most recent change in a DS and revert a change if necessary?
    end # revert_most_recent_change
  end # BlockTemplate

  class DividerBlock < BlockTemplate
    # divider block: ---------
    @@notion_type = "divider"
    def self.notion_type
      @@notion_type
    end
  end

  class TodoBlock < BlockTemplate
    # To-Do block: can be set to X or nil, and also have a text property
    @@notion_type = "to_do"

    def self.notion_type
      @@notion_type
    end

    def checked=(checked_value)
      # request vars
      cookies = !@options["cookies"].nil? ? @options["cookies"] : { :token_v2.to_s => token_v2 }
      headers = !@options["headers"].nil? ? @options["headers"] : { "Content-Type" => "application/json" }
      timestamp = DateTime.now.strftime("%Q")
      request_url = @@method_urls[:UPDATE_BLOCK]

      accepted_yes_vals = ["1", "yes", "true"]
      accepted_no_vals = ["0", "no", "false"]
      all_accepted_values = (accepted_yes_vals << accepted_no_vals).flatten
      $LOGGER.info(all_accepted_values)
      downcased_value = checked_value.to_s.downcase
      if all_accepted_values.include?(downcased_value)
        if accepted_yes_vals.include?(downcased_value) then standardized_check_val="yes" else standardized_check_val="no" end
        $LOGGER.info(standardized_check_val)

        operations = [
          {
            "id": @id,
            "table": "block",
            "path": [
              "properties",
            ],
            "command": "update",
            "args": {
              "checked": [
                [
                  standardized_check_val,
                ],
              ],
            },
          },
          {
            "table": "block",
            "id": @id,
            "path": [
              "last_edited_time",
            ],
            "command": "set",
            "args": timestamp,
          },
          {
            "table": "block",
            "id": @parent_id,
            "path": [
              "last_edited_time",
            ],
            "command": "set",
            "args": timestamp,
          },
        ]
        request_body = update_block_payload(operations)
        response = HTTParty.post(
          request_url,
          :body => request_body.to_json,
          :cookies => cookies,
          :headers => headers,
        )
        return response.body
      else
        $LOGGER.error("#{checked_value} is not an accepted input value. If you want to check a To-Do block, use one of the following: 1, 'yes', of true. If you want to un-check a To-Do block, use one of the following: 0, 'no', false.")
      end
    end
  end

  class CodeBlocks < BlockTemplate
    # Code block: coding language and the code to assign to the block
    @@notion_type = "code"
    # args => {language => [["JavaScript"]], ty[e => "code"]}
    def self.notion_type
      @@notion_type
    end
  end

  class HeaderBlock < BlockTemplate
    # Header block: H1
    # header
    @@notion_type = "header"
    def self.notion_type
      @@notion_type
    end
  end

  class SubHeaderBlock < BlockTemplate
    # SubHeader Block: H2
    # sub_header
    @@notion_type = "sub_header"
    def self.notion_type
      @@notion_type
    end
  end

  class SubSubHeaderBlock < BlockTemplate
    # Sub-Sub Header Block: H3
    @@notion_type = "sub_sub_header"
    def self.notion_type
      @@notion_type
    end
  end

  class PageBlock < BlockTemplate
    @@notion_type = "page"
    def self.notion_type
      @@notion_type
    end
  end

  class ToggleBlock < BlockTemplate
    # Toggle block: Accepts text and a hash of children to create.
    @@notion_type = "toggle"
    def self.notion_type
      @@notion_type
    end
  end

  class BulletedBlock < BlockTemplate
    # Bullet list block: accepts the text to assign to the bullet point
    @@notion_type = "bulleted_list"
    def self.notion_type
      @@notion_type
    end
  end

  class NumberedBlock < BlockTemplate
    # Numbered list Block: accepts the content to assign to the numbered block
    @@notion_type = "numbered_list"
    def self.notion_type
      @@notion_type
    end
  end

  class QuoteBlock < BlockTemplate
    # accepts the content and the emoji to assign to the quote
    @@notion_type = "quote"
    def self.notion_type
      @@notion_type
    end
  end

  class CalloutBlock < BlockTemplate
    @@notion_type = "callout"
    def self.notion_type
      @@notion_type
    end
  end

  class LatexBlock < BlockTemplate
    @@notion_type = "equation"
    def self.notion_type
      @@notion_type
    end
  end
end # Notion

classes = Notion.constants.select { |c| Notion.const_get(c).is_a? Class and c.to_s != "BlockTemplate" }
notion_types = []
classes.each { |cls| notion_types.push(Notion.const_get(cls).notion_type) }
BLOCK_TYPES = notion_types.zip(classes).to_h