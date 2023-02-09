//
//  BidOnSdkTestCase.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 08.02.2023.
//

#import <XCTest/XCTest.h>
#import <BidOn/BidOn.h>


@interface BDNSdkTestCase : XCTestCase

@end


@implementation BDNSdkTestCase

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testRegisterDefaultAdapter {
    [BDNSdk registerDefaultAdapters];
}

- (void)testSetLogLevel {
    [BDNSdk setLogLevel:BDNLoggerLevelDebug];
}

- (void)testInitialize {
    [BDNSdk initializeWithAppKey:@"APP KEY" completion:^{
            
    }];
}

- (void)testRegisterAdapters {
    [BDNSdk registerAdapterWithClassName:@"BidOnAdapterAppLovin.AppLovinDemandSourceAdapter"];
    [BDNSdk registerAdapterWithClassName:@"BidOnAdapterGoogleMobileAds.GoogleMobileAdsDemandSourceAdapter"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
