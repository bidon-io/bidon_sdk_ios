//
//  BDNBannerTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 08.02.2023.
//

#import <XCTest/XCTest.h>
#import <BidOn/BidOn.h>


@interface BDNBannerTestCase : XCTestCase <BDNAdViewDelegate>

@property (nonatomic, strong) BDNBanner *banner;

@end


@implementation BDNBannerTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)createBanner {
    self.banner = [[BDNBanner alloc] initWithFrame: CGRectZero];
    self.banner.format = BDNAdViewFormatBanner;
    self.banner.delegate = self;
    self.banner.translatesAutoresizingMaskIntoConstraints = NO;

    
    [self.banner loadAdWith:0.1];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)adObject:(id<BDNAdObject>)adObject didFailToLoadAd:(NSError *)error {}

- (void)adObject:(id<BDNAdObject>)adObject didLoadAd:(id<BNAd>)ad {}

- (void)adView:(UIView<BDNAdView> *)adView didDismissScreen:(id<BNAd>)ad {}

- (void)adView:(UIView<BDNAdView> *)adView willLeaveApplication:(id<BNAd>)ad {}

- (void)adView:(UIView<BDNAdView> *)adView willPresentScreen:(id<BNAd>)ad {}

@end
