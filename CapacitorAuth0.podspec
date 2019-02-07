
  Pod::Spec.new do |s|
    s.name = 'CapacitorAuth0'
    s.version = '0.0.1'
    s.summary = 'Auth0 plugin for capacitor'
    s.license = 'MIT'
    s.homepage = 'https://github.com/areo/capacitor-auth0'
    s.author = 'Areo AS'
    s.source = { :git => 'https://github.com/areo/capacitor-auth0.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '10.0'
    s.dependency 'Capacitor'
    s.dependency 'Auth0'
  end
