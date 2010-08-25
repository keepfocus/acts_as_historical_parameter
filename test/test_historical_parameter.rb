require File.join(File.dirname(__FILE__), 'test_helper')

class TestHistoricalParameter < ActiveSupport::TestCase
  def test_historical_parameter
    assert_kind_of HistoricalParameter, HistoricalParameter.new
  end
end
