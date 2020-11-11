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

@block = @client.get_block(url_or_id="bfe133c350ad4f21850a44e89054b54d", options)
p @block