#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_screenguard.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_screenguard'
  s.version          = '0.0.1'
  s.summary          = 'A Native screenshot blocking library for Flutter developer, with background customizable after captured. Screenshot detector are also supported.'
  s.description      = <<-DESC
  A Native screenshot blocking library for Flutter developer, with background customizable after captured. Screenshot detector are also supported.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'gbumps' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'SDWebImage', '~> 5.19.4'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
