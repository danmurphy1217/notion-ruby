require 'httparty'

# class User
#     include HTTParty
#     attr_reader :token_v2
    
#     def initialize(token_v2)
#         @token_v2 = token_v2
#         self.class.headers({'token_v2': token_v2})
#     end
# end

cookies ={
    "token_v2" => "ec4db968e894dd7b5b20a36de10e80c7bb18a7717e49bae9089e694a3d693957b09d88c5cda10e22dfb44a349cacd2516cb8c5b6a55ae79da2a100084410fac249b08eb6d8d0c1db3e8840eeced4"
}

# response_user_content = HTTParty.post('https://www.notion.so/api/v3/loadUserContent', :cookies => cookies)
# response_user_analytics = HTTParty.post('https://www.notion.so/api/v3/getUserAnalyticsSettings', :cookies => cookies)
# p response_user_content
# p "BREAK"
# p response_user_analytics
# p "BREAK"
# response_user_content = HTTParty.post("https://www.notion.so/api/v3/loadUserContent", :cookies => cookies)
# p response_user_content
# p "BREAK"

body = {
    :requests => [
        {
            :table => "block",
            :id => "1e52ad0f-013e-4f42-9325-bb014757874f",
            :version => -1
        }
    ]
}

# response_record_values = HTTParty.post(
#     "https://www.notion.so/api/v3/getRecordValues", 
#     :body => body.to_json,
#     :headers => {'Content-Type' => 'application/json'},
#     :cookies => cookies
# )
# p response_record_values.body
# p "BREAK"

response_page_chunk = HTTParty.post(
    "https://www.notion.so/api/v3/loadPageChunk",
    :body => {
        :pageId => "8a2db7b4-7351-48ae-b53b-4acf54e4e98d",
        :chunkNumber => 0,
        :limit => 50,
        :verticalColumns => true,
        # :stack => [[{:table => "block", :id => "8a2db7b4-7351-48ae-b53b-4acf54e4e98d", :index => 72}.to_json]]
    }.to_json, 
    :headers => {'Content-Type' => 'application/json'},
    :cookies => cookies
)

p response_page_chunk.body

# 7c45a47d-4a2e-4d5e-85a1-62632b367893