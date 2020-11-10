# mappings for method requests => endpoints
# I decided to map certain requests to isolated endpoints in an effort to make it easy to maintain them should Notion ever make internal changes.

class Mappings
    def self.mappings
        return {
            :get_block => "/loadPageChunk"
        }
    end
end