require 'test_helper'

class ActsAsHistoricalParameterTest < ActiveSupport::TestCase
  load_schema

  class Installation < ActiveRecord::Base
  end

  class HistoricParameter < ActiveRecord::Base
    belongs_to :parameterized, :polymorphic => true
  end

  test "schema has loaded correctly" do
    assert_equal [], Installation.all
    assert_equal [], HistoricParameter.all
  end
end
