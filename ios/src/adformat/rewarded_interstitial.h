//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef rewarded_interstitial_h
#define rewarded_interstitial_h

#import "ad_format_base.h"

#import "load_ad_request.h"

@interface RewardedInterstitialAd : AdFormatBase <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADRewardedInterstitialAd *gadAd;

- (instancetype) initWithID:(NSString*) adId;
- (void) load:(LoadAdRequest*) loadAdRequest;
- (void) show;

@end

#endif /* rewarded_interstitial_h */
