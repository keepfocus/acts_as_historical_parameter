module ActsAsHistoricalParameter
  class HistoricalFormBuilder < ActionView::Helpers::FormBuilder
    def new_history_value_button(parameter, options = {})
      add_label = options.delete(:add_label) || "Add value"
      method = :"#{parameter}_history"
      object = self.object.class.reflect_on_association(method).klass.new
      @template.after_historical_form do
        @template.content_tag :table, :id => "#{method}_fields_template" do
          @template.content_tag :tbody do
            fields_for method, object, :child_index => :"new_#{method}" do |f|
              f.historical_value_fields
            end
          end
        end
      end
      self.submit add_label, {
        :class => "add_historical_value",
        :name => "add_#{method}_value",
        :"data-association" => method.to_s
      }
    end

    def historical_value_fields
      @template.content_tag :tr do
        o = @template.content_tag :td do
          self.text_field(:value)
        end
        o += @template.content_tag :td do
          self.datetime_select(:valid_from)
        end
        o += @template.content_tag :td do
          self.check_box(:_destroy) + self.label(:_destroy, "Remove?")
        end
        o
      end
    end

    def history_edit_table_for(parameter)
      method = :"#{parameter}_history"
      @template.content_tag :table, :id => "#{method}_table" do
        @template.content_tag :tbody do
          o = @template.content_tag :tr do
            @template.content_tag(:th, "Value") + @template.content_tag(:th, "Valid from")
          end
          o += self.fields_for method do |b|
            @template.concat b.historical_value_fields
          end
          o
        end
      end
    end
  end
end
