module ActsAsHistoricalParameter
  class HistoricalFormBuilder < ActionView::Helpers::FormBuilder
    def new_history_value_button(parameter, options = {})
      add_label = options.delete(:add_label) || "Add value"
      self.submit add_label, :class => "add_historical_value", :name => "add_#{parameter}_value", :"data-association" => parameter.to_s
    end
    def historical_value_fields
      output = self.text_field(:value)
      output << self.datetime_select(:valid_from)
      output << self.check_box(:_destroy)
      output << self.label(:_destroy, "Remove?")
    end
  end
end
