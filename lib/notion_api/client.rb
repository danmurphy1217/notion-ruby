# frozen_string_literal: true

require_relative "core"
require_relative "blocks"

module NotionAPI
  # acts as the 'main interface' to the methods of this package.
  class Client < Core
    attr_reader :token_v2, :active_user_header

    def initialize(token_v2, active_user_header = nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      super(token_v2, active_user_header)
    end
  end
end