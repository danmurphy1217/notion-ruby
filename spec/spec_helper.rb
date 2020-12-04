require "notion_api"
require_relative "spec_variables"

# TODO: missing testing concepts:
# 1. tables and other CVs with missing data (i.e. how do the methods perform when there is a null cell)
# 2. tables and other CVs with entirely blank rows (i.e. how do the methods perform when there is an entirely null cell)
# 3. CV page IDs different from regular Page IDs, so that should be fixed.

RSpec.configure do |conf|
  conf.before(:example) do

    conf.include Helpers
  end
end