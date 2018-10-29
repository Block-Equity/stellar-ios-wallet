# Uncomment the next line to define a global platform for your project
platform :ios, '11.2'

def shared_pods
  pod 'stellar-ios-mac-sdk', '~> 1.4.7'
  pod 'KeychainSwift', '~> 10.0'
  pod 'Alamofire', '~> 4.7'
end

target 'BlockEQ' do
  use_frameworks!

  workspace 'BlockEQ.xcworkspace'
  project 'BlockEQ.xcodeproj'

  shared_pods
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift', :branch => 'master'
  pod 'Whisper', :git => 'https://github.com/freeubi/Whisper.git', :branch => 'swift-4.2-support'
  pod 'Kingfisher', '~> 4.10'

  target 'BlockEQTests' do
    inherit! :search_paths
  end

  target 'BlockEQUITests' do
    inherit! :search_paths
  end

end

target 'StellarAccountService' do
  use_frameworks!
  workspace 'BlockEQ.xcworkspace'
  project 'StellarAccountService.xcodeproj'

  shared_pods

  target 'StellarAccountServiceTests' do
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    if config.name == 'Release'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
    else
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    end
  end
end
