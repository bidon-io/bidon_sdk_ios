# IronSource + Bidon

### Table of contents

  - [Installation](#installation)
    - [CocoaPods](#cocoapods-recommended)
    - [Manual](#manual)
  - [Set The Delegates](#set-the-delegates)
  - [Demand Sources](#demand-sources)
  - [MMP](#mmp)
  - [Init the SDK](#init-the-sdk)
  - [Rewarded Video](#rewarded-video)
  - [Interstitial](#interstitial)
  - [Banner/MREC](#bannermrec)
  
>  A project should already has integrated [IronSource SDK](https://developers.is.com/ironsource-mobile/ios/ios-sdk/).

## Installation

### CocoaPods (Recommended)

To integrate the IronSource Decorator through CocoaPods, first add the following lines to your Podfile:

``` ruby
pod 'IronSourceSDK'
pod 'Bidon/IronSourceDecorator'

# For usage of Demand Sources uncomment following lines
# pod 'Bidon/BidMachineAdapter'
# pod 'Bidon/GoogleMobileAdsAdapter'

# For usage of MMP uncomment following lines
# pod 'Bidon/AppsFlyerAdapter'

```

Then run the following on the command line:

``` ruby
pod install --repo-update
```

### Manual

> TODO:// Manual integration guiode

## Set The Delegates

Import the necessary files

_Swift_

```swift
import IronSourceDecorator
import MobileAdvertising 
import 
``` 

_Objective C_

```objc
#import "IronSource/IronSource.h"
#import <IronSourceDecorator/IronSourceDecorator.h>
#import <MobileAdvertising/MobileAdvertising.h>
```

*Set Delegates*

The IronSource Decorator fires several events to inform you of your ad unit activity. To receive these events, register to the delegates of the ad units you set up on the ironSource platform.

__Rewarded Video__

_Swift_

```swift
IronSource.bid.setRewardedVideoDelegate(yourRewardedVideoDelegate)
``` 

_Objective C_

```objc
[[IronSource bid] setRewardedVideoDelegate:yourRewardedVideoDelegate];
```

__Interstital__

_Swift_

```swift
IronSource.bid.setInterstitialDelegate(yourInterstitialDelegate)
``` 

_Objective C_

```objc
[[IronSource bid] setInterstitialDelegate:yourInterstitialDelegate];
```

## Demand Sources

For using of BidMachine and GoogleMobileAds SDK in postbid you will need to register their's adapters before initialization of the SDK

_Swift_ example

```swift
import IronSourceDecorator
import GoogleMobileAdsAdapter
import BidMachineAdapter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        ⋮
        
        IronSource.bid.register(
            adapter: BidMachineDemandSourceAdapter.self,
            parameters: BidMachineParameters(
                sellerId: "BidMachine seller id"
            )
        )
        
        IronSource.bid.bid.register(
            adapter: GoogleMobileAdsDemandSourceAdapter.self,
            parameters: GoogleMobileAdsParameters(
                interstitial: [
                    LineItem(0.1, adUnitId: "AdMob interstitial ad unit id"),
                ],
                rewardedAd: [
                    LineItem(0.1, adUnitId: "AdMob rewarded ad unit id"),
                ],
                banner: [
                    LineItem(0.1, adUnitId: "AdMob banner ad unit id"),
                ]
            )
        )

        ⋮
```

_Objective C_ example

```objc
#import <IronSourceDecorator/IronSourceDecorator.h>
#import <GoogleMobileAdsAdapter/GoogleMobileAdsAdapter.h>
#import <BidMachineAdapter/BidMachineAdapter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ⋮

    // BidMachine
    NSDictionary *bidMachineParameters = @{
        @"seller_id": @"BidMachine seller id"
    };
    NSData *bidMachineParametersRaw = [NSJSONSerialization dataWithJSONObject:bidMachineParameters options:0 error:&error];
    BidMachineDemandSourceAdapter *bidMachineAdapter = [[BidMachineDemandSourceAdapter alloc] initWithRawParameters:bidMachineParametersRaw error:&error];
    
    [[IronSource bid] registerWithAdapter:(id<Adapter>)bidMachineAdapter error:&error];

    // GoogleMobileAds
    NSDictionary *adMobParameters = @{
        @"line_items": @{
            @"interstitial": @[
                @{
                    @"pricefloor": @0.01,
                    @"ad_unit_id": @"AdMob interstitial ad unit id"
                }
            ],
            @"rewarded_ad": @[
                @{
                    @"pricefloor": @0.01,
                    @"ad_unit_id": @"AdMob rewarded ad unit id"
                }
            ],
            @"banner": @[
                @{
                    @"pricefloor": @0.01,
                    @"ad_unit_id": @"AdMob banner ad unit id"
                }
            ]
        }
    };
    
    NSData *adMobParametersRaw = [NSJSONSerialization dataWithJSONObject:adMobParameters options:0 error:&error];
    GoogleMobileAdsDemandSourceAdapter *adMobAdapter = [[GoogleMobileAdsDemandSourceAdapter alloc] initWithRawParameters:adMobParametersRaw error:&error];
    
    [[IronSource bid] registerWithAdapter:(id<Adapter>)adMobAdapter error:&error];

    ⋮
```

## MMP

For using of AppsFlyer as ad revenue tracking partner you will need to register its adapter before initialization of the SDK

_Swift_ example

```swift
import IronSourceDecorator
import AppsFlyerAdapter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        ⋮
        
         IronSource.bid.register(
            adapter: AppsFlyerMobileMeasurementPartnerAdapter.self,
            parameters: AppsFlyerParameters(
                devKey: "some key",
                appId: "some app id"
            )
        )

        ⋮
```

_Objective C_ example

```objc
#import <IronSourceDecorator/IronSourceDecorator.h>
#import <AppsFlyerAdapter/AppsFlyerAdapter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ⋮

    NSDictionary *appsFlyerParameters = @{
        @"dev_key": @"dev key",
        @"app_id": @"app id"
    };
    
    NSData *appsFlyerParametersRaw = [NSJSONSerialization dataWithJSONObject:appsFlyerParameters options:0 error:&error];
    AppsFlyerMobileMeasurementPartnerAdapter *appsFlyerAdapter = [[AppsFlyerMobileMeasurementPartnerAdapter alloc] initWithRawParameters:appsFlyerParametersRaw error:&error];
        
    [[IronSource bid] registerWithAdapter:(id<Adapter>)appsFlyerAdapter error:&error];

    ⋮
```

## Init the SDK

You can initialize the SDK in two ways.

1. We recommend this approach as it will fetch the specific ad units you define in the adUnits parameter. Ad unit is a string array.

_Swift_

```swift
IronSource.initWithAppKey(kAPPKEY, adUnits:YOUR_AD_UNITS)
```

_Objective C_

```objc
[[IronSource bid] initWithAppKey:YOUR_APP_KEY adUnits:YOUR_AD_UNITS];
```

Sample:

_Swift_

```swift
 IronSource.bid.initWithAppKey(kAPPKEY, adUnits:[IS_REWARDED_VIDEO];
/** or for all ad units
IronSource.bid.initWithAppKey(kAPPKEY, adUnits:[IS_REWARDED_VIDEO,IS_INTERSTITIAL,IS_OFFERWALL, IS_BANNER];
```

_Objective C_

```objc
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_REWARDED_VIDEO] delegate: nil];
/** or for all ad units
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_REWARDED_VIDEO,IS_INTERSTITIAL,IS_OFFERWALL, IS_BANNER] delegate: nil];
```

When using this init approach, you can now initialize each ad unit separately at different touchpoints in your app flow in one session.

_Swift_

```swift
// To init Rewarded Video
IronSource.bid.initWithAppKey(kAPPKEY, adUnits:[IS_REWARDED_VIDEO];
// To init Interstitial
IronSource.bid.initWithAppKey(kAPPKEY, adUnits:[IS_INTERSTITIAL];
// To init Offerwall
IronSource.bid.initWithAppKey(kAPPKEY, adUnits:[IS_OFFERWALL];
// To init Banner
IronSource.bid.initWithAppKey(kAPPKEY, adUnits:[IS_BANNER];
```

_Objective C_

```objc
// To init Rewarded Video
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_REWARDED_VIDEO] delegate: nil];
//To init Interstitial
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_INTERSTITIAL] delegate: nil];
// To init Offerwall
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_OFFERWALL] delegate: nil];
// To init Banner
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_BANNER] delegate: nil];
```

2. Alternatively, you can init the SDK as detailed below and the SDK will init the ad units you’ve  configured on the ironSource platform:

_Swift_

```swift
IronSource.initWithAppKey(kAPPKEY)
```

_Objective C_

```objc
[IronSource initWithAppKey:YOUR_APP_KEY adUnits:@[IS_BANNER, IS_INTERSTITIAL, IS_BANNER] delegate: nil];
```

*Init Complete Callback*

The ironSource SDK fires callback to inform you that the ironSource SDK was initialized successfully, for ironSource SDK 7.2.1+ . This listener will provide you an indication that the initialization process was completed, and you can start loading ads. The callback will be sent once per session, and will indicate the first initialization of the SDK.

_Swift_

```swift
IronSource.bid.initWithAppKey(kAPPKEY, delegate: self)
//MARK: ISInitializationDelegate Functions
/**
   called after init mediation completed     
*/
public func initializationDidComplete() {
         
}
```

_Objective C_

```objc
[[IronSource bid] initWithAppKey:APP_KEY adUnits:@[IS_BANNER, IS_INTERSTITIAL, IS_BANNER] delegate:self];
#pragma mark -ISInitializationDelegate
// Invoked after init mediation completed
- (void)initializationDidComplete {
}
```

## Rewarded Video

*Show a Video Ad to Your Users*

You are still able to get notified by rewarded video availability by callback `-rewardedVideoHasChangedAvailability:`. Alternatively, you can also request ad availability directly by calling:

_Swift_

```swift
IronSource.bid.hasRewardedVideo()
```

_Objective C_

```objc
[[IronSource bid] hasRewardedVideo];
```

Once an ad network has an available video, you will be ready to show the video to your users. Before you display the ad, make sure to pause any game action, including audio, to ensure the best experience for your users.

_Swift_

```swift
IronSource.bid.showRewardedVideo(with: <UIViewController>, placement: <String?>)
```

_Objective C_

```objc
[[IronSource bid] showRewardedVideoWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName];
```

*Manually load rewarded video ads*

Request a rewarded video ad d before you plan on showing it to your users as the loading process can take time. Use the following API to load your ad: 

_Swift_

```swift
IronSource.bid.loadRewardedVideo()
```

_Objective C_

```objc
[[IronSource bid] loadRewardedVideo];
```

> All other integration steps remain the same.

## Interstitial 

*Check Ad Availability*

You are still able to get notified by interstitial availability by callback `-interstitialDidLoad:`. Alternatively, you can also request ad availability directly by calling:

_Swift_

```swift
IronSource.bid.hasInterstitial()
```

_Objective C_

```objc
[[IronSource bid] hasInterstitial];
```

Once you receive the interstitialDidLoad callback, you are ready to show an Interstitial Ad to your users. To provide the best experience for your users, make sure to pause any game action, including audio, during the time the ad is displayed.

Invoke the following method to serve an Interstitial ad to your users:

_Swift_

```swift
IronSource.bid.showInterstitialWithViewController(with: <UIViewController>, placement: <String?>)
```

_Objective C_

```objc
[[IronSource bid] showInterstitialWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName];
```

> All other integration steps remain the same.

## Banner/MREC

*Implement the Delegate*

`ISBannerDelegate` is moved to `BNISBannerDelegate`. Only `-bannerDidLoad:` returened argument type is changed from `ISBannerView` to `UIView`. 

*Load Banner Ad* 

To load a banner ad, call the following method:

* Initiate the Banner view by calling this method (in this example it’s the BANNER banner size):

_Swift_

```swift
IronSource.bid.loadBanner(with: <UIViewController>, size: ISBannerSize_BANNER)
```

_Objective C_

```objc
[[IronSource bid] loadBannerWithViewController:self size:ISBannerSize_BANNER];
```

* Another option is initiating the banner with Custom size, using this signature (WxH in points):

_Swift_

```swift
IronSource.bid.loadBanner(with: <UIViewController>,**** size: ISBannerSize(width: 320, andHeight: 50))
```

_Objective C_

```objc
[[IronSource bid] loadBannerWithViewController:self size:[[ISBannerSize alloc] initWithWidth:320 andHeight:50]];
```

*Additional Load Settings*

We support placements, pacing and capping for Banners on the ironSource dashboard. Learn how to set up placements, capping and pacing for Banners to optimize your app’s user experience here.

If you’ve set up placements for your Banner, call the following method to serve a Banner ad in a specific placement:

_Swift_

```swift
IronSource.bid.loadBanner(with: YOUR_VIEW_CONTROLLER, size: YOUR_BANNER_SIZE, placement: YOUR_PLACEMENT_NAME)
```

_Objective C_

```objc
[[IronSource bid] loadBannerWithViewController:self size:ISBannerSize_BANNER placement:placement];
```

*Destroy the Banner Ad*

To destroy a banner, call the following method:

_Swift_

```swift
IronSource.bid.destroyBanner(YOUR_IRONSOURCE_BANNER)
```

_Objective C_

```objc
[[IronSource bid] destroyBanner: bannerView];
```

A destroyed banner can no longer be loaded. If you want to serve it again, you must initiate it again.

> All other integration steps remain the same.
