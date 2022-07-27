//
//  AppLovinDecoratorTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 19.07.2022.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <BidOn/BidOn.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <BidOnDecoratorAppLovinMax/BidOnDecoratorAppLovinMax.h>
#import "AdaptersFactory.h"


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
    
    id<Adapter> adapter = [AdaptersFactory mockAdapterWithIdentifier:adapterID];
    [self.sdk.bid registerWithAdapter:adapter error:&error];
    
    XCTAssertNil(error, @"Error while register adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testRegisterBidMachine {
    NSError *error;
    id<Adapter> adapter = (id<Adapter>)[AdaptersFactory bidmachineAdapterWithError:&error];
    XCTAssertNil(error, @"Error while creating bidmachine adapter");

    [self.sdk.bid registerWithAdapter:(id<Adapter>)adapter error:&error];
    
    XCTAssertNil(error, @"Error while register bidmachine adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testRegisterGoogleMobileAds {
    NSError *error;
    id<Adapter> adapter = (id<Adapter>)[AdaptersFactory googleMobileAdsAdapterWithError:&error];
    XCTAssertNil(error, @"Error while creating google mobile ads adapter");
    
    [self.sdk.bid registerWithAdapter:(id<Adapter>)adapter error:&error];
    
    XCTAssertNil(error, @"Error while register google mobile ads adapter");
    XCTAssertEqual(self.sdk.bid.adapters.count, 1);
}

- (void)testRegisterAppsFlyer {
    NSError *error;
    
    id<Adapter> adapter = (id<Adapter>)[AdaptersFactory appsFlyerAdapterWithError:&error];
    XCTAssertNil(error, @"Error while creating appsflyer adapter");
    
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
