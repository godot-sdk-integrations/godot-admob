//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef rewarded_h
#define rewarded_h

#import "ad_format_base.h"

#import "load_ad_request.h"


@interface RewardedAd : AdFormatBase <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADRewardedAd *gadAd;

- (instancetype) initWithID:(NSString*) adId;
- (void) load:(LoadAdRequest*) loadAdRequest;
- (void) show;

@end

#endif /* rewarded_h */
