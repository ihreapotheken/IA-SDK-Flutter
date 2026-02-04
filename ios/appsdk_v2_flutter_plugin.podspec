#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint appsdk_v2_flutter_plugin.podspec` to validate before publishing.
#

# Read IOS_APPSDK_VERSION from .env file
# Search upwards through directory tree to find .env containing IOS_APPSDK_VERSION
# Resolve symlinks to get the real path of the plugin
current_dir = File.realpath(__dir__)
ios_appsdk_version = nil

10.times do
  candidate = File.join(current_dir, '.env')
  if File.exist?(candidate)
    env_content = File.read(candidate)
    version_match = env_content.match(/IOS_APPSDK_VERSION\s*=\s*"?([^"\n]+)"?/)
    if version_match
      ios_appsdk_version = version_match[1].strip.gsub('"', '')
      break
    end
  end
  parent = File.dirname(current_dir)
  break if parent == current_dir # reached root
  current_dir = parent
end

unless ios_appsdk_version
  raise "Error: .env file with IOS_APPSDK_VERSION not found"
end

Pod::Spec.new do |s|
  s.name             = 'appsdk_v2_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/**/*'
  s.dependency 'Flutter'
  s.dependency 'IAIntegrations', ios_appsdk_version
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'

  s.resource_bundles = {'appsdk_v2_flutter_plugin_privacy' => ['appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/PrivacyInfo.xcprivacy']}
end
