module ActsAsHistoricalParameter
  module ViewHelper
    def historical_form_for(*args, &block)
      @after_historical_form_callbacks.collect do |callback|
        callback.call
      end.join("")
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
