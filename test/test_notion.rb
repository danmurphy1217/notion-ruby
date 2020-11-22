require "minitest/autorun"
require "notion_api"

class HolaTest < Minitest::Test
  def test_config
    assert_equal "HI".downcase, "hi"
  end
end
