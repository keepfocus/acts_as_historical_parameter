module ActsAsHistoricalParameter
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_historical_parameter(name, ident)
      has_many :historic_parameters, :as => :parameterized unless defined? historic_parameters      
      define_method(name) do
        @historical_parameters ||= {}
        @historical_parameters[name] ||= historic_parameters.first :conditions => ["ident = ?", ident], :order => "valid_from DESC"
        @historical_parameters[name].value
      end
      define_method("set_#{name}") do |value, from|
        @historical_parameters ||= {}
        @historical_parameters[name] = historic_parameters.build :ident => ident, :valid_from => from, :value => value
      end
      define_method("#{name}=") do |value|
        self.send "set_#{name}", value, Time.zone.now
      end
      define_method("#{name}_values") do
        hps = historic_parameters.all(:conditions => ["ident = ?", ident], :order => "valid_from")
        values = []
        if hps.length >= 2
          values = hps.each_cons(2).collect do |a|
            [
              a[0].valid_from,
              a[1].valid_from,
              a[0].value
            ]
          end
        end
        lv = hps.last
        if lv
          values + [[lv.valid_from, nil, lv.value]]
        else
          nil
        end
      end      
    end
  end
end

ActiveRecord::Base.send :include, ActsAsHistoricalParameter
