platform :ios, '10.0'
workspace 'MobileAdvertising.xcworkspace'

source 'https://github.com/appodeal/CocoaPods.git'
source 'https://cdn.cocoapods.org/'

install! 'cocoapods', :warn_for_multiple_pod_sources => false
use_frameworks!


# Defenitions

def applovin
  pod 'AppLovinSDK'
end

def ironsource 
  pod 'IronSourceSDK', '7.2.3.1-APD'
end 

def fyber
  pod 'FairBidSDK'
end

def bidmachine 
  pod 'BidMachine'
  pod 'BDMIABAdapter'
end

def admob
  pod 'Google-Mobile-Ads-SDK'
end

def ocmock
  pod 'OCMock', '~> 3.9.1'
end

# Targets 

target 'AppLovinDecorator' do
  project 'Decorators/Decorators.xcodeproj'
  applovin
end

target 'IronSourceDecorator' do
  project 'Decorators/Decorators.xcodeproj'
  ironsource
end

target 'FyberDecorator' do
  project 'Decorators/Decorators.xcodeproj'
  fyber
end

target 'BidMachineAdapter' do
  project 'Adapters/Adapters.xcodeproj'
  bidmachine
end

target 'GoogleMobileAdsAdapter' do
  project 'Adapters/Adapters.xcodeproj'
  admob
end


# Tests

target 'Tests-ObjectiveC' do
  project 'Tests/Tests.xcodeproj'
  ocmock
  applovin
  fyber
  ironsource
  bidmachine
  admob
end


# Demo 

target 'AppLovinMAX-Demo' do
  project 'Sandbox/Sandbox.xcodeproj'
  applovin
  bidmachine
  admob
end

target 'IronSource-Demo' do
  project 'Sandbox/Sandbox.xcodeproj'
  ironsource
  bidmachine
  admob
end

target 'Fyber-Demo' do
  project 'Sandbox/Sandbox.xcodeproj'
  fyber
  bidmachine
  admob
end


