# frozen_string_literal: true

require_relative 'blocks'
require_relative 'core'
require 'csv'

module Notion
  # acts as the 'gateway interface' to the methods of this package.
  class Client < Core
    attr_reader :token_v2, :active_user_header

    def initialize(token_v2, active_user_header = nil)
      @token_v2 = token_v2
      @active_user_header = active_user_header
      super(token_v2, active_user_header)
    end
  end
end