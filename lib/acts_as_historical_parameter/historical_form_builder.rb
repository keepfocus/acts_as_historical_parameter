module ActsAsHistoricalParameter
  class HistoricalFormBuilder < ActionView::Helpers::FormBuilder
    def new_history_value_button(parameter, options = {})
      add_label = options.delete(:add_label) || I18n.t('acts_as_historical_parameter.new_history_value', :default => "Add value")
      method = :"#{parameter}_history"
      object = self.object.class.reflect_on_association(method).klass.new
      @template.after_historical_form do
        @template.concat %Q[<table id="#{method}_fields_template" style="display:none;"><tbody>]
        fields_for method, object, :child_index => :"new_#{method}" do |f|
          @template.concat f.historical_value_fields
        end
        @template.concat '</tbody></table>'
      end
      self.submit add_label, {
        :class => "add_historical_value",
        :name => "add_#{method}_value",
        :"data-association" => method.to_s
      }
    end

    def historical_value_fields(options = {})
      @template.content_tag :tr do
        o = @template.content_tag :td do
          self.text_field(:value)
        end
        o += @template.content_tag :td do
          if options[:show_time]
            self.datetime_select(:valid_from)
          else
            self.date_select(:valid_from)
          end
        end
        o += @template.content_tag :td, :class => "destroy_historical_value" do
          self.check_box(:_destroy) + self.label(:_destroy, "Remove?")
        end
        o
      end
    end

    def history_edit_table_for(parameter, options ={})
      method = :"#{parameter}_history"
      @template.concat %Q[<table id="#{method}_table"><tbody>]
      @template.concat '<tr><th>Value</th><th>Valid from</th></tr>'
      self.fields_for method do |b|
        @template.concat b.historical_value_fields(options)
      end
      @template.concat '</tbody></table>'
    end
  end
end
