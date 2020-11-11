# notion-ruby
Unofficial Notion Client for Ruby.

To utilize the API, you'll first need to retrieve your token_v2 credentials by signing into Notion in your browser of choice, inspecting the cookies, and finding the **token_v2** cookie. To retrieve your token_v2:
### In Chrome
1. Log into [notion](https://www.notion.so)
2. press cmd+shift+c (on Mac, control+shift+c on windows)
3. Navigate to application -> Store and click the Cookies dropdown
4. Find `token_v2` under the name column.

### In Safari
1. Same as above
2. press option+cmd+c (on Mac)
3. Navigate to Storage, open the Cookies folder, and then click on token_v2 to retrieve the correct value.

After this, you can instantiate the client with the following code:
```ruby
client = Notion::Client.new(<token_v2>)
```

After this instantiation, you can interface with the get_block method. This functionality is currently under development and being updated regularly, so things are likely to change.

```ruby
# these return the same response! You can access a block by providing us with either the full URL or the ID from the end of the URL.
client = Notion::Client.new(<token_v2>)
client.get_block("https://www.notion.so/danmurphy/Docker-6a1cf4ee773f49c4b11ae9e643cb9087")
client.get_block("6a1cf4ee773f49c4b11ae9e643cb9087")

# alternatively, if you want to do some extra work, you can also pre-package the ID for us:
client.get_block("6a1cf4ee-773f-49c4-b11a-e9e643cb9087")
```
# Upcoming features
1. Finalize the `get_block` method
2. Add class that defines the different block types (page, checkbox, etc...), and return the block as a class instance in the `get_block` method
3. Add functionality for updating data (seems like these methods should be attached to the block's type class)
