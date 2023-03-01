# Banners

This page is describes how to implement banner ads though the Bidon SDK.

## Loading an Banners

To load banner, create a `BDNBanner`.  Implement `BDNAdViewDelegate` that you are notified when your ad is ready and of other ad-related events. This argument can be ad revenue value from mediaton.

> Set `rootViewController` property before attemp to call loadAd method!

```swift
class ViewController: UIViewController {
    var banner: Bidon.Banner!
    
    func loadBanner() {
        banner = Bidon.Banner(frame: .zero)
        banner.rootViewController = self
        banner.format = .banner
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.heightAnchor.constraint(equalToConstant: 50),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            banner.leftAnchor.constraint(equalTo: view.leftAnchor),
            banner.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        banner.loadAd(with: 0.1)
    }
}


extension ViewController: Bidon.AdViewDelegate {
    func adView(_ adView: UIView & Bidon.AdView, willPresentScreen ad: Bidon.Ad) {}
    
    func adView(_ adView: UIView & Bidon.AdView, didDismissScreen ad: Bidon.Ad) {}
    
    func adView(_ adView: UIView & Bidon.AdView, willLeaveApplication ad: Bidon.Ad) {}
    
    func adObject(_ adObject: Bidon.AdObject, didLoadAd ad: Bidon.Ad) {}
    
    func adObject(_ adObject: Bidon.AdObject, didFailToLoadAd error: Error) {}
}
```

```obj-c
#import "ViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <Bidon/Bidon.h>


@interface ViewController() <BDNAdViewDelegate>

@property (nonatomic, strong) BDNBannerView *banner;

@end


@implementation ViewController

- (void)createBanner {
    self.banner = [[BDNBannerView alloc] initWithFrame:CGRectZero
                                             placement:BDNSdk.defaultPlacement];
    self.banner.format = BDNBannerFormatBanner;
    self.banner.delegate = self;
    self.banner.translatesAutoresizingMaskIntoConstraints = NO;

    [self.banner loadAdWith:0.1];
    
    [self.view addSubview: self.banner];
    [NSLayoutConstraint activateConstraints:@[
        [self.banner.heightAnchor constraintEqualToConstant:50],
        [self.banner.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.banner.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.banner.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];
    
    [self.banner loadAdWith:0.1];
}

#pragma mark - BDNAdViewDelegate Protocol

- (void)adObject:(id<BDNAdObject>)adObject didFailToLoadAd:(NSError *)error {}

- (void)adObject:(id<BDNAdObject>)adObject didLoadAd:(id<BDNAd>)ad {}

- (void)adView:(UIView<BDNAdView> *)adView didDismissScreen:(id<BDNAd>)ad {}

- (void)adView:(UIView<BDNAdView> *)adView willLeaveApplication:(id<BDNAd>)ad {}

- (void)adView:(UIView<BDNAdView> *)adView willPresentScreen:(id<BDNAd>)ad {}

@end
```

## Ad View Format

| Ad View Format | Size | Description  |
|---|---|---|
| banner  | 320 x 50   | Fixed size banner for phones |
| leaderboard | 728 x 90  | Fixed size banner for pads  |
| mrec | 300 x 250 | Fixed medium rectangle banners  |
| adaptive | -/- x 50/90 | Flexible width banners |