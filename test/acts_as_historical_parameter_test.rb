require 'test_helper'

class ActsAsHistoricalParameterTest < ActiveSupport::TestCase
  load_schema

  class Installation < ActiveRecord::Base
    acts_as_historical_parameter :area, 1
  end

  def setup
    Installation.delete_all
    HistoricalParameter.delete_all
  end

  test "schema has loaded correctly" do
    assert_equal [], Installation.all
    assert_equal [], HistoricalParameter.all
  end

  test "historic parameter works like regualar attribute" do
    installation = Installation.new
    installation.area = 42.0
    assert_equal 42.0, installation.area
  end

  test "historic parameter ignores set to nil value" do
    installation = Installation.new
    installation.area = 42.0
    installation.area = nil
    assert_equal 42.0, installation.area
  end

  test "historic parameter can be undefined" do
    installation = Installation.new
    assert_nil installation.area
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

  test "callback history within timeslot for area #1" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 1, 1))
    installation.set_area(43, Time.zone.local(2010, 2, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 1, 1), Time.zone.local(2010, 2, 1)) {1}
    mock(dummy).calculate(Time.zone.local(2010, 2, 1), Time.zone.local(2010, 3, 1)) {2}
    result = installation.area_sum(Time.zone.local(2010, 1, 1), Time.zone.local(2010, 3, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 1*42 + 2*43, result
  end

  test "callback history within timeslot for area #2" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 1, 1))
    installation.set_area(43, Time.zone.local(2010, 2, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 2, 1), Time.zone.local(2010, 3, 1)) {2}
    result = installation.area_sum(Time.zone.local(2010, 2, 1), Time.zone.local(2010, 3, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 2*43, result
  end

  test "callback history within timeslot for area #3" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 1, 1))
    installation.set_area(43, Time.zone.local(2010, 2, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 1, 15), Time.zone.local(2010, 2, 1)) {1}
    result = installation.area_sum(Time.zone.local(2010, 1, 15), Time.zone.local(2010, 2, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 42, result
  end

  test "edit parameter history through model" do
    installation = Installation.new
    installation.update_attributes({
      :historical_parameters_attributes => [
        {:valid_from => Time.zone.local(2010, 1, 1), :value => 42, :ident => 1},
        {:valid_from => Time.zone.local(2010, 2, 1), :value => 43, :ident => 1}
      ]
    })
    installation.save
    assert_equal 43, installation.area
    expected = [
      [Time.zone.local(2010, 01, 01), Time.zone.local(2010, 02, 01), 42],
      [Time.zone.local(2010, 02, 01), nil, 43]
    ]
    assert_equal expected, installation.area_values
  end

  test "edit parameter history through model (direct association)" do
    installation = Installation.new
    installation.update_attributes({
      :area_history_attributes => [
        {:valid_from => Time.zone.local(2010, 1, 1), :value => 42},
        {:valid_from => Time.zone.local(2010, 2, 1), :value => 43}
      ]
    })
    installation.save
    assert_equal 43, installation.area
    expected = [
      [Time.zone.local(2010, 01, 01), Time.zone.local(2010, 02, 01), 42],
      [Time.zone.local(2010, 02, 01), nil, 43]
    ]
    assert_equal expected, installation.area_values
  end

end
