//
//  AdaptersFactory.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 25.07.2022.
//

#import "AdaptersFactory.h"
#import <OCMock/OCMock.h>

@implementation AdaptersFactory

+ (id<Adapter>)mockAdapterWithIdentifier:(NSString *)identifier {
    id<Adapter> adapter = OCMProtocolMock(@protocol(Adapter));
    OCMStub([adapter identifier]).andReturn(identifier);
    return adapter;
}

+ (GoogleMobileAdsDemandSourceAdapter *)googleMobileAdsAdapterWithError:(NSError **)error {
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
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
    GoogleMobileAdsDemandSourceAdapter *adapter = [[GoogleMobileAdsDemandSourceAdapter alloc] initWithRawParameters:data error:error];
    return adapter;
}

+ (BidMachineDemandSourceAdapter *)bidmachineAdapterWithError:(NSError **)error {
    NSDictionary *parameters = @{
        @"seller_id": @"BidMachine seller id"
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
    BidMachineDemandSourceAdapter *adapter = [[BidMachineDemandSourceAdapter alloc] initWithRawParameters:data error:error];
    return adapter;
}

+ (AppsFlyerMobileMeasurementPartnerAdapter *)appsFlyerAdapterWithError:(NSError **)error {
    NSDictionary *parameters = @{
        @"dev_key": @"dev key",
        @"app_id": @"app id"
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
    AppsFlyerMobileMeasurementPartnerAdapter *adapter = [[AppsFlyerMobileMeasurementPartnerAdapter alloc] initWithRawParameters:data error:error];
    return adapter;
}

@end
