# Uncomment the next line to define a global platform for your project
platform :ios, '11.2'

def shared_pods
  pod 'stellar-ios-mac-sdk', :git => 'https://github.com/Soneso/stellar-ios-mac-sdk.git'
  pod 'KeychainSwift', '~> 10.0'
  pod 'Alamofire', '~> 4.7'
  pod 'Repeat', '~> 0.5'
  pod 'Reusable', '~> 4.0'
  pod 'Cache', '~> 5.2'
end

target 'BlockEQ' do
  use_frameworks!

  workspace 'BlockEQ.xcworkspace'
  project 'BlockEQ.xcodeproj'

  shared_pods
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift', :branch => 'master'
  pod 'Imaginary', :git => 'https://github.com/hyperoslo/Imaginary.git', :branch => 'master'

  target 'BlockEQTests' do
    inherit! :search_paths
  end

  target 'BlockEQSnapshotTests' do
    inherit! :search_paths
    pod 'SnapshotTesting'
  end

end

target 'StellarHub' do
  use_frameworks!
  workspace 'BlockEQ.xcworkspace'
  project 'StellarHub.xcodeproj'

  shared_pods

  target 'StellarHubTests' do
  end
end

