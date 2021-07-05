# OpenAVT-Core podspec

Pod::Spec.new do |s|
  s.name             = 'OpenAVT-Core'
  s.version          = '0.5.0'
  s.summary          = 'Open Audio-Video Telemetry, core library.'
  s.description      = <<-DESC
  Open Audio-Video Telemetry, core library. It contains the base classes to build player specific trackers and vendor specific backends.
                       DESC
  s.swift_versions   = '5.0'
  s.homepage         = 'https://github.com/asllop/OpenAVT-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'asllop' => 'andreu.santaren@gmail.com' }
  s.source           = { :git => 'https://github.com/asllop/OpenAVT-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/OpenAVT-Core/Classes/**/*'
end
