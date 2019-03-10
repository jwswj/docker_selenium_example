ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'active_support/all'

RSpec.configure do |config|
  config.order = :random

  Kernel.srand config.seed

  config.disable_monkey_patching!
end
