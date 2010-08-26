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
    @template.historical_form_for(DummyInstallation.new) {}
    assert_match /<form[^>]*>.*<\/form>/, @template.output_buffer
  end

  test "historical_form_for passes form builder to form_for along with other options" do
    mock(@template).form_for(:first, :second, :other => :arg, :builder => ActsAsHistoricalParameter::HistoricalFormBuilder)
    @template.historical_form_for(:first, :second, :other => :arg)
  end

  test "instance of ActsAsHistoricalParameter::HistoricalFormBuilder is passed to historical_form_for block" do
    @template.historical_form_for(:dummy_installation, DummyInstallation) do |f|
      assert_instance_of ActsAsHistoricalParameter::HistoricalFormBuilder, f
    end
  end
 
  test "historical_form_for appends content to end of nested form" do
    @template.after_historical_form { @template.concat "123" }
    @template.after_historical_form { @template.concat "456" }
    @template.historical_form_for(DummyInstallation.new) {}
    assert @template.output_buffer.include? "123456"
  end
 
  test "after_historical_form content comes after form" do
    @template.after_historical_form { @template.concat '<span id="before">1</span>' }
    @template.historical_form_for(DummyInstallation.new) {
      @template.after_historical_form { @template.concat '<span id="inside">1</span>' }
    }
    output = @template.output_buffer
    assert_select_string output, "form ~ span#before"
    assert_select_string output, "form ~ span#inside"
    assert_select_string output, "form span#before", false
    assert_select_string output, "form span#inside", false
  end

  test "historical_value_fields inserts fields required for a value" do
    value = HistoricalParameter.new
    @template.fields_for 'area_history', value, :builder => ActsAsHistoricalParameter::HistoricalFormBuilder do |b|
      @template.concat b.historical_value_fields
    end
    output = @template.output_buffer
    assert_select_string output, "input[name=?][type=text]", "area_history[value]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(1i)]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(2i)]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(3i)]"
    assert_select_string output, "input[name=?][type=checkbox]", "area_history[_destroy]"
  end

  test "new_history_value_button is inserted into form and template outside" do
    @template.historical_form_for(DummyInstallation.new) { |f|
      @template.concat f.new_history_value_button :area
    }
    output = @template.output_buffer
    assert_select_string output, "form.new_dummy_installation" do
      assert_select "input.add_historical_value[type=submit][name=add_area_history_value][data-association=area_history]"
      assert_select "input[name=?]", "dummy_installation[area_history_attribute][new_area_history][value]", false
    end
    assert_select_string output, "table#area_history_fields_template" do
      assert_select "tbody tr td input[name=?]", "dummy_installation[area_history_attributes][new_area_history][value]", 1
      assert_select "tbody tr td select[name=?]", "dummy_installation[area_history_attributes][new_area_history][valid_from(1i)]", 1
      assert_select "tbody tr td select[name=?]", "dummy_installation[area_history_attributes][new_area_history][valid_from(2i)]", 1
      assert_select "tbody tr td select[name=?]", "dummy_installation[area_history_attributes][new_area_history][valid_from(3i)]", 1
      assert_select "tbody tr td input[name=?][type=checkbox]", "dummy_installation[area_history_attributes][new_area_history][_destroy]", 1
    end
  end

  test "history_edit_table_for should create table for editing values over time" do
    installation = DummyInstallation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    output = @template.output_buffer
    assert_select_string output, "table > tbody" do
      assert_select "tr", 2
      assert_select "tr > th", "Value"
      assert_select "tr th", "Valid from"
      assert_select "tr td input[name=?]", "dummy_installation[area_history_attributes][0][value]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(4i)]", false
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(5i)]", false
      assert_select "tr td.destroy_historical_value" do
        assert_select "input[name=?][type=checkbox]", "dummy_installation[area_history_attributes][0][_destroy]", 1
      end      
    end
  end

  test "history_edit_table_for should show time if instructed to" do
    installation = DummyInstallation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area, :show_time => true
    }
    output = @template.output_buffer
    assert_select_string output, "table > tbody" do
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(4i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(5i)]", 1
    end
  end

  test "history_edit_table_for should also work with saved and reloaded instance" do
    installation = DummyInstallation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 1, 1)
    installation.area_history.build :value => 43, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    installation = DummyInstallation.find(installation.to_param)
    @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    output = @template.output_buffer
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "input[name=?]", "dummy_installation[area_history_attributes][0][id]", 1
      assert_select "input[name=?]", "dummy_installation[area_history_attributes][1][id]", 1
      assert_select "tr", 3
      assert_select "tr td input[name=?]", "dummy_installation[area_history_attributes][0][value]", 1
      assert_select "tr td input[name=?]", "dummy_installation[area_history_attributes][1][value]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][1][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][1][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td select[name=?]", "dummy_installation[area_history_attributes][1][valid_from(3i)]", 1
      assert_select "tr td input[name=?][type=checkbox]", "dummy_installation[area_history_attributes][0][_destroy]", 1
      assert_select "tr td input[name=?][type=checkbox]", "dummy_installation[area_history_attributes][1][_destroy]", 1
    end
  end

end
