require File.join(File.dirname(__FILE__), 'test_helper')

class TestHistoricalEditForm < ActiveSupport::TestCase
  def setup
    @template = ActionView::Base.new
    @template.output_buffer = ""
    stub(@template).url_for { "" }
    stub(@template).installation_path { "" }
    stub(@template).installations_path { "" }
    stub(@template).protect_against_forgery? { false }
  end  

  test "historical_form_for creates form" do
    output = @template.historical_form_for(DummyInstallation.new) {}
    assert_match /<form[^>]*>.*<\/form>/, output
  end

  test "historical_form_for appends content to end of nested form" do
    @template.after_historical_form { "123" }
    @template.after_historical_form { "456" }
    output = @template.historical_form_for(DummyInstallation.new) {}
    assert output.include? "123456"
  end
  
  test "after_historical_form content comes after form" do
    @template.after_historical_form { @template.content_tag :span, "1", :id => "before" }
    output = @template.historical_form_for(DummyInstallation.new) {
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

  test "new_history_value_button is inserted into form and template outside" do
    output = @template.historical_form_for(DummyInstallation.new) { |f|
      f.new_history_value_button :area
    }
    assert_select_string output, "form.new_dummy_installation" do
      assert_select "input.add_historical_value[type=submit][name=add_area_history_value][data-association=area_history]"
      assert_select "input[name=?]", "dummy_installation[area_history_attribute][new_area_history][value]", false
    end
    assert_select_string output, "table#area_history_fields_template" do
      assert_select "tbody tr td input[name=?]", "dummy_installation[area_history_attributes][new_area_history][value]"
    end
  end

  test "history_edit_table_for should create table for editing values over time" do
    installation = DummyInstallation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    assert_select_string output, "table > tbody" do
      assert_select "tr", 2
      assert_select "tr > th", "Value"
      assert_select "tr th", "Valid from"
      assert_select "tr td input[name=?]", "dummy_installation[area_history_attributes][0][value]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td input[name=?][type=checkbox]", "dummy_installation[area_history_attributes][0][_destroy]", 1
    end
  end

end
