ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'rubygems'
require 'test/unit'
require 'rr'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

class Installation < ActiveRecord::Base
  acts_as_historical_parameter :area, 1
end

class ActiveSupport::TestCase
  include RR::Adapters::TestUnit
  include ActionDispatch::Assertions

  def self.load_schema
    config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
    ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

    db_adapter = ENV['DB']

    # no db passed, try one of these fine config-free DBs before bombing.
    db_adapter ||=
      begin
        require 'sqlite'
        'sqlite'
      rescue MissingSourceFile
        begin
          require 'sqlite3'
          'sqlite3'
        rescue MissingSourceFile
        end
      end

    if db_adapter.nil?
      raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
    end

    ActiveRecord::Base.establish_connection(config[db_adapter])
    load(File.dirname(__FILE__) + "/schema.rb")
  end

  def assert_select_string(string, *selectors, &block)
    doc_root = HTML::Document.new(string).root
    assert_select(doc_root, *selectors, &block)
  end
  
end
