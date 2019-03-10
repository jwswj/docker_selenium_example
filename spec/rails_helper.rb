require 'spec_helper'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Ensure that if we are running js tests, we are using latest webpack assets
  # This will use the defaults of :js and :server_rendering meta tags
  # ReactOnRails::TestHelper.configure_rspec_to_compile_assets(config)

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.include ActionDispatch::TestProcess

  config.filter_rails_from_backtrace!
end
