module ActsAsHistoricalParameter
  module ViewHelper
    def historical_form_for(*args, &block)
      options = args.extract_options!.reverse_merge(:builder => ActsAsHistoricalParameter::HistoricalFormBuilder)
      output = form_for(*args << options, &block)
      if @after_historical_form_callbacks
        fields = @after_historical_form_callbacks.each do |callback|
          output << callback.call
        end
      end
      output
    end

    def after_historical_form(&block)
      @after_historical_form_callbacks ||= []
      @after_historical_form_callbacks << block
    end
  end
end

class ActionView::Base
  include ActsAsHistoricalParameter::ViewHelper
end
