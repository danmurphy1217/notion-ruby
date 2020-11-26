# frozen_string_literal: true

require_relative 'core'
require 'httparty'

module NotionAPI
  # Base Template for all blocks. Inherits core methods from the Block class defined in block.rb
  class BlockTemplate < Core
    include Utils

    attr_reader :id, :title, :parent_id

    def initialize(id, title, parent_id)
      @id = id
      @title = title
      @parent_id = parent_id
    end

    def title=(new_title)
      # ! Change the title of a block.
      # ! new_title -> new title for the block : ``str``
      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))
      update_title(new_title.to_s, request_id, transaction_id, space_id)
      @title = new_title
    end

    def convert(block_class_to_convert_to)
      # ! convert a block from its current type to another.
      # ! block_class_to_convert_to -> the type of block to convert to : ``cls``
      if type == block_class_to_convert_to.notion_type
        # if converting to same type, skip and return self
        self
      else
        # setup cookies, headers, and grab/create static vars for request
        cookies = Core.options['cookies']
        headers = Core.options['headers']
        request_url = URLS[:UPDATE_BLOCK]

        # set random IDs for request
        request_id = extract_id(SecureRandom.hex(16))
        transaction_id = extract_id(SecureRandom.hex(16))
        space_id = extract_id(SecureRandom.hex(16))
        request_ids = {
          request_id: request_id,
          transaction_id: transaction_id,
          space_id: space_id
        }

        # build hash's that contain the operations to send to Notions backend
        convert_type_hash = Utils::BlockComponents.convert_type(@id, block_class_to_convert_to)
        last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)

        operations = [
          convert_type_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash
        ]

        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub."; end

        block_class_to_convert_to.new(@id, @title, @parent_id)

      end
    end

    def duplicate(target_block = nil)
      # ! duplicate the block that this method is invoked upon.
      # ! target_block -> the block to place the duplicated block after. Can be any valid Block ID! : ``str``
      cookies = Core.options['cookies']
      headers = Core.options['headers']
      request_url = URLS[:UPDATE_BLOCK]

      new_block_id = extract_id(SecureRandom.hex(16))
      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))

      root_children = children_ids(@id)
      sub_children = []
      root_children.each { |root_id| sub_children.push(children_ids(root_id)) }

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }
      body = {
        pageId: @id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false
      }

      user_notion_id = get_notion_id(body)

      block = target_block ? get(target_block) : self # allows dev to place block anywhere!

      duplicate_hash = Utils::BlockComponents.duplicate(type, @title, block.id, new_block_id, user_notion_id, root_children)
      set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(block.parent_id, new_block_id)
      block_location_hash = Utils::BlockComponents.block_location_add(block.parent_id, block.id, new_block_id, target_block, 'listAfter')
      last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(block.parent_id)
      last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(block.id)

      operations = [
        duplicate_hash,
        set_parent_alive_hash,
        block_location_hash,
        last_edited_time_parent_hash,
        last_edited_time_child_hash
      ]

      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )
      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
         Please try again, and if issues persist open an issue in GitHub."; end

      class_to_return = NotionAPI.const_get(Classes.select { |cls| NotionAPI.const_get(cls).notion_type == type }.join.to_s)
      class_to_return.new(new_block_id, @title, block.parent_id)
    end

    def move(target_block, position = 'after')
      # ! move the block to a new location.
      # ! target_block -> the targetted block to move to. : ``str``
      # ! position -> where the block should be listed, in positions relative to the target_block [before, after, top-child, last-child]
      positions_hash = {
        'after' => 'listAfter',
        'before' => 'listBefore'
      }

      unless positions_hash.keys.include?(position); raise ArgumentError, "Invalid position. You said: #{position}, valid options are: #{positions_hash.keys.join(', ')}"; end

      position_command = positions_hash[position]
      cookies = Core.options['cookies']
      headers = Core.options['headers']
      request_url = URLS[:UPDATE_BLOCK]

      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      check_parents = (@parent_id == target_block.parent_id)
      set_block_dead_hash = Utils::BlockComponents.set_block_to_dead(@id) # kill the block this method is invoked on...
      block_location_remove_hash = Utils::BlockComponents.block_location_remove(@parent_id, @id) # remove the block this method is invoked on...
      parent_location_hash = Utils::BlockComponents.parent_location_add(check_parents ? @parent_id : target_block.parent_id, @id) # set parent location to alive
      block_location_add_hash = Utils::BlockComponents.block_location_add(check_parents ? @parent_id : target_block.parent_id, @id, target_block.id, position_command)
      last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)

      if check_parents
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
        operations = [
          set_block_dead_hash,
          block_location_remove_hash,
          parent_location_hash,
          block_location_add_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash
        ]
      else
        last_edited_time_new_parent_hash = Utils::BlockComponents.last_edited_time(target_block.parent_id)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
        @parent_id = target_block.parent_id
        operations = [
          set_block_dead_hash,
          block_location_remove_hash,
          parent_location_hash,
          block_location_add_hash,
          last_edited_time_parent_hash,
          last_edited_time_new_parent_hash,
          last_edited_time_child_hash
        ]
      end
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )
      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
         Please try again, and if issues persist open an issue in GitHub."; end

      self
    end

    def create(block_type, block_title, target = nil, position = 'after')
      # ! create a new block
      # ! block_type -> the type of block to create : ``cls``
      # ! block_title -> the title of the new block : ``str``
      # ! target -> the block_id that the new block should be placed after. ``str`` 
      # ! position -> 'after' or 'before'
      positions_hash = {
        'after' => 'listAfter',
        'before' => 'listBefore'
      }
      unless positions_hash.keys.include?(position); raise "Invalid position. You said: #{position}, valid options are: #{positions_hash.keys.join(', ')}"; end

      position_command = positions_hash[position]

      cookies = Core.options['cookies']
      headers = Core.options['headers']

      new_block_id = extract_id(SecureRandom.hex(16))
      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      create_hash = Utils::BlockComponents.create(new_block_id, block_type.notion_type)
      set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(@id, new_block_id)
      block_location_hash = Utils::BlockComponents.block_location_add(@id, @id, new_block_id, target, position_command)
      last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@id)
      last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
      title_hash = Utils::BlockComponents.title(new_block_id, block_title)

      operations = [
        create_hash,
        set_parent_alive_hash,
        block_location_hash,
        last_edited_time_parent_hash,
        last_edited_time_child_hash,
        title_hash
      ]

      request_url = URLS[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )
      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
         Please try again, and if issues persist open an issue in GitHub."; end

      block_type.new(new_block_id, block_title, @id)
    end

    private

    def get(url_or_id)
      # ! retrieve a Notion Block and return its instantiated class object.
      # ! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)

      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
        return {} if i >= 10

        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i += 1
      end
      block_type = extract_type(clean_id, jsonified_record_response)
      block_parent_id = extract_parent_id(clean_id, jsonified_record_response)

      if block_type.nil?
        {}
      else
        block_class = NotionAPI.const_get(BLOCK_TYPES[block_type].to_s)
        if block_class == NotionAPI::CollectionView
          block_collection_id = extract_collection_id(clean_id, jsonified_record_response)
          block_view_id = extract_view_ids(clean_id, jsonified_record_response)
          collection_title = extract_collection_title(clean_id, block_collection_id, jsonified_record_response)
          block_class.new(clean_id, collection_title, block_parent_id, block_collection_id, block_view_id.join)
        else
          block_title = extract_title(clean_id, jsonified_record_response)
          block_class.new(clean_id, block_title, block_parent_id)
        end
      end
    end

    def update_title(new_title, request_id, transaction_id, space_id)
      # ! Helper method for sending POST request to change title of block.
      # ! new_title -> new title for the block : ``str``
      # ! request_id -> the unique ID for the request key. Generated using SecureRandom : ``str``
      # ! transaction_id -> the unique ID for the transaction key. Generated using SecureRandom: ``str``
      # ! transaction_id -> the unique ID for the space key. Generated using SecureRandom: ``str``
      # setup cookies, headers, and grab/create static vars for request
      cookies = Core.options['cookies']
      headers = Core.options['headers']
      request_url = URLS[:UPDATE_BLOCK]

      # set unique IDs for request
      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      # build and set operations to send to Notion
      title_hash = Utils::BlockComponents.title(@id, new_title)
      last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)
      last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)
      operations = [
        title_hash,
        last_edited_time_parent_hash,
        last_edited_time_child_hash
      ]

      request_body = build_payload(operations, request_ids) # defined in utils.rb

      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )
      response.body
    end
  end

  # divider block: ---------
  class DividerBlock < BlockTemplate
    @notion_type = 'divider'
    @type = 'divider'

    def type
      NotionAPI::DividerBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # To-Do block: best for checklists and tracking to-dos.
  class TodoBlock < BlockTemplate
    @notion_type = 'to_do'
    @type = 'to_do'

    def type
      NotionAPI::TodoBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end

    def checked=(checked_value)
      # ! change the checked property of the Todo Block.
      # ! checked_value -> boolean value used to determine whether the block should be checked [yes] or not [no] : ``str``
      # set static variables for request
      cookies = Core.options['cookies']
      headers = Core.options['headers']
      request_url = URLS[:UPDATE_BLOCK]

      # set unique values for request
      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))
      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      if %w[yes no].include?(checked_value.downcase)
        checked_hash = Utils::BlockComponents.checked_todo(@id, checked_value.downcase)
        last_edited_time_parent_hash = Utils::BlockComponents.last_edited_time(@parent_id)
        last_edited_time_child_hash = Utils::BlockComponents.last_edited_time(@id)

        operations = [
          checked_hash,
          last_edited_time_parent_hash,
          last_edited_time_child_hash
        ]
        request_body = build_payload(operations, request_ids)
        response = HTTParty.post(
          request_url,
          body: request_body.to_json,
          cookies: cookies,
          headers: headers
        )
        unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
           Please try again, and if issues persist open an issue in GitHub."; end

        true
      else
        false
      end
    end
  end

  # Code block: used to store code, should be assigned a coding language.
  class CodeBlock < BlockTemplate
    @notion_type = 'code'
    @type = 'code'

    def type
      NotionAPI::CodeBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # Header block: H1
  class HeaderBlock < BlockTemplate
    @notion_type = 'header'
    @type = 'header'

    def type
      NotionAPI::HeaderBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # SubHeader Block: H2
  class SubHeaderBlock < BlockTemplate
    @notion_type = 'sub_header'
    @type = 'sub_header'

    def type
      NotionAPI::SubHeaderBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # Sub-Sub Header Block: H3
  class SubSubHeaderBlock < BlockTemplate
    @notion_type = 'sub_sub_header'
    @type = 'sub_sub_header'

    def type
      NotionAPI::SubSubHeaderBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # Page Block, entrypoint for the application
  class PageBlock < BlockTemplate
    @notion_type = 'page'
    @type = 'page'

    def type
      NotionAPI::PageBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end

    def get_block(url_or_id)
      # ! retrieve a Notion Block and return its instantiated class object.
      # ! url_or_id -> the block ID or URL : ``str``
      get(url_or_id)
    end

    def get_collection(url_or_id)
      # ! retrieve a Notion Collection and return its instantiated class object.
      # ! url_or_id -> the block ID or URL : ``str``
      clean_id = extract_id(url_or_id)

      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
        return {} if i >= 10

        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i += 1
      end
      block_parent_id = extract_parent_id(clean_id, jsonified_record_response)
      block_collection_id = extract_collection_id(clean_id, jsonified_record_response)
      block_view_id = extract_view_ids(clean_id, jsonified_record_response).join
      block_title = extract_collection_title(clean_id, block_collection_id, jsonified_record_response)

      CollectionView.new(clean_id, block_title, block_parent_id, block_collection_id, block_view_id)
    end

    def create_collection(_collection_type, collection_title, data)
      # ! create a Notion Collection View and return its instantiated class object.
      # ! _collection_type -> the type of collection to create : ``str``
      # ! collection_title -> the title of the collection view : ``str``
      # ! data -> JSON data to add to the table : ``str``

      unless %w[table].include?(_collection_type) ; raise ArgumentError, "That collection type is not yet supported. Try: \"table\"."; end
      cookies = Core.options['cookies']
      headers = Core.options['headers']

      new_block_id = extract_id(SecureRandom.hex(16))
      parent_id = extract_id(SecureRandom.hex(16))
      collection_id = extract_id(SecureRandom.hex(16))
      view_id = extract_id(SecureRandom.hex(16))

      children = []
      alive_blocks = []
      data.each do |_row|
        child = extract_id(SecureRandom.hex(16))
        children.push(child)
        alive_blocks.push(Utils::CollectionViewComponents.set_collection_blocks_alive(child, collection_id))
      end

      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      create_collection_view = Utils::CollectionViewComponents.create_collection_view(new_block_id, collection_id, view_id)
      configure_view = Utils::CollectionViewComponents.set_view_config(new_block_id, view_id, children)
      configure_columns = Utils::CollectionViewComponents.set_collection_columns(collection_id, new_block_id, data)
      set_parent_alive_hash = Utils::BlockComponents.set_parent_to_alive(@id, new_block_id)
      add_block_hash = Utils::BlockComponents.block_location_add(@id, @id, new_block_id, nil, 'listAfter')
      new_block_edited_time = Utils::BlockComponents.last_edited_time(new_block_id)
      collection_title_hash = Utils::CollectionViewComponents.set_collection_title(collection_title, collection_id)

      operations = [
        create_collection_view,
        configure_view,
        configure_columns,
        set_parent_alive_hash,
        add_block_hash,
        new_block_edited_time,
        collection_title_hash
      ]
      operations << alive_blocks
      all_ops = operations.flatten
      data.each_with_index do |row, i|
        child = children[i]
        row.keys.each_with_index do |col_name, j|
          child_component = Utils::CollectionViewComponents.insert_data(child, j.zero? ? 'title' : col_name, row[col_name])
          all_ops.push(child_component)
        end
      end

      request_url = URLS[:UPDATE_BLOCK]
      request_body = build_payload(all_ops, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )

      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
         Please try again, and if issues persist open an issue in GitHub."; end

      CollectionView.new(new_block_id, collection_title, parent_id, collection_id, view_id)
    end
  end

  # Toggle block: best for storing children blocks
  class ToggleBlock < BlockTemplate
    @notion_type = 'toggle'
    @type = 'toggle'

    def type
      NotionAPI::ToggleBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # Bullet list block: best for an unordered list
  class BulletedBlock < BlockTemplate
    @notion_type = 'bulleted_list'
    @type = 'bulleted_list'

    def type
      NotionAPI::BulletedBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # Numbered list Block: best for an ordered list
  class NumberedBlock < BlockTemplate
    @notion_type = 'numbered_list'
    @type = 'numbered_list'

    def type
      NotionAPI::NumberedBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # best for memorable information
  class QuoteBlock < BlockTemplate
    @notion_type = 'quote'
    @type = 'quote'

    def type
      NotionAPI::QuoteBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # same as quote... works similarly to page block
  class CalloutBlock < BlockTemplate
    @notion_type = 'callout'
    @type = 'callout'

    def type
      NotionAPI::CalloutBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # simiilar to code block but for mathematical functions.
  class LatexBlock < BlockTemplate
    @notion_type = 'equation'
    @type = 'equation'

    def type
      NotionAPI::LatexBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # good for just about anything (-:
  class TextBlock < BlockTemplate
    @notion_type = 'text'
    @type = 'text'

    def type
      NotionAPI::TextBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

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

  # no use case for this yet.
  class ColumnListBlock < BlockTemplate
    @notion_type = 'column_list'
    @type = 'column_list'

    def type
      NotionAPI::ColumnListBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end

  # no use case for this yet.
  class ColumnBlock < BlockTemplate
    @notion_type = 'column'
    @type = 'column'

    def type
      NotionAPI::ColumnBlock.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end
  end
