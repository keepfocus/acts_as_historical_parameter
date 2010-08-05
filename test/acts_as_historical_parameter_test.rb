require 'test_helper'

class Installation < ActiveRecord::Base
  acts_as_historical_parameter :area, 1
end

class HistoricParameter < ActiveRecord::Base
  belongs_to :parameterized, :polymorphic => true
end

class ActsAsHistoricalParameterTest < ActiveSupport::TestCase
  load_schema

  def setup
    Installation.delete_all
    HistoricParameter.delete_all
  end

  test "schema has loaded correctly" do
    assert_equal [], Installation.all
    assert_equal [], HistoricParameter.all
  end

  test "historic parameter works like regualar attribute" do
    installation = Installation.new
    installation.area = 42.0
    assert_equal 42.0, installation.area
  end

  test "historic parameter has a history" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 01, 01))
    installation.set_area(43, Time.zone.local(2010, 02, 01))
    assert_equal 43, installation.area
    installation.save
    expected = [
      [Time.zone.local(2010, 01, 01), Time.zone.local(2010, 02, 01), 42],
      [Time.zone.local(2010, 02, 01), nil, 43]
    ]
    assert_equal expected, installation.area_values
  end
end
