# frozen_string_literal: true
require 'selenium/webdriver'

Capybara.configure do |config|
  config.javascript_driver = :selenium
  config.raise_server_errors = false # Ignore errors due to missing images
  config.enable_aria_label = true # Match fields against aria-label attribute

  # Allow overriding selenium browser from environment
  # Always uses "selenium" for capybara so that screenshots work
  case ENV["CAPYBARA_DRIVER"]
  when "remote"
    # We use remote in docker compose to drive headless chrome in another container
    selenium_host = ENV.fetch("SELENIUM_HOST", "127.0.0.1")
    selenium_port = ENV.fetch("SELENIUM_PORT", "4444")

    # Selenium container needs to talk back to us, but docker-compose run
    # doesn't use a stable hostname, so listen on all addresses and ask for the
    # current hostname and tell selenium to connect back on that.
    config.server = :puma
    config.server_host = "0.0.0.0"
    config.app_host = "http://#{Socket.gethostname}"
    config.always_include_port = true

    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new app,
        browser: :remote,
        url: "http://#{selenium_host}:#{selenium_port}/wd/hub",
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
          chromeOptions: { args: %w[--headless --disable-gpu --no-sandbox --window-size=1280,960] }
        )
    end
  else # headless_chrome
    # Override selenium so screenshots still work
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new app,
        browser: :chrome,
        driver_opts: {log_path: Rails.root.join("log/chrome.log").to_s},
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
          # macOS inherits display's dpi causing odd screenshots so force a scale factor
          chromeOptions: { args: %w[--headless --disable-gpu --force-device-scale-factor=1 --window-size=1280,960] }
        )
    end
  end

  # Bump the default wait time on CI (locally it's fine)
  config.default_max_wait_time = 90 if ENV["CI"]
  config.save_path = Rails.root.join("tmp/capybara")
end

# rails 5.1 introduced system tests which are embraced in rspec-rails 3.7 and
# which do a bunch of rando stuff including starting a noisy puma server. Tell
# it to be quiet.
if defined? ActionDispatch::SystemTesting
  ActionDispatch::SystemTesting::Server.silence_puma = true
end

# When using selenium in feature specs sometimes it fails to create a session.
# If it looks like this is a feature spec using capybara with a selenium driver
# then touch the selenium browser which sends the "create session" command to
# the selenium server. If that fails, try another time.
RSpec.configure do |config|
  config.before(type: :feature) do
    if Capybara.current_session.driver.is_a? Capybara::Selenium::Driver
      begin
        Capybara.current_session.driver.browser
      rescue => e
        Rails.logger.info "Selenium driver failed to create a session, trying again"
        Rails.logger.info e
        Capybara.current_session.driver.browser
      end
    end
  end
end

# Make sure that all cookies are cleared after feature specs
# "delete_all_cookies" actually means "Delete all the cookies for the current
# domain" so it needs to be run while a page is loaded on the app domain, so we
# do it after each feature spec while we're presumably still on an app page.
# It's not perfect, but it seems to work in practise.
RSpec.configure do |config|
  config.after(type: :feature) do
    if Capybara.current_session.driver.is_a? Capybara::Selenium::Driver
      Capybara.current_session.driver.browser.manage.delete_all_cookies
    end
  end
end

# When selenium is running remote, it can run into problems uploading files.
# The recommendation is the set the file_detector:
# https://github.com/SeleniumHQ/selenium/blob/2abd80f236d1a7459ef638e96af8c4efd86b4abd/rb/lib/selenium/webdriver/common/driver_extensions/uploads_files.rb#L38-L43
# This should probably be further scoped down.
RSpec.configure do |config|
  config.before(:each, type: :feature, js: true) do
    Capybara.current_session.driver.browser.file_detector = lambda do |args|
      str = args.first.to_s
      str if File.exist?(str)
    end
  end
end
