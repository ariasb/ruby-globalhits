require 'appium_lib'
require 'selenium-webdriver'
require 'rspec'
require 'yaml'
require_relative '../pages/search_page'

caps_config = YAML.load_file(File.expand_path('../config/caps.yml', __dir__))

opts = {
  caps: caps_config['caps'],
  appium_lib: caps_config['appium_lib']
}

unless `adb devices`.lines.any? { |line| line.include?("\tdevice") }
  raise "Se te volvio a olvidar encender el emulador"
end

$driver = Appium::Driver.new(opts, false)
Appium.promote_appium_methods Object

RSpec.configure do |config|
  config.before(:all) do
    $driver.start_driver
    begin
      $driver.terminate_app(caps_config['caps']['appPackage'])
    rescue => e
      puts "No se cerro: #{e.message}"
    end
    $driver.activate_app(caps_config['caps']['appPackage'])
  end

  config.after(:all) do
    $driver.driver_quit
  end
end

def driver
  $driver
end
