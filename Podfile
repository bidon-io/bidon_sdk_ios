platform :ios, '10.0'
workspace 'MobileAdvertising.xcworkspace'

source 'https://github.com/appodeal/CocoaPods.git'
source 'https://cdn.cocoapods.org/'

install! 'cocoapods', :warn_for_multiple_pod_sources => false
use_frameworks!

def applovin
  pod 'AppLovinSDK'
end

def bidmachine 
  pod 'BidMachine'
end

def admob
  pod 'Google-Mobile-Ads-SDK'
end

target 'AppLovinDecorator' do
  project 'Decorators/Decorators.xcodeproj'
  applovin
end

target 'BidMachineAdapter' do
  project 'Adapters/Adapters.xcodeproj'
  bidmachine
end

target 'GoogleMobileAdsAdapter' do
  project 'Adapters/Adapters.xcodeproj'
  admob
end

target 'Tests-ObjectiveC' do
  project 'Tests/Tests.xcodeproj'
  applovin
  bidmachine
end

target 'AppLovinMAX-Demo' do
  project 'Sandbox/Sandbox.xcodeproj'
  applovin
  bidmachine
  admob
end


