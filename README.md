# Unofficial Notion Client for Ruby.
[![Build Status](https://travis-ci.com/danmurphy1217/notion-ruby.svg?branch=master)](https://travis-ci.com/danmurphy1217/notion-ruby) [![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)

- Read the [blog post](https://towardsdatascience.com/introducing-the-notion-api-ruby-gem-d47d4a6ef0ca), which outlines why I built this and some of the functionality.
- Check out the [Gem](https://rubygems.org/gems/notion)!

## Getting Started
### Installation
to install the gem:
```ruby
gem install notion
```
Then, place this at the top of your file:
```ruby
require 'notion_api' 
```
To get started using the gem, you'll first need to retrieve your token_v2 credentials by signing into Notion online, navigating to the developer tools, inspecting the cookies, and finding the value associated with the **token_v2** key.

From here, you can instantiate the Notion Client with the following code:
```ruby
>>> @client = NotionAPI::Client.new("<insert_v2_token_here>")
```
## Retrieving a Page
A typical starting point is the `get_page` method, which returns a Notion Page Block. The `get_page` method accepts the ID (formatted or not) or the URL of the page:
1. URL → https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66
2. ID → d2ce338f19e847f586bd17679f490e66
3. Formatted ID → d2ce338f-19e8-47f5-86bd-17679f490e66
```ruby
>>> @client.get_page("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66")
>>> @client.get_page("d2ce338f19e847f586bd17679f490e66")
>>> @client.get_page("d2ce338f-19e8-47f5-86bd-17679f490e66")
```
All three of these will return the same block instance:
```ruby
#<NotionAPI::PageBlock id="d2ce338f-19e8-47f5-86bd-17679f490e66" title="TEST" parent_id="<omitted>">
```
The following attributes can be read from any block class instance:
1. `id`: the ID associated with the block.
2. `title`: the title associated with the block.
3. `parent_id`: the parent ID of the block.
4. `type`: the type of the block.

To update the title of the page:
![Update the title of a page](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/change_title.gif)

## Retrieving a Block within the Page
Now that you have retrieved a Notion Page, you have full access to the blocks on that page. You can retrieve a specific block or collection view, retrieve all children IDs (array of children IDs), or retrieve all children (array of children class instances).

### Get a Block
To retrieve a specific block, you can use the `get_block` method. This method accepts the ID of the block (formatted or not), and will return the block as an instantiated class instance:
```ruby
@page = @client.get_page("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66")
@page.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
#<TextBlock id="2cbbe0bf-34cd-409b-9162-64284b33e526" title="TEST" parent_id="d2ce338f-19e8-47f5-86bd-17679f490e66">
```
Any Notion Block has access to the following methods:

1. `title=` → change the title of a block.
```ruby
>>> @block = @client.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @block.title # get the current title...
"TEST"
>>> @block.title= "New Title Here" # lets update it...
>>> @block.title
"New Title Here"
```
For example:
![Update the title of a block](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/change%20block%20title.gif)
2. `convert` → convert a block to a different type.
```ruby
>>> @block = @client.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @block.type
"text"
>>> @new_block = @block.convert(NotionAPI::CalloutBlock)
>>> @new_block.type
"callout"
>>> @new_block # new class instance returned...
#<NotionAPI::CalloutBlock:0x00007ffb75b19ea0 id="2cbbe0bf-34cd-409b-9162-64284b33e526" title="New Title Here" parent_id="d2ce338f-19e8-47f5-86bd-17679f490e66">
```
For example:
![Convert a page](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/change%20to%20todo%2C%20check.gif)

3. `duplicate`→ duplicate the current block.
```ruby
>>> @block = @client.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @block.duplicate # block is duplicated and placed directly after the current block
>>> @block.duplicate("f13da22b-9012-4c49-ac41-6b7f97bd519e") # the duplicated block is placed after 'f13da22b-9012-4c49-ac41-6b7f97bd519e'
```
For example:
![Convert a page](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/duplicate.gif)
4. `move` → move a block to another location.
```ruby
>>> @block = @client.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @target_block = @client.get_block("c3ce468f-11e3-48g5-87be-27679g491e66")
>>> @block.move(@target_block) # @block moved to **after** @target_block
>>> @block.move(@target_block, "before") # @block moved to **before** @target_block
```
For example:
![move a block](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/move_before_and_after.gif)
### Get a Collection View - Table
To retrieve a collection, you use the `get_collection` method. This method is designed to work with Table collections, but the codebase is actively being updated to support others:
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66")
>>> @page.get_collection("34d03794-ecdd-e42d-bb76-7e4aa77b6503")
#<NotionAPI::CollectionView:0x00007fecd8859770 @id="34d03794-ecdd-e42d-bb76-7e4aa77b6503", @title="Car Data", @parent_id="9c50a7b3-9ad7-4f2b-aa08-b3c95f1f19e7", @collection_id="5ea0fa7c-00cd-4ee0-1915-8b5c423f8f3a", @view_id="5fdb08da-0732-49dc-d0c3-2e31fccca73a">
```
Any Notion Block has access to the following methods:
1. `row_ids` → retrieve the IDs associated with each row.
```ruby
>>> @collection = @page.get_collection("34d03794-ecdd-e42d-bb76-7e4aa77b6503")
>>> @collection.row_ids
ent.rb
["785f4e24-e489-a316-50cf-b0b100c6673a", "78642d95-da23-744c-b084-46d039927bba", "96dff83c-6961-894c-39c2-c2c8bfcbfa90", "87ae8ae7-5518-fbe1-748e-eb690c707fac",..., "5a50bdd4-69c5-0708-5093-b135676e83c1", "ff9b8b89-1fed-f955-4afa-5a071198b0ee", "721fe76a-9e3c-d348-8324-994c95d77b2e"]
```
2. `rows` → retrieve each Row, returned as an array of TableRowInstance classes.
```ruby
>>> @collection = @page.get_collection("34d03794-ecdd-e42d-bb76-7e4aa77b6503")
>>> @collection.rows
#<NotionAPI::CollectionViewRow:0x00007ffecca82078 @id="785f4e24-e489-a316-50cf-b0b100c6673a", @parent_id="9c50a7b3-9ad7-4f2b-aa08-b3c95f1f19e7", @collection_id="5ea0fa7c-00cd-4ee0-1915-8b5c423f8f3a", @view_id="5fdb08da-0732-49dc-d0c3-2e31fccca73a">,..., #<NotionAPI::CollectionViewRow:0x00007ffecca81998 @id="fbf44f93-52ee-0e88-262a-94982ffb3fb2", @parent_id="9c50a7b3-9ad7-4f2b-aa08-b3c95f1f19e7", @collection_id="5ea0fa7c-00cd-4ee0-1915-8b5c423f8f3a", @view_id="5fdb08da-0732-49dc-d0c3-2e31fccca73a">]
```
3. `row("<row_id>")` → retrieve a specific row.
```ruby
>>> @collection = @page.get_collection("34d03794-ecdd-e42d-bb76-7e4aa77b6503")
>>> @collection.row("f1c7077f-44a9-113d-a156-90ab6880c3e2")
{"age"=>[9], "vin"=>["1C6SRFLT1MN591852"], "body"=>["4D Crew Cab"], "fuel"=>["Gasoline"], "make"=>["Ram"], "msrp"=>[64935], "year"=>[2021], "model"=>[1500], "price"=>[59688], "stock"=>["21R14"], "dealerid"=>["MP2964D"], "colour"=>["Bright White Clearcoat"], "engine"=>["HEMI 5.7L V8 Multi Displacement VVT"], "photos"=>["http://vehicle-photos-published.vauto.com/d0/c2/dd/8b-1307-4c67-8d31-5a301764b875/image-1.jpg"], "series"=>["Rebel"], "newused"=>["N"], "city_mpg"=>[""],...,"engine_cylinder_ct"=>[8], "engine_displacement"=>[5.7], "photos_last_modified_date"=>["11/13/2020 8:16:56 AM"]}
```

## Creating New Blocks
Here's a high-level example:
![create a callout a block](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/create.gif)
The block types available to the `create` method are:
1. `DividerBlock`
2. `TodoBlock`
3. `CodeBlock` 
4. `HeaderBlock` 
5. `SubHeaderBlock`
6. `SubSubHeaderBlock`
7. `PageBlock`
8. `ToggleBlock`
9. `BulletedBlock`
10. `NumberedBlock`
11. `QuoteBlock`
12. `CalloutBlock`
13. `LatexBlock`
14. `TextBlock` 
15. `ImageBlock` and 
16. `TableOfContentsBlock`.
If you want to create a collection, utilize the `create_collection` method [defined below].

To create a new block, you have a few options:
### Create a block whose parent is the page
If you want to create a new block whose parent ID is the **page**, call the `create` method on the PageBlock instance.
1. `@page.create("<type_of_block", "title of block")` → create a new block at the end of the page.
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @page.create(NotionAPI::TextBlock, "Hiya!")
#<NotionAPI::TextBlock:0x00007fecd4459770 **omitted**>
```
2. `@page.create("<type_of_block", "title of block", "target_block_id")` → create a new block after the target block.
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @page.create(NotionAPI::TextBlock, "Hiya!", "ee0a6531-44cd-439f-a68c-1bdccbebfc8a")
#<NotionAPI::TextBlock:0x00007fecd8859770 **omitted**>
```
3. `@page.create("<type_of_block"), "title of block", "target_block_id", "before/after")` → create a new block after or before the target block.
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @page.create(NotionAPI::TextBlock, "Hiya!", "ee0a6531-44cd-439f-a68c-1bdccbebfc8a", "before")
#<NotionAPI::TextBlock:0x00007fecd8859880 **omitted**>
```
### Create a block whose parent is another block
If you want to create a nested block whose parent ID is **another block**, call the `create` method on that block.
1. `@block.create("<type_of_block", "title of block")` → create a new nested block whose parent ID is @block.id
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @block = @page.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @block.create(NotionAPI::TextBlock, "Hiya!") # create a nested text block
#<NotionAPI::TextBlock:0x00007fecd8861780 **omitted**>
```
2. `@block.create("<type_of_block", "title of block", "target_block")` → create a new nested block whose parent ID is @block.id and whose location is after the target block
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @block = @page.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @block.create(NotionAPI::TextBlock, "Hiya!" "ae3d1c60-b9d1-0ac0-0fff-16d3fc8907a2") # create a nested text block after a specific child
#<NotionAPI::TextBlock:0x00007fecd8859781 **omitted**>
```
3. `@block.create("<type_of_block", "title of block", "target_block", "before/after")` → reate a new nested block whose parent ID is @block.id and whose location is before the target block
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @block = @page.get_block("2cbbe0bf-34cd-409b-9162-64284b33e526")
>>> @block.create(NotionAPI::TextBlock, "Hiya!" "ae3d1c60-b9d1-0ac0-0fff-16d3fc8907a2", "before") # create a nested text block before a specific child
#<NotionAPI::TextBlock:0x00007fecd8859781 **omitted**>
```
The simplest way to describe this: the parent ID of the created block is the ID of the block the `create` method is invoked on. If the `create` method is invoked on a **PageBlock**, the block is a child of that page. If the `create` method is invoked on a block within the page, the block is a child of that block.

** NOTE: Notion only supports 'nesting' certain block types. If you try to nest a block that cannot be nested, it will fail. **
## Creating New Collections
Let's say we have the following JSON data:
```json
[
  {
    "emoji": "😀",
    "description": "grinning face",
    "category": "Smileys & Emotion",
    "aliases": ["grinning"],
    "tags": ["smile", "happy"],
    "unicode_version": "6.1",
    "ios_version": "6.0"
  },
  {
    "emoji": "😃",
    "description": "grinning face with big eyes",
    "category": "Smileys & Emotion",
    "aliases": ["smiley"],
    "tags": ["happy", "joy", "haha"],
    "unicode_version": "6.0",
    "ios_version": "6.0"
  }
]
```
A new table collection view containing this data is created with the following code:
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @page.create_collection("table", "title for table", JSON.parse(File.read("./path/to/emoji_json_data.json")))
```
Here's an example with a larger dataset:
![create a collection view table](https://github.com/danmurphy1217/notion-ruby/blob/master/gifs/create%20collection.gif)

Additionally, say you already have a Table and want to add a new row with it containing the following data:
```ruby
{
    "emoji": "😉",
    "description": "winking face",
    "category": "Smileys & Emotion",
    "aliases": ["wink"],
    "tags": ["flirt"],
    "unicode_version": "6.0",
    "ios_version": "6.0"
}
```
```ruby
>>> @page = @client.get_page("https://www.notion.so/danmurphy/Notion-API-Testing-66447bc817f044bc81ed3cf4802e9b00")
>>> @collection = @page.get_collection("f1664a99-165b-49cc-811c-84f37655908a")
>>> @collection.add_row(JSON.parse(File.read("path/to/new_emoji_row.json")))
```

The first argument passed to `create_collection` determines which type of collection view to create. In the above example, a "table" is created, but other supported options are:
1. list
2. board
3. calendar
4. timeline
5. gallery
