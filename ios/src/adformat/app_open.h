//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef app_open_h
#define app_open_h

#import "ad_format_base.h"
#import "load_ad_request.h"


@interface AppOpenAd : AdFormatBase <GADFullScreenContentDelegate>

@property (nonatomic, assign) class AdmobPlugin* plugin;
@property (nonatomic, strong) NSString* adUnitId;
@property (nonatomic) BOOL autoShowOnResume;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isShowing;
@property (nonatomic) NSTimeInterval loadTime;
@property (nonatomic, strong) GADAppOpenAd* loadedAd;

- (instancetype)initWithPlugin:(class AdmobPlugin*)plugin;
- (Error) loadWithRequest:(LoadAdRequest*) loadRequest autoShowOnResume:(BOOL) autoShow;
- (void) show;
- (BOOL) isAvailable;

@end

#endif /* app_open_h */
