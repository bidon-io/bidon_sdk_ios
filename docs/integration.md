# Integration

This page is describes how to donwload, import and configure the Bidon SDK. 

- [Integration](#integration)
  - [Download](#download)
    - [CocoaPods (Recommended)](#cocoapods-recommended)
    - [Manual](#manual)
  - [Initialize the SDK](#initialize-the-sdk)
  - [Configure Ad Types](#configure-ad-types)
  
## Download 

### CocoaPods (Recommended)

To integrate the Bidon SDK through CocoaPods, first add the following lines to your Podfile:

``` ruby
pod 'Bidon'

# For usage of Demand Sources uncomment following lines
# pod 'BidonAdapterBidMachine'
# pod 'BidonAdapterGoogleMobileAds'
# pod 'BidonAdapterAppLovin'
# pod 'BidonAdapterDTExchange'

```

Then run the following on the command line:

``` ruby
pod install --repo-update
```

### Manual

> TODO:// Manual integration guiode

## Initialize the SDK

Receive your `app key` in the dashboard app settings. We highly recommend to initialize the Bidon SDK in app delegate's `application:applicationDidFinishLaunching:` method. 

`swift`
```swift
import Bidon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Register all available demand source adapters.
        BidonSdk.registerDefaultAdapters()    
        // Configure Bidon
        BidonSdk.logLevel = .debug
        // Initialize
        BidonSdk.initialize(appKey: "APP KEY") {
            // Load any ads
        }

        ⋮
```

```obj-c
#import <Bidon/Bidon-Swift.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register all available demand source adapters.
    [BDNSdk registerDefaultAdapters];
    // Configure Bidon
    [BDNSdk setLogLevel:BDNLoggerLevelDebug];
    // Initialize
    [BDNSdk initializeWithAppKey:@"APP KEY" completion:^{
        // Load any ads
    }];

    ⋮
```

## Configure Ad Types

- [Interstitials](/docs/ad-formats/interstitials.md)
- [Rewarded Ads](/docs/ad-formats/rewarded.md)
- [Banners](/docs/ad-formats/banners.md)