# Advanced

This page is describes advanced features of the Bidon SDK.

## Manualy register adapters

You're able to define which adapters will be used by Bidon SDK in the application runtime by yourself. You'll need to use the following code to register adapters instead of `registerDefaultAdapters:` before initialize the Bidon SDK.

```swift
import Bidon
import BidonAdapterAppLovin
import BidonAdapterGoogleMobileAds 
⋮

BidonSdk.registerAdapter(adapter: BidonAdapterAppLovin.AppLovinDemandSourceAdapter())
BidonSdk.registerAdapter(adapter: BidonAdapterGoogleMobileAds.GoogleMobileAdsDemandSourceAdapter())
```

```obj-c
[BDNSdk registerAdapterWithClassName:@"BidonAdapterAppLovin.AppLovinDemandSourceAdapter"];
[BDNSdk registerAdapterWithClassName:@"BidonAdapterGoogleMobileAds.GoogleMobileAdsDemandSourceAdapter"];
```

## Impression-Level Ad Revenue

You're able to send impression-level ad revenue data for any MMP or analytics platform. 

```swift
func adObject(
    _ adObject: AdObject,
    didPay revenue: AdRevenue,
    ad: Ad
) {
    let value = revenue.revenue
    let currency = revenue.currency
    let networkName = ad.networkName
    let adUnitId = ad.adUnitId
}
```

```objc
- (void)adObject:(id<BDNAdObject>)adObject didPay:(id<BDNAdRevenue>)revenue ad:(id<BDNAd>)ad {
    double value = [revenue revenue];
    NSString *currency = [revenue currency];
    NSString *networkName = [ad networkName];
    NSString *adUnitId = [ad adUnitId];
}
```