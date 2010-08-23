require File.join(File.dirname(__FILE__), 'test_helper')

class TestHistoricalEditForm < ActiveSupport::TestCase
  load_schema

  def setup
    @template = ActionView::Base.new
    @template.output_buffer = ""
    stub(@template).url_for { "" }
    stub(@template).installation_path { "" }
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
    @template.after_historical_form { @template.content_tag :span, "1", :id => "before" }
    output = @template.historical_form_for(Installation.new) {
      @template.after_historical_form { @template.content_tag :span, "1", :id => "inside" }
    }
    assert_select_string output, "form ~ span#before"
    assert_select_string output, "form ~ span#inside"
    assert_select_string output, "form span#before", false
    assert_select_string output, "form span#inside", false
  end

  test "historical_value_fields inserts fields required for a value" do
    value = HistoricalParameter.new
    output = @template.fields_for 'area_history', value, :builder => ActsAsHistoricalParameter::HistoricalFormBuilder do |b|
      @template.concat b.historical_value_fields
    end
    assert_select_string output, "input[name=?][type=text]", "area_history[value]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(1i)]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(2i)]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(3i)]"
    assert_select_string output, "input[name=?][type=checkbox]", "area_history[_destroy]"
  end

  test "new_history_value_button is inserted into form" do
    output = @template.historical_form_for(Installation.new) { |f|
      f.new_history_value_button :area
    }
    assert_select_string output, "form input.add_historical_value[type=submit][data-association=area]"
  end

end
