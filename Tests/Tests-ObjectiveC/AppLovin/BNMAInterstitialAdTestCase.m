//
//  BNMAInterstitialAdTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 19.07.2022.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <MobileAdvertising/MobileAdvertising.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <AppLovinDecorator/AppLovinDecorator.h>

#import "BNMAMockAuctionDelegate.h"


@interface BNMAInterstitialAdTestCase : XCTestCase

@property (nonatomic, copy) NSString *adUnitIdentifier;

@property (nonatomic, strong) BNMAInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALSdk *sdkMock;
@property (nonatomic, strong) BNMAMockAuctionDelegate *auctionDelegate;

@end


@implementation BNMAInterstitialAdTestCase

- (void)setUp {
    self.adUnitIdentifier = NSUUID.UUID.UUIDString;
    self.sdkMock = OCMClassMock(ALSdk.class);
    self.auctionDelegate = [BNMAMockAuctionDelegate new];
    self.interstitialAd = [[BNMAInterstitialAd alloc] initWithAdUnitIdentifier:self.adUnitIdentifier
                                                                           sdk:self.sdkMock];
    self.interstitialAd.auctionDelegate = self.auctionDelegate;
}

- (void)tearDown {
   
}

- (void)testExample {
    
}

@end




@interface ExampleViewController: NSObject <BNMAAdDelegate>
@property (nonatomic, strong) BNMAInterstitialAd *interstitialAd;
@property (nonatomic, assign) NSInteger retryAttempt;
@end

@implementation ExampleViewController

- (void)createInterstitialAd
{
    self.interstitialAd = [[BNMAInterstitialAd alloc] initWithAdUnitIdentifier: @"YOUR_AD_UNIT_ID"];
    self.interstitialAd.delegate = self;

    // Load the first ad
    [self.interstitialAd loadAd];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoad:(id<Ad>)ad
{
    // Interstitial ad is ready to be shown. '[self.interstitialAd isReady]' will now return 'YES'

    // Reset retry attempt
    self.retryAttempt = 0;
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(NSError *)error
{
    // Interstitial ad failed to load
    // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
    
    self.retryAttempt++;
    NSInteger delaySec = pow(2, MIN(6, self.retryAttempt));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.interstitialAd loadAd];
    });
}

- (void)didDisplayAd:(id<Ad>)ad {}

- (void)didClickAd:(id<Ad>)ad {}

- (void)didHideAd:(id<Ad>)ad
{
    // Interstitial ad is hidden. Pre-load the next ad
    [self.interstitialAd loadAd];
}

- (void)didFailToDisplayAd:(id<Ad>)ad withError:(NSError *)error
{
    // Interstitial ad failed to display. We recommend loading the next ad
    [self.interstitialAd loadAd];
}

@end
