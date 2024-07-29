#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint superuser_plugin_unix.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'superuser_plugin_unix'
  s.version          = '2.0.0'
  s.summary          = 'Detect, verify user who execute Flutter program has superuser role in UNIX'
  s.description      = <<-DESC
Detect, verify user who execute Flutter program has superuser role in UNIX
                       DESC
  s.homepage         = 'https://osp.rk0cc.xyz'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'enquiry@rk0cc.xyz' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