end

module NotionAPI
  # collection views such as tables and timelines.
  class CollectionView < Core
    attr_reader :id, :title, :parent_id, :collection_id, :view_id

    @notion_type = 'collection_view'
    @type = 'collection_view'

    def type
      NotionAPI::CollectionView.notion_type
    end

    class << self
      attr_reader :notion_type, :type
    end

    def initialize(id, title, parent_id, collection_id, view_id)
      @id = id
      @title = title
      @parent_id = parent_id
      @collection_id = collection_id
      @view_id = view_id
    end

    def add_row(data)
      # ! add new row to Collection View table.
      # ! data -> data to add to table : ``hash``

      cookies = Core.options['cookies']
      headers = Core.options['headers']

      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))
      new_block_id = extract_id(SecureRandom.hex(16))
      schema = extract_collection_schema(@collection_id, @view_id)
      keys = schema.keys
      col_map = {}
      keys.map { |key| col_map[schema[key]['name']]  = key }

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      instantiate_row = Utils::CollectionViewComponents.add_new_row(new_block_id)
      set_block_alive = Utils::CollectionViewComponents.set_collection_blocks_alive(new_block_id, @collection_id)
      new_block_edited_time = Utils::BlockComponents.last_edited_time(new_block_id)
      parent_edited_time = Utils::BlockComponents.last_edited_time(@parent_id)

      operations = [
        instantiate_row,
        set_block_alive,
        new_block_edited_time,
        parent_edited_time
      ]

      data.keys.each_with_index do |col_name, j|
        child_component = Utils::CollectionViewComponents.insert_data(new_block_id, j.zero? ? 'title' : col_map[col_name], data[col_name])
        operations.push(child_component)
      end

      request_url = URLS[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )

      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
         Please try again, and if issues persist open an issue in GitHub."; end

         NotionAPI::CollectionViewRow.new(new_block_id, @parent_id, @collection_id, @view_id)
    end

    def add_property(name, type)
      # ! add a property (column) to the table.
      # ! name -> name of the property : ``str``
      # ! type -> type of the property : ``str``
      cookies = Core.options['cookies']
      headers = Core.options['headers']

      request_id = extract_id(SecureRandom.hex(16))
      transaction_id = extract_id(SecureRandom.hex(16))
      space_id = extract_id(SecureRandom.hex(16))

      request_ids = {
        request_id: request_id,
        transaction_id: transaction_id,
        space_id: space_id
      }

      # create updated schema
      schema = extract_collection_schema(@collection_id, @view_id)
      schema[name] = {
        name: name,
        type: type
      }
      new_schema = {
        schema: schema
      }

      add_collection_property = Utils::CollectionViewComponents.add_collection_property(@collection_id, new_schema)

      operations = [
        add_collection_property
      ]

      request_url = URLS[:UPDATE_BLOCK]
      request_body = build_payload(operations, request_ids)
      response = HTTParty.post(
        request_url,
        body: request_body.to_json,
        cookies: cookies,
        headers: headers
      )
      unless response.code == 200; raise "There was an issue completing your request. Here is the response from Notion: #{response.body}, and here is the payload that was sent: #{operations}.
         Please try again, and if issues persist open an issue in GitHub."; end

      true
    end

    def row(row_id)
      # ! retrieve a row from a CollectionView Table.
      # ! row_id -> the ID for the row to retrieve: ``str``
      clean_id = extract_id(row_id)

      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false
      }
      jsonified_record_response = get_all_block_info(clean_id, request_body)
      schema = extract_collection_schema(@collection_id, @view_id)
      keys = schema.keys
      column_names = keys.map { |key| schema[key]['name'] }
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
        return {} if i >= 10

        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i += 1
      end
      row_jsonified_response = jsonified_record_response['block'][clean_id]['value']['properties']
      row_data = {}
      keys.each_with_index { |key, idx| row_data[column_names[idx]] = row_jsonified_response[key] ? row_jsonified_response[key].flatten : [] }
      row_data
    end

    def row_ids
      # ! retrieve all Collection View table rows.
      clean_id = extract_id(@id)

      request_body = {
        pageId: clean_id,
        chunkNumber: 0,
        limit: 100,
        verticalColumns: false
      }

      jsonified_record_response = get_all_block_info(clean_id, request_body)
      i = 0
      while jsonified_record_response.empty? || jsonified_record_response['block'].empty?
        return {} if i >= 10

        jsonified_record_response = get_all_block_info(clean_id, request_body)
        i += 1
      end

      jsonified_record_response['collection_view'][@view_id]['value']['page_sort']
    end

    def rows
      # ! returns all rows as instantiated class instances.
      row_id_array = row_ids
      parent_id = @parent_id
      collection_id = @collection_id
      view_id = @view_id

      row_id_array.map { |row_id| NotionAPI::CollectionViewRow.new(row_id, parent_id, collection_id, view_id) }
    end

    private

    def extract_collection_schema(collection_id, view_id)
      # ! retrieve the collection scehma. Useful for 'building' the backbone for a table.
      # ! collection_id -> the collection ID : ``str``
      # ! view_id -> the view ID : ``str``
      cookies = Core.options['cookies']
      headers = Core.options['headers']

      query_collection_hash = Utils::CollectionViewComponents.query_collection(collection_id, view_id, '')

      request_url = URLS[:GET_COLLECTION]
      response = HTTParty.post(
        request_url,
        body: query_collection_hash.to_json,
        cookies: cookies,
        headers: headers
      )
      response['recordMap']['collection'][collection_id]['value']['schema']
    end
  end
  # Class for each row in a Collection View Table.
  class CollectionViewRow < Core
    @notion_type = 'table_row'
    @type = 'table_row'

    def type
      NotionAPI::CollectionViewRow.notion_type
    end

    class << self
      attr_reader :notion_type, :type, :parent_id
    end

    attr_reader :parent_id, :id
    def initialize(id, parent_id, collection_id, view_id)
      @id = id
      @parent_id = parent_id
      @collection_id = collection_id
      @view_id = view_id
    end
  end
end

# gather a list of all the classes defined here...
Classes = NotionAPI.constants.select { |c| NotionAPI.const_get(c).is_a? Class and c.to_s != 'BlockTemplate' and c.to_s != 'Core' and c.to_s !='Client' }
notion_types = []
Classes.each { |cls| notion_types.push(NotionAPI.const_get(cls).notion_type) }
BLOCK_TYPES = notion_types.zip(Classes).to_h