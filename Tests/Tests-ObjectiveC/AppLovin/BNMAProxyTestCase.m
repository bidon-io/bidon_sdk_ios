//
//  AppLovinDecoratorTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 19.07.2022.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <MobileAdvertising/MobileAdvertising.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <AppLovinDecorator/AppLovinDecorator.h>
#import <GoogleMobileAdsAdapter/GoogleMobileAdsAdapter.h>
#import <BidMachineAdapter/BidMachineAdapter.h>
#import <AppsFlyerAdapter/AppsFlyerAdapter.h>


@interface BNMAProxyTestCase : XCTestCase

@property (nonatomic, strong) ALSdk *sdk;

@end


@implementation BNMAProxyTestCase

- (void)setUp {
    self.sdk = OCMPartialMock([ALSdk sharedWithKey:NSUUID.UUID.UUIDString]);
}

- (void)testSdkContainsProxy {
    XCTAssertNotNil(self.sdk.bid, @"The proxy is nil");
}

- (void)testRegisteringDemand {
    NSString *adapterID = @"adapter id";
    NSError *error;
    
    id<Adapter> adapter = OCMProtocolMock(@protocol(Adapter));
    OCMStub([adapter identifier]).andReturn(adapterID);
    
    [self.sdk.bid registerWithAdapter:adapter error:&error];
    
    XCTAssertNil(error, @"Error while register adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testRegisterBidMachine {
    NSError *error;
    NSDictionary *parameters = @{
        @"seller_id": @"BidMachine seller id"
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    BidMachineDemandSourceAdapter *adapter = [[BidMachineDemandSourceAdapter alloc] initWithRawParameters:data error:&error];
    
    [self.sdk.bid registerWithAdapter:(id<Adapter>)adapter error:&error];
    
    XCTAssertNil(error, @"Error while register bidmachine adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testRegisterGoogleMobileAds {
    NSError *error;
    NSDictionary *parameters = @{
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
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    GoogleMobileAdsDemandSourceAdapter *adapter = [[GoogleMobileAdsDemandSourceAdapter alloc] initWithRawParameters:data error:&error];
    
    [self.sdk.bid registerWithAdapter:(id<Adapter>)adapter error:&error];
    
    XCTAssertNil(error, @"Error while register google mobile ads adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testRegisterAppsFlyer {
    NSError *error;
    NSDictionary *parameters = @{
        @"dev_key": @"dev key",
        @"app_id": @"app id"
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    AppsFlyerMobileMeasurementPartnerAdapter *adapter = [[AppsFlyerMobileMeasurementPartnerAdapter alloc] initWithRawParameters:data error:&error];
    
    [self.sdk.bid registerWithAdapter:(id<Adapter>)adapter error:&error];
    
    XCTAssertNil(error, @"Error while register apps flyer adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testInitialization {
    __block ALSdkConfiguration *receivedConfiguration;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Initialization completion expectation"];
    ALSdkConfiguration *configurationMock = OCMClassMock(ALSdkConfiguration.class);
    
    OCMStub([self.sdk initializeSdkWithCompletionHandler:OCMArg.any]).andDo(^(NSInvocation *inv) {
        void (^completion)(ALSdkConfiguration *);
        [inv getArgument:&completion atIndex:2];
        completion(configurationMock);
        [expectation fulfill];
    });
    
    [self.sdk.bid initializeSdkWithCompletionHandler:^(ALSdkConfiguration *config) {
        receivedConfiguration = config;
    }];
    
    [self waitForExpectations:@[expectation] timeout:1];
    XCTAssertIdentical(receivedConfiguration, configurationMock);
}

@end
