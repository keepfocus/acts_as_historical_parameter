require 'test_helper'

class Installation < ActiveRecord::Base
  acts_as_historical_parameter :area, 1
end

class HistoricParameter < ActiveRecord::Base
  belongs_to :parameterized, :polymorphic => true
end

class ActsAsHistoricalParameterTest < ActiveSupport::TestCase
  load_schema

  test "schema has loaded correctly" do
    assert_equal [], Installation.all
    assert_equal [], HistoricParameter.all
  end

  test "historic parameter works like regualar attribute" do
    installation = Installation.new
    installation.area = 42.0
    assert_equal 42.0, installation.area
  end
end
