//
//  BNMAMockAuctionDelegate.h
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 19.07.2022.
//

#import <Foundation/Foundation.h>
#import <MobileAdvertising/MobileAdvertising.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <AppLovinDecorator/AppLovinDecorator.h>

NS_ASSUME_NONNULL_BEGIN


@interface BNMAMockAuctionDelegate : NSObject <BNMAuctionDelegate>

@property (nonatomic, readonly) NSArray <NSDictionary *> *events;

@end

NS_ASSUME_NONNULL_END
