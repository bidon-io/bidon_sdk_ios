platform :ios, '12.0'
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
  pod 'BidMachine', '~> 2.0.1.0'
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
  pod 'BidMachineMintegralAdapter'
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
  pod 'Appodeal', '3.1.1-Beta'
  pod 'APDAdColonyAdapter', '3.1.1.1-Beta'
  pod 'APDAdjustAdapter', '3.1.1.1-Beta'
  pod 'APDAppLovinAdapter', '3.1.1.1-Beta'
  pod 'APDAppsFlyerAdapter', '3.1.1.1-Beta'
  pod 'APDBidMachineAdapter', '3.1.1.1-Beta' # Required
  pod 'APDFirebaseAdapter', '3.1.1.1-Beta'
  pod 'APDGoogleAdMobAdapter', '3.1.1.1-Beta'
  pod 'APDIABAdapter', '3.1.1.1-Beta' # Required
  pod 'APDIronSourceAdapter', '3.1.1.1-Beta'
  pod 'APDFacebookAdapter', '3.1.1.1-Beta'
  pod 'APDMetaAudienceNetworkAdapter', '3.1.1.1-Beta'
  pod 'APDMyTargetAdapter', '3.1.1.1-Beta'
  pod 'APDStackAnalyticsAdapter', '3.1.1.1-Beta' # Required
  pod 'APDUnityAdapter', '3.1.1.1-Beta'
  pod 'APDVungleAdapter', '3.1.1.1-Beta'
  pod 'APDYandexAdapter', '3.1.1.1-Beta'
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

