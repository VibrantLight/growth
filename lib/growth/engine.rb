require "rubygems"
require "pry"
require "dry-transaction"

module Growth
  class Engine < ::Rails::Engine
    isolate_namespace Growth 
  end
end