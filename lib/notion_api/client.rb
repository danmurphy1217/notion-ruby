
require "httparty"
require_relative "mappings"

module Notion
    class Client
        include HTTParty
        base_uri "https://www.notion.so/api/v3" # root URI for all requests
        p base_uri
        attr_reader :token_v2
        # all that's needed for instantiation is the v2_token
        def initialize(token_v2)
            @token_v2 = token_v2
            @cookies = { :token_v2.to_s => token_v2}
            @headers = {'Content-Type' => 'application/json'}
        end
        def get_block(page_id, chunk_number=0, limit=50, vertical_columns=true)
            request_url = self.class.base_uri + Mappings.mappings[:get_block]
            
            request_body = {
                :pageId => page_id,
                :chunkNumber => chunk_number,
                :limit => limit,
                :verticalColumns => vertical_columns,
            }
            response = HTTParty.post(
                request_url,
                :body => request_body.to_json,
                :cookies => @cookies,
                :headers => @headers
            )
            return JSON.parse(response.body)["recordMap"]["block"]["#{page_id}"]["value"]["properties"]["title"], JSON.parse(response.body)["recordMap"]["block"]["#{page_id}"]["value"]
        end
    end
end

notion = Notion::Client.new("ec4db968e894dd7b5b20a36de10e80c7bb18a7717e49bae9089e694a3d693957b09d88c5cda10e22dfb44a349cacd2516cb8c5b6a55ae79da2a100084410fac249b08eb6d8d0c1db3e8840eeced4")
p notion.get_block("71728e4a-fc6d-41a8-abef-e6c00ac781fc")
# 68fcb122-0fd9-44f8-9ff7-0f1f0bc925af
# c7e1114a-f161-4b94-a7e7-704fd13d5545


# 081e0123-a257-45f0-bb5f-2e7d55a9c0b2
# 24dadfd5-0c81-4ea0-85f6-c70c47f60308 # this block comes directly after 081e0123-*

# 71728e4a-fc6d-41a8-abef-e6c00ac781fc
# e9243458-1edc-45ef-8765-8948e3ddbc8b