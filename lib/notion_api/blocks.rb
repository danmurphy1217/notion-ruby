require_relative "utils"
require_relative "core"

require "httparty"
require "date"
require "logger"

$LOGGER = Logger.new(STDOUT)
$LOGGER.level = Logger::INFO

module Notion
  class BlockTemplate < Core
    #! Base Template for all blocks. Inherits core methods from the Block class defined in block.rb
    include Utils

    attr_reader :type, :id, :title, :parent_id
    $Components = Utils::BlockComponents
    $CollectionViewComponents = Utils::CollectionViewComponents

    def initialize(id, title, parent_id)
      @id = id
      @title = title
      @parent_id = parent_id
    end # initialize

    def title=(new_title)
      #! Change the title of a block.
      #! new_title -> new title for the block : ``str``
      request_id = extract_id(SecureRandom.hex(n = 16))
      transaction_id = extract_id(SecureRandom.hex(n = 16))
      space_id = extract_id(SecureRandom.hex(n = 16))
      update_title(new_title.to_s, request_id, transaction_id, space_id)
      $LOGGER.info("Title changed from '#{self.title}' to '#{new_title}'")
      @title = new_title
      return true
    end # title=

    def convert(block_class_to_convert_to)
      #! convert a block from its current type to another.
      #! block_class_to_convert_to -> the type of block to convert to : ``cls``
      if self.type == block_class_to_convert_to.notion_type
        # if converting to same type, skip and return self
        return self
      else
        # setup cookies, headers, and grab/create static vars for request
        cookies = @@options["cookies"]
        headers = @@options["headers"]
        request_url = @@method_urls[:UPDATE_BLOCK]
        timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i

        # set random IDs for request
        request_id = extract_id(SecureRandom.hex(n = 16))
        transaction_id = extract_id(SecureRandom.hex(n = 16))
        space_id = extract_id(SecureRandom.hex(n = 16))
        request_ids = {
          :request_id => request_id,
          :transaction_id => transaction_id,
          :space_id => space_id,
        }

        # build hash's that contain the operations to send to Notions backend
        convert_type_hash = $Components.convert_type(@id, block_class_to_convert_to)
        last_edited_time_parent_hash = $Components.last_edited_time(@parent_id)
        last_edited_time_child_hash = $Components.last_edited_time(@id)

        operations = [
          convert_type_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash,
        ]

        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          :body => request_body.to_json,
          :cookies => cookies,
          :headers => headers,
        )

        return block_class_to_convert_to.new(@id, @title, @parent_id)
      end
    end

    def duplicate(target_block = nil)
      #! duplicate the block that this method is invoked upon.
      #! target_block -> the block to place the duplicated block after. Can be any valid Block ID! : ``str``
      cookies = @@options["cookies"]
      headers = @@options["headers"]
      request_url = @@method_urls[:UPDATE_BLOCK]
      timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.not.to_i

      new_block_id = extract_id(SecureRandom.hex(n = 16))
      request_id = extract_id(SecureRandom.hex(n = 16))
      transaction_id = extract_id(SecureRandom.hex(n = 16))
      space_id = extract_id(SecureRandom.hex(n = 16))

      root_children = children_ids(@id)
      sub_children = []
      root_children.each { |root_id| sub_children.push(children_ids(root_id)) }

      request_ids = {
        :request_id => request_id,
        :transaction_id => transaction_id,
        :space_id => space_id,
      }
      body = {
        :pageId => @id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }

      user_notion_id = get_notion_id(body)

      block = target_block ? get_block(target_block) : self # allows dev to place block anywhere!

      duplicate_hash = $Components.duplicate(block.type, title, block.id, new_block_id, user_notion_id, root_children)
      set_parent_alive_hash = $Components.set_parent_to_alive(block.parent_id, new_block_id)
      block_location_hash = $Components.block_location_add(block_parent_id = block.parent_id, block_id = block.id, new_block_id = new_block_id, targetted_block = target_block, command = "listAfter")
      last_edited_time_parent_hash = $Components.last_edited_time(block.parent_id)
      last_edited_time_child_hash = $Components.last_edited_time(block.id)

      operations = [
        duplicate_hash,
        set_parent_alive_hash,
        block_location_hash,
        last_edited_time_parent_hash,
        last_edited_time_child_hash,
      ]

      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return {}
    end

    def move(target_block, position = "after")
      positions_hash = {
        "after" => "listAfter",
        # "child-after" => "listAfter",
        "before" => "listBefore",
      # "child-before" => "listBefore",
      }
      if !positions_hash.keys.include?(position)
        raise "Invalid position. You said: #{position}, valid options are: #{positions_hash.keys.join(", ")}"
      else
        position_command = positions_hash[position]
        #! move the block to a new location.
        #! target_block -> the targetted block to move to. : ``str``
        #! position -> where the block should be listed, in positions relative to the target_block [before, after, top-child, last-child]
        cookies = @@options["cookies"]
        headers = @@options["headers"]
        request_url = @@method_urls[:UPDATE_BLOCK]

        request_id = extract_id(SecureRandom.hex(n = 16))
        transaction_id = extract_id(SecureRandom.hex(n = 16))
        space_id = extract_id(SecureRandom.hex(n = 16))

        request_ids = {
          :request_id => request_id,
          :transaction_id => transaction_id,
          :space_id => space_id,
        }
        body = {
          :pageId => @id,
          :chunkNumber => 0,
          :limit => 100,
          :verticalColumns => false,
        }
        check_parents = (@parent_id == target_block.parent_id)
        set_block_dead_hash = $Components.set_block_to_dead(@id) # kill the block this method is invoked on...
        block_location_remove_hash = $Components.block_location_remove(@parent_id, @id) # remove the block this method is invoked on...
        parent_location_hash = $Components.parent_location_add(check_parents ? @parent_id : target_block.parent_id, @id) # set parent location to alive
        block_location_add_hash = $Components.block_location_add(block_parent_id = check_parents ? @parent_id : target_block.parent_id, block_id = @id, targetted_block = target_block.id, command = position_command)

        if check_parents
          last_edited_time_parent_hash = $Components.last_edited_time(@parent_id)
          last_edited_time_child_hash = $Components.last_edited_time(@id)
          operations = [
            set_block_dead_hash,
            block_location_remove_hash,
            parent_location_hash,
            block_location_add_hash,
            last_edited_time_parent_hash,
            last_edited_time_child_hash,
          ]
        else
          last_edited_time_parent_hash = $Components.last_edited_time(@parent_id)
          last_edited_time_new_parent_hash = $Components.last_edited_time(target_block.parent_id)
          last_edited_time_child_hash = $Components.last_edited_time(@id)
          operations = [
            set_block_dead_hash,
            block_location_remove_hash,
            parent_location_hash,
            block_location_add_hash,
            last_edited_time_parent_hash,
            last_edited_time_new_parent_hash,
            last_edited_time_child_hash,
          ]
        end
        if !check_parents
          @parent_id = target_block.parent_id
        end
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          :body => request_body.to_json,
          :cookies => cookies,
          :headers => headers,
        )
        return self
      end
    end

    def create(block_type, block_title, after = nil, position = "after")
      #! create a new block
      #! block_type -> the type of block to create : ``cls``
      #! block_title -> the title of the new block : ``str``
      #! loc -> the block_id that the new block should be placed after. ``str``
      positions_hash = {
        "after" => "listAfter",
        # "child-after" => "listAfter",
        "before" => "listBefore",
      # "child-before" => "listBefore",
      }
      if !positions_hash.keys.include?(position)
        raise "Invalid position. You said: #{position}, valid options are: #{positions_hash.keys.join(", ")}"
      else
        position_command = positions_hash[position]

        cookies = @@options["cookies"]
        headers = @@options["headers"]
        timestamp = DateTime.now.strftime("%Q")

        new_block_id = extract_id(SecureRandom.hex(n = 16))
        request_id = extract_id(SecureRandom.hex(n = 16))
        transaction_id = extract_id(SecureRandom.hex(n = 16))
        space_id = extract_id(SecureRandom.hex(n = 16))

        request_ids = {
          :request_id => request_id,
          :transaction_id => transaction_id,
          :space_id => space_id,
        }

        body = {
          :pageId => @id,
          :chunkNumber => 0,
          :limit => 100,
          :verticalColumns => false,
        }

        create_hash = $Components.create(new_block_id, block_type.notion_type)
        set_parent_alive_hash = $Components.set_parent_to_alive(@id, new_block_id)
        last_edited_time_parent_hash = $Components.last_edited_time(@id)
        block_location_hash = $Components.block_location_add(@id, @id, new_block_id, targetted_block = after, command = position_command)
        last_edited_time_parent_hash = $Components.last_edited_time(@id)
        last_edited_time_child_hash = $Components.last_edited_time(@id)
        title_hash = $Components.title(new_block_id, block_title)

        operations = [
          create_hash,
          set_parent_alive_hash,
          block_location_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash,
          title_hash,
        ]

        request_url = @@method_urls[:UPDATE_BLOCK]
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          :body => request_body.to_json,
          :cookies => cookies,
          :headers => headers,
        )

        new_block = block_type.new(new_block_id, block_title, @id)
        return new_block
      end
    end # create

    private

    def get(url_or_id)
      #! retrieve a Notion Block and return its instantiated class object.
      #! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)

      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response["block"].empty?
        if i >= 10
          return {}
        else
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
      end
      block_id = clean_id
      block_title = extract_title(clean_id, jsonified_record_response)
      block_type = extract_type(clean_id, jsonified_record_response)
      block_parent_id = extract_parent_id(clean_id, jsonified_record_response)

      if block_type.nil?
        return {}
      else
        block_class = Notion.const_get(BLOCK_TYPES[block_type].to_s)
        if block_class == Notion::CollectionView
          block_collection_id = extract_collection_id(clean_id, jsonified_record_response)
          collection_title = extract_collection_title(clean_id, block_collection_id, jsonified_record_response)
          return block_class.new(block_id, collection_title, block_parent_id, block_collection_id)
        else
          return block_class.new(block_id, block_title, block_parent_id)
        end
      end
    end

    def update_title(new_title, request_id, transaction_id, space_id)
      #! Helper method for sending POST request to change title of block.
      #! new_title -> new title for the block : ``str``
      #! request_id -> the unique ID for the request. Generated using SecureRandom : ``str``
      #! transaction_id -> the unique ID for the transactions. Generated using SecureRandom: ``str``
      # setup cookies, headers, and grab/create static vars for request
      cookies = @@options["cookies"]
      headers = @@options["headers"]
      request_url = @@method_urls[:UPDATE_BLOCK]
      timestamp = DateTime.now.strftime("%Q") # 13-second timestamp (unix timestamp in MS), to get it in seconds we can use Time.now.to_i

      # set unique IDs for request
      request_ids = {
        :request_id => request_id,
        :transaction_id => transaction_id,
        :space_id => space_id,
      }

      # build and set operations to send to Notion
      title_hash = $Components.title(@id, new_title)
      last_edited_time_parent_hash = $Components.last_edited_time(@parent_id)
      last_edited_time_child_hash = $Components.last_edited_time(@id)
      operations = [
        title_hash,
        last_edited_time_parent_hash,
        last_edited_time_child_hash,
      ]

      request_body = build_payload(operations, request_ids) # defined in utils.rb

      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return response.body
    end # update_title
  end # BlockTemplate

  class DividerBlock < BlockTemplate
    # divider block: ---------
    @@notion_type = "divider"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class TodoBlock < BlockTemplate
    # To-Do block: best for checklists and tracking to-dos.
    @@notion_type = "to_do"

    def self.notion_type
      @@notion_type
    end

    def self.name
      #! change the class.name attribute
      @@notion_type
    end

    def type
      @@notion_type
    end

    def checked=(checked_value)
      #! change the checked property of the Todo Block.
      #! checked_value -> boolean value used to determine whether the block should be checked [yes, 1, true] or not [no, 0, false] : ``bool | str``
      # set static variables for request
      cookies = @@options["cookies"]
      headers = @@options["headers"]
      timestamp = DateTime.now.strftime("%Q")
      request_url = @@method_urls[:UPDATE_BLOCK]

      # set unique values for request
      request_id = extract_id(SecureRandom.hex(n = 16))
      transaction_id = extract_id(SecureRandom.hex(n = 16))
      space_id = extract_id(SecureRandom.hex(n = 16))
      request_ids = {
        :request_id => request_id,
        :transaction_id => transaction_id,
        :space_id => space_id,
      }

      if ["yes", "no"].include?(checked_value.downcase)
        checked_hash = $Components.checked_todo(@id, checked_value.downcase)
        last_edited_time_parent_hash = $Components.last_edited_time(@parent_id)
        last_edited_time_child_hash = $Components.last_edited_time(@id)

        operations = [
          checked_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash,
        ]
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          :body => request_body.to_json,
          :cookies => cookies,
          :headers => headers,
        )
        return true
      else
        return false
        $LOGGER.error("#{checked_value} is not an accepted input value. If you want to check a To-Do block, use one of the following: 1, 'yes', of true. If you want to un-check a To-Do block, use one of the following: 0, 'no', false.")
      end
    end
  end

  class CodeBlock < BlockTemplate
    # Code block: used to store code, should be assigned a coding language.
    @@notion_type = "code"

    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class HeaderBlock < BlockTemplate
    # Header block: H1
    @@notion_type = "header"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class SubHeaderBlock < BlockTemplate
    # SubHeader Block: H2
    @@notion_type = "sub_header"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class SubSubHeaderBlock < BlockTemplate
    # Sub-Sub Header Block: H3
    @@notion_type = "sub_sub_header"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class PageBlock < BlockTemplate
    @@notion_type = "page"

    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end

    def get_block(url_or_id)
      #! retrieve a Notion Block and return its instantiated class object.
      #! url_or_id -> the block ID or URL : ``str``
      return get(url_or_id)
    end

    def get_collection(url_or_id)
      #! retrieve a Notion Block and return its instantiated class object.
      #! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)

      request_body = {
        :pageId => clean_id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response["block"].empty?
        if i >= 10
          return {}
        else
          jsonified_record_response = get_all_block_info(clean_id, request_body)
          i += 1
        end
      end
      block_id = clean_id
      block_parent_id = extract_parent_id(clean_id, jsonified_record_response)
      block_collection_id = extract_collection_id(clean_id, jsonified_record_response)
      block_view_id = extract_view_ids(clean_id, jsonified_record_response).join
      block_title = extract_collection_title(clean_id, block_collection_id, jsonified_record_response)

      return CollectionView.new(block_id, block_title, block_parent_id, block_collection_id, block_view_id)
    end

    def create_collection(collection_type, collection_title, data = {})
      cookies = @@options["cookies"]
      headers = @@options["headers"]
      timestamp = DateTime.now.strftime("%Q")

      new_block_id = extract_id(SecureRandom.hex(n = 16))
      parent_id = extract_id(SecureRandom.hex(n = 16))
      collection_id = extract_id(SecureRandom.hex(n = 16))
      view_id = extract_id(SecureRandom.hex(n = 16))
      # p collection_id, parent_id, view_id

      children = []
      alive_blocks = []
      data.each do |row|
        child = extract_id(SecureRandom.hex(n = 16))
        children.push(child)
        alive_blocks.push($CollectionViewComponents.set_collection_blocks_alive(child, collection_id))
      end

      request_id = extract_id(SecureRandom.hex(n = 16))
      transaction_id = extract_id(SecureRandom.hex(n = 16))
      space_id = extract_id(SecureRandom.hex(n = 16))

      request_ids = {
        :request_id => request_id,
        :transaction_id => transaction_id,
        :space_id => space_id,
      }

      body = {
        :pageId => @id,
        :chunkNumber => 0,
        :limit => 100,
        :verticalColumns => false,
      }

      create_collection_view = $CollectionViewComponents.create_collection_view(new_block_id, collection_id, view_id)
      # set_parent_block_alive = $CollectionViewComponents.set_collection_blocks_alive(parent_id, collection_id)
      configure_view = $CollectionViewComponents.set_view_config(new_block_id, view_id, children_ids = children)
      configure_columns = $CollectionViewComponents.set_collection_columns(collection_id, new_block_id, data)
      set_parent_alive_hash = $Components.set_parent_to_alive(@id, new_block_id)
      add_block_hash = $Components.block_location_add(@id, @id, new_block_id, targetted_block = nil, command = "listAfter")
      new_block_edited_time = $Components.last_edited_time(new_block_id)
      collection_title_hash = $CollectionViewComponents.set_collection_title(collection_title, collection_id)

      operations = [
        create_collection_view,
        # set_parent_block_alive,
        configure_view,
        configure_columns,
        set_parent_alive_hash,
        add_block_hash,
        new_block_edited_time,
        collection_title_hash,
      ]
      operations << alive_blocks
      all_ops = operations.flatten
      data.each_with_index do |row, i|
        child = children[i]
        row.keys.each_with_index do |col_name, j|
          child_component = $CollectionViewComponents.insert_data(child, j == 0 ? "title" : col_name, row[col_name])
          all_ops.push(child_component)
        end
      end

      request_url = @@method_urls[:UPDATE_BLOCK]
      request_body = build_payload(all_ops, request_ids)
      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )

      new_block = CollectionView.new(new_block_id, collection_title, parent_id, collection_id, view_id)
      return new_block
    end # create_collection
  end

  class ToggleBlock < BlockTemplate
    # Toggle block: best for storing children blocks
    @@notion_type = "toggle"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class BulletedBlock < BlockTemplate
    # Bullet list block: best for an unordered list
    @@notion_type = "bulleted_list"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class NumberedBlock < BlockTemplate
    # Numbered list Block: best for an ordered list
    @@notion_type = "numbered_list"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class QuoteBlock < BlockTemplate
    # best for memorable information
    @@notion_type = "quote"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class CalloutBlock < BlockTemplate
    # same as quote... works similarly to page block
    @@notion_type = "callout"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class LatexBlock < BlockTemplate
    # simiilar to code block but for mathematical functions.
    @@notion_type = "equation"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class TextBlock < BlockTemplate
    # good for just about anything (-:
    @@notion_type = "text"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class ImageBlock < BlockTemplate
    # good for visual information
    @@notion_type = "image"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class TableOfContentsBlock < BlockTemplate
    # maps out the headers - sub-headers - sub-sub-headers on the page
    @@notion_type = "table_of_contents"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class ColumnListBlock < BlockTemplate
    #TODO: no use case for this yet.
    @@notion_type = "column_list"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end

  class ColumnBlock < BlockTemplate
    #TODO: no use case for this yet.
    @@notion_type = "column"
    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end
  end
