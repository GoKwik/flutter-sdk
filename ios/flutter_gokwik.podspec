#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_gokwik.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_gokwik'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin to integrate GoKwik Flutter SDK.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.preserve_paths = 'GokwikUpi.xcframework'
  s.vendored_frameworks = 'GokwikUpi.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm7' , 'ENABLE_BITCODE' => 'NO' }
  s.swift_version = '5.0'
end
