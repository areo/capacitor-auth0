require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'CapacitorAuth0'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = 'https://github.com/areo/capacitor-auth0'
  s.author = package['author']
  s.source = { :git => 'https://github.com/areo/capacitor-auth0.git', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target  = '11.0'
  s.dependency 'Capacitor'
  s.dependency 'Auth0'
end
