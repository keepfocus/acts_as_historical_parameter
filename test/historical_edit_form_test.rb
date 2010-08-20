require 'test_helper'

class HistoricalEditFormTest < ActiveSupport::TestCase
  load_schema

  def setup
    @template = ActionView::Base.new
    @template.output_buffer = ""
    stub(@template).url_for { "" }
    stub(@template).installations_path { "" }
    stub(@template).protect_against_forgery? { false }
  end  

  test "historical_form_for creates form" do
    output = @template.historical_form_for(Installation.new) {}
    assert_match /<form[^>]*>.*<\/form>/, output
  end

  test "historical_form_for appends content to end of nested form" do
    @template.after_historical_form { "123" }
    @template.after_historical_form { "456" }
    output = @template.historical_form_for(Installation.new) {}
    assert output.include? "123456"
  end
  
  test "after_historical_form content comes after form" do
    @template.after_historical_form { "123" }
    output = @template.historical_form_for(Installation.new) {
      @template.after_historical_form { "456" }
    }
    assert_match /<form[^>]*>.*<\/form>.*123456/, output
  end

end
