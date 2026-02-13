ENV["RAILS_ENV"] ||= "test"

require "selenium/webdriver"
require "support/capybara"

RSpec.configure do |config|
  config.around(:each, :smoke_test, type: :system) do |example|
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.run_server = false
    Capybara.app_host = external_host

    example.run

    Capybara.app_host = nil
    Capybara.run_server = true
    Capybara.current_driver = Capybara.default_driver
  end
end

private

def external_host
  "http://#{ENV.fetch('EXTERNAL_HOST', '127.0.0.1:3000')}"
end
