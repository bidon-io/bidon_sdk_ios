# Rewarded Ads

This page is describes how to implement rewarded ads though the Bidon SDK.

## Loading an Rewarded Ad

To load an interstitial ad, instantiate an `BDNRewardedAd` with `placement` configured in the app settings. Implement `BDNRewardedAdDelegate` that you are notified when your ad is ready and of other ad-related events. In the load method you will need to specify the pricefloor. This argument can be ad revenue value from mediaton.

```swift
class ViewController: UIViewController {
    var rewardedAd: Bidon.RewardedAd!
    
    func loadRewardedAd() {
        rewardedAd = Bidon.RewardedAd(placement: "PLACEMENT")
        rewardedAd.delegate = self
        
        rewardedAd.loadAd(with: 0.1)
    }
}


extension ViewController: Bidon.RewardedAdDelegate {
    func adObject(_ adObject: Bidon.AdObject, didLoadAd ad: Bidon.Ad) {}
    
    func adObject(_ adObject: Bidon.AdObject, didFailToLoadAd error: Error) {}
    
    func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, willPresentAd ad: Bidon.Ad) {}
    
    func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, didFailToPresentAd error: Error) {}
    
    func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, didDismissAd ad: Bidon.Ad) {}
    
    func rewardedAd(_ rewardedAd: Bidon.RewardedAdObject, didRewardUser reward: Bidon.Reward) {}
}
```

```obj-c
#import "ViewController.h"
#import <Bidon/Bidon-Swift.h>


@interface ViewController() <BDNRewardedAdDelegate>

@property (nonatomic, strong) BDNRewardedAd *rewardedAd;

@end


@implementation ViewController

- (void)loadRewardedAd {
    self.rewardedAd = [[BDNRewardedAd alloc] initWithPlacement:@"PLACEMENT"];
    self.rewardedAd.delegate = self;

    [self.rewardedAd loadAdWith:0.1];
}

#pragma mark - BDNRewardedAdDelegate

- (void)adObject:(id<BDNAdObject>)adObject didFailToLoadAd:(NSError *)error {}

- (void)adObject:(id<BDNAdObject>)adObject didLoadAd:(id<BDNAd>)ad {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd didDismissAd:(id<BDNAd>)ad {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd didFailToPresentAd:(NSError *)error {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd willPresentAd:(id<BDNAd>)ad {}

- (void)rewardedAd:(id<BDNRewardedAd>)rewardedAd didRewardUser:(id<BDNReward>)reward {}

@end
```

## Showing an Rewarded Ad

```swift
func showRewardedAd() {
    guard rewardedAd.isReady else { return }
    rewardedAd.show(from: self)
}
```

```obj-c
- (void)showRewardedAd {
    if ([self.rewardedAd isReady]) {
        [self.rewardedAd showAdFrom:self];
    }
}
```

## Handle a User Reward

Once a Rewarded Ad did reward user, delegate method `rewardedAd:didRewardUser` will fire. You will be able to receive reward amount and currency.

```swift
func rewardedAd(_ rewardedAd: Bidon.RewardedAdObject, didRewardUser reward: Bidon.Reward) {
    let amount: Int = reward.amount
    let currency: String = reward.label
} 
```

```obj-c
- (void)rewardedAd:(id<BDNRewardedAd>)rewardedAd didRewardUser:(id<BNReward>)reward {
    NSInteger amount = [reward amount];
    NSString *currenct = [reward label];
}
```
