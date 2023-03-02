platform :ios, '11.0'
workspace 'Bidon.xcworkspace'

source 'https://github.com/appodeal/CocoaPods.git'
source 'https://cdn.cocoapods.org/'

install! 'cocoapods', :warn_for_multiple_pod_sources => false
use_frameworks!

# Defenitions

def applovin
  pod 'AppLovinSDK'
end

def bidmachine 
  pod 'BidMachine', '~> 2.0.0.0'
  pod 'BidMachineAdColonyAdapter'
  pod 'BidMachineAmazonAdapter'
  pod 'BidMachineCriteoAdapter'
  pod 'BidMachineMetaAudienceAdapter'
  pod 'BidMachineMyTargetAdapter'
  pod 'BidMachineSmaatoAdapter'
  pod 'BidMachineTapjoyAdapter'
  pod 'BidMachineVungleAdapter'
  pod 'BidMachinePangleAdapter'
  pod 'BidMachineNotsyAdapter'
end

def admob
  pod 'Google-Mobile-Ads-SDK'
end

def appsflyer
  pod 'AppsFlyerFramework', '~> 6.9.0'
  pod 'AppsFlyer-AdRevenue', '~> 6.9.0'
end

def dtexchange
  pod 'Fyber_Marketplace_SDK'
end

def unity_ads
  pod 'UnityAds'
end

def ocmock
  pod 'OCMock', '~> 3.9.1'
end

def appodeal_mediation
  pod 'Appodeal', '~> 3.0.2'
  pod 'APDAdColonyAdapter'
  pod 'APDAdjustAdapter'
  pod 'APDAppLovinAdapter'
  pod 'APDAppsFlyerAdapter'
  pod 'APDBidMachineAdapter'
  pod 'APDGoogleAdMobAdapter'
  pod 'APDIABAdapter'
  pod 'APDIronSourceAdapter'
  pod 'APDMetaAudienceNetworkAdapter'
  pod 'APDMyTargetAdapter'
  pod 'APDStackAnalyticsAdapter'
  pod 'APDUnityAdapter'
  pod 'APDVungleAdapter'
  pod 'APDYandexAdapter'
end

# Targets

target 'BidonAdapterBidMachine' do
  project 'Adapters/Adapters.xcodeproj'
  bidmachine
end

target 'BidonAdapterGoogleMobileAds' do
  project 'Adapters/Adapters.xcodeproj'
  admob
end

target 'BidonAdapterAppLovin' do
  project 'Adapters/Adapters.xcodeproj'
  applovin
end

target 'BidonAdapterDTExchange' do
  project 'Adapters/Adapters.xcodeproj'
  dtexchange
end

target 'BidonAdapterUnityAds' do
  project 'Adapters/Adapters.xcodeproj'
  unity_ads
end

# Tests

target 'Tests-ObjectiveC' do
  project 'Tests/Tests.xcodeproj'
  ocmock
  applovin
  bidmachine
  admob
  applovin
  dtexchange
  unity_ads
end


# Demo

target 'Sandbox' do
  project 'Sandbox/Sandbox.xcodeproj'
  applovin
  appsflyer
  bidmachine
  admob
  applovin
  dtexchange
  unity_ads
  appodeal_mediation
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end

    installer.pods_project.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['IOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end

