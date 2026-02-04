#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ia_cardlink.podspec` to validate before publishing.
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
  s.name             = 'ia_cardlink'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'ia_cardlink/Sources/ia_cardlink/**/*'
  s.dependency 'Flutter'
  s.dependency 'IACore', ios_appsdk_version
  s.dependency 'IAIntegrations', ios_appsdk_version
  s.dependency 'IACardLink', ios_appsdk_version
  s.platform = :ios, '15.0'
  s.swift_version = '5.9'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'ia_cardlink_privacy' => ['ia_cardlink/Sources/ia_cardlink/PrivacyInfo.xcprivacy']}
end
