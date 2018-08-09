# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'BlockEQ' do
  # Pods for BlockEQ
  use_frameworks!

  pod 'stellar-ios-mac-sdk', :git => 'https://github.com/Soneso/stellar-ios-mac-sdk', :branch => 'master'
  pod 'KeychainSwift', '~> 10.0'
  pod 'Alamofire', '~> 4.7'
  pod 'SCLAlertView'
  pod 'Whisper'

  target 'BlockEQTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BlockEQUITests' do
    inherit! :search_paths
    # Pods for testing
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
