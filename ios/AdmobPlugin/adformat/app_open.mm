//
// © 2024-present https://github.com/cengiz-pz
//

#import "app_open.h"

#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "gap_converter.h"

@implementation AppOpenAd

static NSString *const kLogTag = @"AdmobPlugin::AppOpenAd::";

@synthesize plugin;

- (instancetype)initWithPlugin:(AdmobPlugin *)admobPlugin {
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

- (void)loadWithRequest:(LoadAdRequest *)loadRequest autoShowOnResume:(BOOL)autoShow {
	if (self.isLoading) {
		os_log_debug(admob_log, "%@ Cannot load app open ad: App open ad is already loading", kLogTag);
	} else if ([self isAvailable]) {
		os_log_debug(admob_log, "%@ Cannot load app open ad: App open ad is not available", kLogTag);
	} else {
		self.isLoading = YES;
		self.adUnitId = [loadRequest adUnitId];
		self.autoShowOnResume = autoShow;
		self.loadTime = 0;
		self.loadedAd = nil;

		GADRequest *gadRequest = [loadRequest createGADRequest];

		os_log_debug(admob_log, "%@ Loading app open ad: %@", kLogTag, self.adUnitId);

		[GADAppOpenAd loadWithAdUnitID:self.adUnitId
							request:gadRequest
					completionHandler:^(GADAppOpenAd *_Nullable ad, NSError *_Nullable error) {
			self.isLoading = NO;

			if (error) {
				os_log_error(admob_log, "%@ Failed to load: %@", kLogTag, error.localizedDescription);
				Dictionary errorDict = [GAPConverter nsLoadErrorToGodotDictionary:error];
				self.plugin->emit_signal(APP_OPEN_AD_FAILED_TO_LOAD_SIGNAL,
										[GAPConverter nsStringToGodotString:self.adUnitId],
										errorDict);
			} else {
				self.loadedAd = ad;
				self.loadedAd.fullScreenContentDelegate = self;
				self.loadTime = [[NSDate date] timeIntervalSince1970];

				os_log_debug(admob_log, "%@ Loaded %@ successfully", kLogTag, self.adUnitId);
				self.plugin->emit_signal(APP_OPEN_AD_LOADED_SIGNAL,
										[GAPConverter nsStringToGodotString:self.adUnitId],
										[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
			}
		}];
	}
}

- (void)show {
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

- (BOOL)isAvailable {
	if (!self.loadedAd) return NO;
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	return (now - self.loadTime) < (4 * 3600); // 4-hour expiration
}

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Impression recorded", kLogTag);
	self.isShowing = YES;

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_IMPRESSION_SIGNAL,
								 [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Clicked", kLogTag);

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_CLICKED_SIGNAL,
								 [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Did present full screen", kLogTag);
	// adDidPresentFullScreenContent is not called by the SDK (SDK bug?)
	// will use adWillPresentFullScreenContent, which is called by SDK
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Will present full screen", kLogTag);

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL,
								 [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
	os_log_error(admob_log, "%@ Failed to present: %@", kLogTag, error.localizedDescription);
	self.isShowing = NO;
	self.loadedAd = nil;
	self.loadTime = 0;

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL,
								 [GAPConverter nsStringToGodotString:self.adUnitId],
								 [GAPConverter nsAdErrorToGodotDictionary:error]);
	}
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
	os_log_debug(admob_log, "%@ Dismissed", kLogTag);
	self.isShowing = NO;
	self.loadedAd = nil;
	self.loadTime = 0;

	if (self.plugin) {
		self.plugin->emit_signal(APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL,
								 [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

@end
