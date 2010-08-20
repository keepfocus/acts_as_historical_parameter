require 'test_helper'

class HistoricalParameterTest < ActiveSupport::TestCase
  load_schema

  def test_historical_parameter
    assert_kind_of HistoricalParameter, HistoricalParameter.new
  end
end
