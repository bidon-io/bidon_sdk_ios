//
//  BNMAInterstitialAdTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 19.07.2022.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <BidOn/BidOn.h>
#import <BidOnDecoratorAppLovinMax/BidOnDecoratorAppLovinMax.h>
#import <AppLovinSDK/AppLovinSDK.h>

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
