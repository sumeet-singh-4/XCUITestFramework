#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'XCUITestFramework.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# Create main target (just a placeholder app that won't be used)
main_target = project.new_target(:application, 'XCUITestRunner', :ios, '15.0')

# Create UI Test target
ui_test_target = project.new_target(:ui_test_bundle, 'XCUITestFrameworkUITests', :ios, '15.0')
ui_test_target.add_dependency(main_target)

# Add test files to UI test target
test_group = project.new_group('XCUITestFrameworkUITests')
['Tests/BaseTest.swift', 'Tests/LoginTest.swift'].each do |file|
  file_ref = test_group.new_file("XCUITestFrameworkTests/#{file}")
  ui_test_target.add_file_references([file_ref])
end

# Add framework files as references (not compiled, just linked)
framework_group = project.new_group('XCUITestFramework')
Dir.glob('XCUITestFramework/**/*.swift').each do |file|
  framework_group.new_file(file)
end

# Configure build settings
ui_test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.test.XCUITestFrameworkUITests'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['TEST_TARGET_NAME'] = 'XCUITestRunner'
  config.build_settings['SWIFT_VERSION'] = '5.0'
end

project.save
puts "✅ Created Xcode project: #{project_path}"
