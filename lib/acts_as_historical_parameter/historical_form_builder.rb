module ActsAsHistoricalParameter
  class HistoricalFormBuilder < ActionView::Helpers::FormBuilder
    def new_history_value_button(parameter, options = {})
      add_label = options.delete(:add_label) || "Add value"
      self.submit add_label, :class => "add_historical_value", :name => "add_#{parameter}_value", :"data-association" => parameter.to_s
    end
  end
end
