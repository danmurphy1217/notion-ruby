# Unofficial Notion Client for Ruby.

## Getting Started
To get started using this wrapper, you'll first need to retrieve your token_v2 credentials by signing into Notion in your browser of choice, navigating to the developer tools, inspecting the cookies, and finding the value associated with the **token_v2** key.

From here, you can instantiate the Notion Client with the following code:
```ruby
client = Notion::Client.new("<insert_v2_token_here>")
```
The `Client` class extends the `Block` class, which includes a majority of the useful methods you will use to interface with Notion. A useful starting point is the `get_block` method, which returns an instantiated block class that corresponds to the ID you passed. You can pass the ID in three different ways:
1. URL → https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66
2. ID → d2ce338f19e847f586bd17679f490e66
3. Formatted ID → d2ce338f-19e8-47f5-86bd-17679f490e66
```ruby
@client.get_block("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66")
@client.get_block("d2ce338f19e847f586bd17679f490e66")
@client.get_block("d2ce338f-19e8-47f5-86bd-17679f490e66")
```
All three of these will return the same block instance:
```ruby
#<Notion::PageBlock:0x00007f9342d7ea10 **omitted meta-data**>
```
Attributes that can be read from this class instance are:
1. `id`: the clean ID associated with the block.
2. `title`: the title associated with the block.
3. `parent_id`: the parent ID of the block.
4. `type`: the type of the block.

## Block Classes
As mentioned above, an instantiated block class is returned from the `get_block` method. There are many different types of blocks supported by Notion, and the current list of Blocks supported by this wrapper include:
1. Page
2. Quote
3. Numbered List
4. Image
5. Latex
6. Callout
7. Table of Contents
8. Column List
9. Text
10. Divider
11. To-Do
12. Code
13. Toggle
14. Bulleted List
15. Header
16. Sub-Header
17. Sub-Sub-Header

Each of these classes has access to the following methods:
1. `title=` → change the title (content) of a block.
```ruby
>>> @block = @client.get_block("d2ce338f-19e8-47f5-86bd-17679f490e66")
>>> @block.title # get the current title...
"Current Title"
>>> @block.title= "New Title Here" # lets update it...
>>> @block.title
"New Title Here"
```
2. `update` → Change the styling of a block.
[TODO]
3. `convert` → convert a block to a different type.
```ruby
>>> @block = @client.get_block("d2ce338f-19e8-47f5-86bd-17679f490e66")
>>> @block.convert(Notion::CalloutBlock)
>>> @block.type
"callout"
>>> @block # new class instance returned...
#<Notion::CalloutBlock:0x00007ffb75b19ea0 **omitted meta-data**>
```
4. `duplicate`→ duplicate the current block.
[TODO]
5. `revert`→ reverts the most recent change.
[TODO]
## Creating New Blocks
In Notion, the parent ID for a block that is **not** nested is the page that the block appears on. For nested blocks, the parent ID is the block that the nested block appears within. For example, the parent ID for a block contained within a toggle block **is** the toggle block. But, the toggle block's parent ID, as long as it is not nested within another block, is the page that the toggle block appears on. Given this tree-like structure, it made intuitive sense to build the wrapper with similar functionality:
- when the `create` method is called on a `PageBlock` instance, a non-nested block is created on that page, and its parent ID is the ID of the `PageBlock`
- when the `create` method is called on a non-`PageBlock` instance, a nested block is created that belongs to the instance the `create` method is invoked upon.

In any situation, a developer is only two lines of code away from creating a new block:
1. use the `get_block` method to retrieve the page or block in which you want to create a new block.
2. use the `create` method on the class returned from the `get_block` call to create the new non-nested or nested block. For example:
```ruby
>>> client = Notion::Client.new("<insert_v2_token_here>")
>>> @block = @client.get_block("https://www.notion.so/danmurphy/TEST-PAGE-d2ce338f19e847f586bd17679f490e66") # grab a page block...
>>> @my_new_block = @block.create("Enter title here...", Notion::CalloutBlock) # lets create a callout block...
>>> @my_new_block
#<Notion::CalloutBlock:0x00008g9345d4ea09 **omitted meta-data**>
>>> @block = @client.get_block("4ee54585-6fbb-4f2f-b482-373c38370c61") # grab a toggle block...
>>> @my_new_block = @block.create("Enter title here...", Notion::CalloutBlock) # lets create a nested callout block...
>>> @my_new_block
#<Notion::CalloutBlock:0x00008g3324r4ea18 **omitted meta-data**>
```