//
//  BDNInterstitialTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 08.02.2023.
//

#import <XCTest/XCTest.h>
#import <BidOn/BidOn.h>


@interface BDNInterstitialTestCase : XCTestCase <BDNFullscreenAdDelegate>

@property (nonatomic, strong) BDNInterstitial *interstitial;

@end


@implementation BDNInterstitialTestCase

- (void)setUp {
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testLoadInterstitial {
    self.interstitial = [[BDNInterstitial alloc] initWithPlacement:@"PLACEMENT"];
    self.interstitial.delegate = self;
    
    [self.interstitial loadAdWith:0.1];
}

- (void)testShowInterstitial {
    if ([self.interstitial isReady]) {
        [self.interstitial showFrom:UIViewController.new];
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)adObject:(id<BDNAdObject>)adObject didFailToLoadAd:(NSError *)error {}

- (void)adObject:(id<BDNAdObject>)adObject didLoadAd:(id<BNAd>)ad {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd didDismissAd:(id<BNAd>)ad {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd didFailToPresentAd:(NSError *)error {}

- (void)fullscreenAd:(id<BDNFullscreenAd>)fullscreenAd willPresentAd:(id<BNAd>)ad {}

@end
