module ActsAsHistoricalParameter
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_historical_parameter(name, ident)
      define_method(name) do
        @historical_parameters ||= {}
        @historical_parameters[name]
      end
      define_method("#{name}=") do |value|
        @historical_parameters ||= {}
        @historical_parameters[name] = value
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsHistoricalParameter
