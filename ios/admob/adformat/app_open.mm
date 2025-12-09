//
// © 2024-present https://github.com/cengiz-pz
//

#import "app_open.h"

#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "admob_ad_error.h"
#import "admob_ad_info.h"
#import "admob_load_ad_error.h"
#import "gap_converter.h"


@interface AppOpenAd ()

@property (nonatomic, strong) AdmobAdInfo *adInfo;

@end


@implementation AppOpenAd

static NSString *const kLogTag = @"AdmobPlugin::AppOpenAd::";

@synthesize plugin;

- (instancetype) initWithPlugin:(AdmobPlugin *)admobPlugin {
	self = [super init];
	if (self) {
		self.plugin = admobPlugin;
		self.isLoading = NO;
		self.isShowing = NO;
		self.autoShowOnResume = NO;
		self.loadTime = 0;
		self.loadedAd = nil;
		self.adUnitId = nil;
	}
	return self;
}

- (void) loadWithRequest:(LoadAdRequest *)loadAdRequest autoShowOnResume:(BOOL)autoShow {
	if (self.isLoading) {
		os_log_debug(admob_log, "%@ Cannot load app open ad: App open ad is already loading", kLogTag);
	} else if ([self isAvailable]) {
		os_log_debug(admob_log, "%@ Cannot load app open ad: App open ad is not available", kLogTag);
	} else {
		self.isLoading = YES;
		self.adUnitId = [loadAdRequest adUnitId];
		self.autoShowOnResume = autoShow;
		self.loadTime = 0;
		self.loadedAd = nil;

		GADRequest *gadRequest = [loadAdRequest createGADRequest];

		os_log_debug(admob_log, "%@ Loading app open ad: %@", kLogTag, self.adUnitId);

		[GADAppOpenAd loadWithAdUnitID:self.adUnitId request:gadRequest
					completionHandler:^(GADAppOpenAd *_Nullable ad, NSError *_Nullable error) {
			self.isLoading = NO;

			_adInfo = [[AdmobAdInfo alloc] initWithId:self.adUnitId request:loadAdRequest];
			if (error) {
				AdmobLoadAdError *loadAdError = [[AdmobLoadAdError alloc] initWithNsError:error];
				os_log_error(admob_log, "%@ Failed to load: %@", kLogTag, loadAdError.message);

				self.plugin->emit_signal(APP_OPEN_AD_FAILED_TO_LOAD_SIGNAL,
										[self.adInfo buildRawData],
										[loadAdError buildRawData]);
			} else {
				self.loadedAd = ad;
				self.loadedAd.fullScreenContentDelegate = self;
				self.loadTime = [[NSDate date] timeIntervalSince1970];

				os_log_debug(admob_log, "%@ Loaded %@ successfully", kLogTag, self.adUnitId);
				self.plugin->emit_signal(APP_OPEN_AD_LOADED_SIGNAL,
										[self.adInfo buildRawData],
										[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
			}
		}];
	}
}

- (void) show {
	if (self.isShowing) {
		os_log_debug(admob_log, "%@ Cannot show app open ad: App open ad is already showing", kLogTag);
	} else if (![self isAvailable]) {
		os_log_debug(admob_log, "%@ Cannot show app open ad: App open ad is not ready yet", kLogTag);
	} else {
		UIViewController *rootVC = [GDTAppDelegateService viewController];
		if (!rootVC) {
			os_log_error(admob_log, "%@ Cannot show: no root view controller", kLogTag);
		} else {
			self.isShowing = YES;

			dispatch_async(dispatch_get_main_queue(), ^{
				[self.loadedAd presentFromRootViewController:rootVC];
			});
		}
	}
}

- (BOOL) isAvailable {
	if (!self.loadedAd) return NO;
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	return (now - self.loadTime) < (4 * 3600); // 4-hour expiration
}

- (void) adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Impression recorded", kLogTag);
	self.isShowing = YES;

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_IMPRESSION_SIGNAL, [self.adInfo buildRawData]);
	}
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Clicked", kLogTag);

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_CLICKED_SIGNAL, [self.adInfo buildRawData]);
	}
}

/**
* Starting with Google Mobile Ads SDK 11.0, the delegate method:
* (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
* was officially marked as NS_UNAVAILABLE because the SDK no longer reliably calls it (it was flaky across
* different ad networks in the mediation waterfall). Google now expects developers to treat
* adWillPresentFullScreenContent: as the definitive "ad is now showing" signal.
*/
- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Will present full screen", kLogTag);

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData]);
	}
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
	AdmobAdError *adError = [[AdmobAdError alloc] initWithNsError:error];
	os_log_error(admob_log, "%@ Failed to present: %@", kLogTag, adError.message);

	self.isShowing = NO;
	self.loadedAd = nil;
	self.loadTime = 0;

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL,
								[self.adInfo buildRawData],
								[adError buildRawData]);
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Dismissed", kLogTag);
	self.isShowing = NO;
	self.loadedAd = nil;
	self.loadTime = 0;

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData]);
	}
}

@end
