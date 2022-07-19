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
