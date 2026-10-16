#!/usr/bin/env ruby
# Adds a build flavor to the example app's iOS project, the way `flutter --flavor` expects it: Debug-, Release- and
# Profile-<flavor> configurations copied from Debug, Release and Profile, and a <flavor> scheme copied from Runner.
# For an existing flavor, it only updates the display name.
#
# Every flavor keeps the app's bundle ID and signing, so it's delivered like the demo, with no further App IDs or
# provisioning profiles. Only the display name differs.
#
# Usage:
#   ruby scripts/add-example-ios-flavor.rb <flavor> <display name>
#   ruby scripts/add-example-ios-flavor.rb singleEntryPoint 'IA SDK Single Entry Point'
#
# Uses the xcodeproj gem, which comes with CocoaPods. The flavor also needs an Android product flavor and a value in
# example/lib/flavor.dart, see example/README.md.

require 'xcodeproj'

flavor, display_name = ARGV
abort 'Usage: ruby scripts/add-example-ios-flavor.rb <flavor> <display name>' unless display_name

ios_dir = File.expand_path('../example/ios', __dir__)
project = Xcodeproj::Project.open(File.join(ios_dir, 'Runner.xcodeproj'))
runner = project.targets.find { |target| target.name == 'Runner' }
configuration_lists = [project.build_configuration_list] + project.targets.map(&:build_configuration_list)

%w[Debug Release Profile].each do |mode|
  name = "#{mode}-#{flavor}"
  configuration_lists.each do |list|
    next if list[name]

    base = list[mode]
    configuration = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
    configuration.name = name
    configuration.base_configuration_reference = base.base_configuration_reference
    configuration.build_settings = Marshal.load(Marshal.dump(base.build_settings))
    list.build_configurations << configuration
  end

  settings = runner.build_configuration_list[name].build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = runner.build_configuration_list[mode].build_settings['PRODUCT_BUNDLE_IDENTIFIER']
  settings['IA_DISPLAY_NAME'] = display_name
end
project.save

schemes_dir = File.join(ios_dir, 'Runner.xcodeproj', 'xcshareddata', 'xcschemes')
scheme = File.read(File.join(schemes_dir, 'Runner.xcscheme'))
  .gsub(/buildConfiguration = "(Debug|Release|Profile)"/) { %(buildConfiguration = "#{Regexp.last_match(1)}-#{flavor}") }
File.write(File.join(schemes_dir, "#{flavor}.xcscheme"), scheme)

puts "Set up the #{flavor} flavor: #{%w[Debug Release Profile].map { |mode| "#{mode}-#{flavor}" }.join(', ')}, scheme #{flavor}"
