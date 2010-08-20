require 'test_helper'

class ActsAsHistoricalParameterTest < ActiveSupport::TestCase
  load_schema

  setup do
    @template = ActionView::Base.new
    @template.output_buffer = ""
    stub(@template).url_for { "" }
    stub(@template).installations_path { "" }
    stub(@template).protect_against_forgery? { false }
  end  

  test "historical_form_for appends content to end of nested form" do
    @template.after_historical_form { "123" }
    @template.after_historical_form { "456" }
    output = @template.historical_form_for(Installation.new) {}
    assert output.include? "123456"
  end
  
end
