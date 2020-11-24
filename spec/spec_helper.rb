require "notion_api"
require_relative "spec_variables"

RSpec.configure do |conf|
  conf.before(:example) do

    conf.include Helpers
  end
end