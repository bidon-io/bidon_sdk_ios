//
//  AdaptersFactory.h
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 25.07.2022.
//

#import <Foundation/Foundation.h>
#import <BidOn/BidOn.h>
#import <BidOnAdapterGoogleMobileAds/BidOnAdapterGoogleMobileAds.h>
#import <BidOnAdapterBidMachine/BidOnAdapterBidMachine.h>
#import <BidOnAdapterAppsFlyer/BidOnAdapterAppsFlyer.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdaptersFactory : NSObject

+ (id<Adapter>)mockAdapterWithIdentifier:(NSString *)identifier;
+ (GoogleMobileAdsDemandSourceAdapter *)googleMobileAdsAdapterWithError:(NSError **)error;
+ (BidMachineDemandSourceAdapter *)bidmachineAdapterWithError:(NSError **)error;
+ (AppsFlyerMobileMeasurementPartnerAdapter *)appsFlyerAdapterWithError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
