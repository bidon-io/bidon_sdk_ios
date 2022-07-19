//
//  BNMAMockAuctionDelegate.m
//  Tests-ObjectiveC
//
//  Created by Stas Kochkin on 19.07.2022.
//

#import "BNMAMockAuctionDelegate.h"


@interface BNMAMockAuctionDelegate ()

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *mutableEvents;

@end


@implementation BNMAMockAuctionDelegate

- (NSArray<NSDictionary *> *)events {
    return [self.mutableEvents copy];
}

- (NSMutableArray<NSDictionary *> *)mutableEvents {
    if (!_mutableEvents) {
        _mutableEvents = [NSMutableArray arrayWithCapacity:5];
    }
    return _mutableEvents;
}

- (void)didStartAuction {
    [self.mutableEvents addObject:@{
        @"event": [NSString stringWithUTF8String:__func__],
        @"args": @[]
    }];
}

- (void)didCompleteAuction:(id<Ad>)winner {
    [self.mutableEvents addObject:@{
        @"event": [NSString stringWithUTF8String:__func__],
        @"args": winner ? @[winner] : @[]
    }];
}

- (void)didCompleteAuctionRound:(NSString *)round {
    [self.mutableEvents addObject:@{
        @"event": [NSString stringWithUTF8String:__func__],
        @"args": @[round]
    }];
}

- (void)didReceiveAd:(id<Ad>)ad {
    [self.mutableEvents addObject:@{
        @"event": [NSString stringWithUTF8String:__func__],
        @"args": @[ad]
    }];
}

- (void)didStartAuctionRound:(NSString *)round pricefloor:(double)pricefloor {
    [self.mutableEvents addObject:@{
        @"event": [NSString stringWithUTF8String:__func__],
        @"args": @[round, @(pricefloor)]
    }];
}

@end
