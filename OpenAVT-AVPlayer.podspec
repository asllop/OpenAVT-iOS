# OpenAVT-AVPlayer podspec

Pod::Spec.new do |s|
  s.name             = 'OpenAVT-AVPlayer'
  s.version          = '0.5.0'
  s.summary          = 'Open Audio-Video Telemetry, AVPlayer tracker.'
  s.description      = <<-DESC
  Open Audio-Video Telemetry, AVPlayer tracker. It contains a tracker for the AVPlayer.
                       DESC
  s.swift_versions   = '5.0'
  s.homepage         = 'https://github.com/asllop/OpenAVT-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'asllop' => 'andreu.santaren@gmail.com' }
  s.source           = { :git => 'https://github.com/asllop/OpenAVT-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/OpenAVT-AVPlayer/Classes/**/*'

  s.dependency 'OpenAVT-Core'
end
