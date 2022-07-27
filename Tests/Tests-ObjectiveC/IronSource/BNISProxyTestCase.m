//
//  BNISProxy.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 25.07.2022.
//

#import <XCTest/XCTest.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <BidOn/BidOn.h>
#import <IronSource/IronSource.h>
#import <BidOnDecoratorIronSource/BidOnDecoratorIronSource.h>
#import "AdaptersFactory.h"


@interface BNISProxyTestCase : XCTestCase

@end


@implementation BNISProxyTestCase

+ (void)setUp {
    NSError *error;
    
    id<Adapter> mockAdapter = [AdaptersFactory mockAdapterWithIdentifier:@"adapter id"];
    [IronSource.bn registerWithAdapter:mockAdapter error:&error];
    XCTAssertNil(error, @"Error while register mock adapter");
    
    id<Adapter> bidmachineAdapter = (id<Adapter>)[AdaptersFactory bidmachineAdapterWithError:&error];
    XCTAssertNil(error, @"Error while creating bidmachine adapter");

    [IronSource.bn registerWithAdapter:bidmachineAdapter error:&error];
    XCTAssertNil(error, @"Error while register bidmachine adapter");
    
    id<Adapter> googleMobileAdsAdapter = (id<Adapter>)[AdaptersFactory googleMobileAdsAdapterWithError:&error];
    XCTAssertNil(error, @"Error while creating google mobile ads adapter");
    
    [IronSource.bn registerWithAdapter:googleMobileAdsAdapter error:&error];
    XCTAssertNil(error, @"Error while register google mobile ads adapter");
    
    id<Adapter> appsFlyerAdapter = (id<Adapter>)[AdaptersFactory appsFlyerAdapterWithError:&error];
    XCTAssertNil(error, @"Error while creating appsflyer adapter");
    
    [IronSource.bn registerWithAdapter:appsFlyerAdapter error:&error];
    XCTAssertNil(error, @"Error while register appsflyer adapter");
}

- (void)assertHasAdapterWithIdentifier:(NSString *)identifier {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id<Adapter> adapter, NSDictionary<NSString *,id> *bindings) {
        return [adapter.identifier isEqualToString:identifier];
    }];
    
    XCTAssertEqual(IronSource.bn.adapters.count, 4);
    XCTAssertEqual([IronSource.bn.adapters filteredArrayUsingPredicate:filter].count, 1);
}

- (void)testRegisteringDemand {
    [self assertHasAdapterWithIdentifier:@"adapter id"];
}

- (void)testRegisterBidMachine {
    [self assertHasAdapterWithIdentifier:@"bidmachine"];
}

- (void)testRegisterGoogleMobileAds {
    [self assertHasAdapterWithIdentifier:@"admob"];
}

- (void)testRegisterAppsFlyer {
    [self assertHasAdapterWithIdentifier:@"appsflyer"];
}

- (void)testShouldInitialize {
    // TODO: Implement test on initialization
}

@end
