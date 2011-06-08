$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongoid'
require File.expand_path(File.dirname(__FILE__) + "/support/connection")
require File.expand_path(File.dirname(__FILE__) + "/support/category")
require 'rspec'
require 'mongestry'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
