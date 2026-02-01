//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef interstitial_h
#define interstitial_h

#import "ad_format_base.h"
#import "load_ad_request.h"

@interface InterstitialAd : AdFormatBase <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic) BOOL isLoaded;

- (instancetype) initWithID:(NSString*) adId;
- (void) load:(LoadAdRequest*) loadAdRequest;
- (void) show;

@end

#endif /* interstitial_h */