end # Notion

module Notion
  class CollectionView < Core #! should be Block... this class will be extended by CV-based classes, and will define method only exposed to them.
    #! by inheriting BlockTemplate, it inherits a bunch of methods that don't really apply.
    # collection views such as tables and timelines.
    attr_reader :type, :id, :title, :parent_id
    @@notion_type = "collection_view"

    def initialize(id, title, parent_id, collection_id, view_id)
      @id = id
      @title = title
      @parent_id = parent_id
      @collection_id = collection_id
      @view_id = view_id
    end # initialize

    def self.notion_type
      @@notion_type
    end

    def type
      @@notion_type
    end

    def add_row(data)
      #! add new row to Collection View table.
      #! data -> JSON data to add to table : ``json``

      cookies = @@options["cookies"]
      headers = @@options["headers"]
      timestamp = DateTime.now.strftime("%Q")

      request_id = extract_id(SecureRandom.hex(n = 16))
      transaction_id = extract_id(SecureRandom.hex(n = 16))
      space_id = extract_id(SecureRandom.hex(n = 16))
      new_block_id = extract_id(SecureRandom.hex(n = 16))

      request_ids = {
        :request_id => request_id,
        :transaction_id => transaction_id,
        :space_id => space_id,
      }

      instantiate_row = $CollectionViewComponents.add_new_row(new_block_id)
      set_block_alive = $CollectionViewComponents.set_collection_blocks_alive(new_block_id, @collection_id)
      new_block_edited_time = $Components.last_edited_time(new_block_id)
      parent_edited_time = $Components.last_edited_time(@parent_id)

      operations = [
        instantiate_row,
        set_block_alive,
        new_block_edited_time,
        parent_edited_time,
      ]

      data.keys.each_with_index do |col_name, j|
        child_component = $CollectionViewComponents.insert_data(new_block_id, j == 0 ? "title" : col_name, data[col_name])
        operations.push(child_component)
      end

      request_url = @@method_urls[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return true
    end

    def add_property(name, type)
      #! add a property (column) to the table.
      #! name -> name of the property : ``str``
      #! type -> type of the property : ``str``
      cookies = @@options["cookies"]
      headers = @@options["headers"]

      request_id = extract_id(SecureRandom.hex(n = 16))
      transaction_id = extract_id(SecureRandom.hex(n = 16))
      space_id = extract_id(SecureRandom.hex(n = 16))

      request_ids = {
        :request_id => request_id,
        :transaction_id => transaction_id,
        :space_id => space_id,
      }

      # create updated schema
      schema = extract_collection_schema(@collection_id, @view_id)
      schema[name] = {
        :name => name,
        :type => type
      }
      new_schema = {
        :schema => schema
      }

      add_collection_property = $CollectionViewComponents.add_collection_property(@collection_id, new_schema)

      operations = [
        add_collection_property
      ]

      request_url = @@method_urls[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        :body => request_body.to_json,
        :cookies => cookies,
        :headers => headers,
      )

      return true
    end

    private

    def extract_collection_schema(collection_id, view_id)
      cookies = @@options["cookies"]
      headers = @@options["headers"]

      query_collection_hash = $CollectionViewComponents.query_collection(collection_id, view_id, query="")

      request_url = @@method_urls[:GET_COLLECTION]
      response = HTTParty.post(
        request_url,
        :body => query_collection_hash.to_json,
        :cookies => cookies,
        :headers => headers,
      )
      return response["recordMap"]["collection"][collection_id]["value"]["schema"]
    end
  end
end

# gather a list of all the classes defined here...
Classes = Notion.constants.select { |c| Notion.const_get(c).is_a? Class and c.to_s != "BlockTemplate" and c.to_s != "Core" }
notion_types = []
Classes.each { |cls| notion_types.push(Notion.const_get(cls).notion_type) }
BLOCK_TYPES = notion_types.zip(Classes).to_h
