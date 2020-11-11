require "httparty"
require_relative "types"
module Notion
    class Resource < Types
        include HTTParty
        base_uri "https://www.notion.so/api/v3"

        attr_reader :token_v2, :clean_id, :cookies, :headers
        def initialize(token_v2, clean_id, options={})
            @clean_id = clean_id
            @cookies = !options["cookies"].nil? ? options["cookies"] : { :token_v2.to_s => token_v2 }
            @headers = !options["headers"].nil? ? options["headers"] : {'Content-Type' => 'application/json'}
        end
    end
end