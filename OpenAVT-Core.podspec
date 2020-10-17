#
# Be sure to run `pod lib lint OpenAVT-Core.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OpenAVT-Core'
  s.version          = '0.1.0'
  s.summary          = 'Open Audio-Video Telemetry, core library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Open Audio-Video Telemetry, core library. It contains the base classes to build player specific trackers and vendor specific backends.
                       DESC
  s.swift_versions   = '5.0'
  s.homepage         = 'https://github.com/asllop/OpenAVT-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'asllop' => 'andreu.santaren@gmail.com' }
  s.source           = { :git => 'https://github.com/asllop/OpenAVT-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'OpenAVT-Core/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OpenAVT-Core' => ['OpenAVT-Core/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
