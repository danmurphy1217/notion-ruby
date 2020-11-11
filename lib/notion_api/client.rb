require_relative "block"
module Notion
    attr_reader :token_v2
    class Client < Block
        def initialize(token_v2)
            @token_v2 = token_v2
        end
    end
end


@client = Notion::Client.new("ec4db968e894dd7b5b20a36de10e80c7bb18a7717e49bae9089e694a3d693957b09d88c5cda10e22dfb44a349cacd2516cb8c5b6a55ae79da2a100084410fac249b08eb6d8d0c1db3e8840eeced4")
# options for request
options = {}
options["cookies"] = {:token_v2 => "ec4db968e894dd7b5b20a36de10e80c7bb18a7717e49bae9089e694a3d693957b09d88c5cda10e22dfb44a349cacd2516cb8c5b6a55ae79da2a100084410fac249b08eb6d8d0c1db3e8840eeced4"}
options["headers"] = {'Content-Type' => 'application/json'}

@block = @client.get_block(url_or_id="6a1cf4ee-773f-49c4-b11a-e9e643cb9087", options)
children_ids = @client.get_block_children_ids(url_or_id="https://www.notion.so/danmurphy/Generic-Linux-CLI-24bb8c43a6c44561a5f5919d4bd86013", options)

all_page_ids = []
children_ids.each do |id|
    block = @client.get_block(id, options=options)[0]
    all_page_ids.push(@client.get_block_children_ids(block, options=options))
end

all_page_ids.flatten.each do |id|
    p @client.get_block(id, options=options)
end