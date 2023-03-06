# Interstitials

This page is describes how to implement interstitial ads though the Bidon SDK.

## Loading an Interstitial Ad

To load an interstitial ad, instantiate an `BDNInterstitial` with `placement` configured in the app settings. Implement `BDNFullscreenAdDelegate` that you are notified when your ad is ready and of other ad-related events. In the load method you will need to specify the pricefloor. This argument can be ad revenue value from mediaton.

```swift
class ViewController: UIViewController {
    var interstitialAd: Bidon.Interstitial!
    
    func loadInterstitialAd() {
        interstitialAd = Bidon.Interstitial(placement: "PLACEMENT")
        interstitialAd.delegate = self
        
        interstitialAd.loadAd(with: 0.1)
    }
}


extension ViewController: Bidon.FullscreenAdDelegate {
    func adObject(_ adObject: Bidon.AdObject, didLoadAd ad: Bidon.Ad) {}
    
    func adObject(_ adObject: Bidon.AdObject, didFailToLoadAd error: Error) {}
    
    func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, willPresentAd ad: Bidon.Ad) {}
    
    func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, didFailToPresentAd error: Error) {}
    
    func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, didDismissAd ad: Bidon.Ad) {}
}
```

```obj-c
#import "ViewController.h"
#import <Bidon/Bidon-Swift.h>


@interface ViewController() <BDNFullscreenAdDelegate>

@property (nonatomic, strong) BDNInterstitial *interstitial;

@end


@implementation ViewController

- (void)loadInterstitialAd {
    self.interstitial = [[BDNInterstitial alloc] initWithPlacement:@"PLACEMENT"];
    self.interstitial.delegate = self;

    [self.interstitial loadAdWith:0.1];
}

#pragma mark - BDNFullscreenAdDelegate

- (void)adObject:(id<BDNAdObject>)adObject didFailToLoadAd:(NSError *)error {}

- (void)adObject:(id<BDNAdObject>)adObject didLoadAd:(id<BDNAd>)ad {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd didDismissAd:(id<BDNAd>)ad {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd didFailToPresentAd:(NSError *)error {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd willPresentAd:(id<BDNAd>)ad {}

@end
```

## Showing an Interstitial Ad

```swift
func showInterstitialAd() {
    guard interstitialAd.isReady else { return }
    interstitialAd.showAd(from: self)
}
```

```obj-c
- (void)showInterstitialAd {
    if ([self.interstitial isReady]) {
        [self.interstitial showAdFrom:self];
    }
}
```