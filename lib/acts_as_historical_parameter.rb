%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

module ActsAsHistoricalParameter
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def define_historical_getter(name, ident)
      define_method(name) do
        @historical_parameter ||= {}
        @historical_parameter[name] ||= historical_parameters.first :conditions => ["ident = ?", ident], :order => "valid_from DESC"
        @historical_parameter[name].value
      end
    end

    def define_historical_setter(name, ident)
      define_method("set_#{name}") do |value, from|
        @historical_parameter ||= {}
        @historical_parameter[name] = historical_parameters.build :ident => ident, :valid_from => from, :value => value
      end
      define_method("#{name}=") do |value|
        self.send "set_#{name}", value, Time.zone.now
      end
    end

    def define_historical_values(name, ident)
      define_method("#{name}_values") do
        hps = historical_parameters.all(:conditions => ["ident = ?", ident], :order => "valid_from")
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

    def define_historical_sum(name)
      class_eval <<-EOM
        def #{name}_sum(start_time, end_time)
          #{name}_values.sum do |entry|
            if entry[1] and start_time < entry[1]
              if start_time > entry[0]
                yield start_time, entry[1], entry[2]
              else
                yield entry[0], entry[1], entry[2]
              end
            elsif entry[1].nil? and end_time > entry[0]
              yield entry[0], end_time, entry[2]
            else
              0
            end
          end
        end
      EOM
    end

    def acts_as_historical_parameter(name, ident)
      has_many :historical_parameters, :as => :parameterized unless defined? historical_parameters
      define_historical_getter(name, ident)
      define_historical_setter(name, ident)
      define_historical_values(name, ident)
      define_historical_sum(name)
    end
  end
end

ActiveRecord::Base.send :include, ActsAsHistoricalParameter
