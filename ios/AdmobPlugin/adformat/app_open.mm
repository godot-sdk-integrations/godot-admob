//
// © 2024-present https://github.com/cengiz-pz
//

#import "app_open.h"

#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "gap_converter.h"

@implementation AppOpenAd

@synthesize plugin;

- (instancetype) initWithPlugin:(AdmobPlugin*)admobPlugin {
	self = [super init];
	if (self) {
		self.plugin = admobPlugin;
	}
	return self;
}

- (void) loadWithRequest:(LoadAdRequest*) loadRequest autoShowOnResume:(BOOL) autoShow {
	if (self.isLoading) {
		os_log_debug(admob_log, "Cannot load app open ad: App open ad is already loading");
	} else if ([self isAvailable]) {
		os_log_debug(admob_log, "Cannot load app open ad: App open ad is not available");
	} else {
		self.isLoading = true;
		self.adUnitId = [loadRequest adUnitId];
		self.autoShowOnResume = autoShow;
		GADRequest* gadRequest = [loadRequest createGADRequest];
		[GADAppOpenAd loadWithAdUnitID:self.adUnitId
					request: gadRequest
					completionHandler:^(GADAppOpenAd * _Nullable ad, NSError * _Nullable error) {
			self.isLoading = false;
			if (error) {
				os_log_error(admob_log, "App open ad failed to load: %@", [error localizedDescription]);
				Dictionary errorDict = [GAPConverter nsLoadErrorToGodotDictionary:error];
				self.plugin->emit_signal(APP_OPEN_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId], errorDict);
			} else {
				self.loadedAd = ad;
				self.loadedAd.fullScreenContentDelegate = self;
				self.loadTime = [[NSDate date] timeIntervalSince1970];
				os_log_debug(admob_log, "App open ad loaded: %@", self.adUnitId);
				self.plugin->emit_signal(APP_OPEN_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId],
						[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
			}
		}];
	}
}

- (void) show {
	if (self.isShowing) {
		os_log_debug(admob_log, "Cannot show app open ad: App open ad is already showing");
	} else if (![self isAvailable]) {
		os_log_debug(admob_log, "Cannot show app open ad: App open ad is not ready yet");
	} else {
		UIViewController *rootVC = [GDTAppDelegateService viewController];
		if (!rootVC) {
			os_log_error(admob_log, "Cannot show app open ad: invalid root view controller");
		} else {
			self.isShowing = true;

			dispatch_async(dispatch_get_main_queue(), ^{
				[self.loadedAd presentFromRootViewController:rootVC];
			});
		}
	}
}

- (BOOL) isAvailable {
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	return self.loadedAd != nil && (now - self.loadTime) < (4 * 3600); // 4 hours
}

- (void) adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
	self.isShowing = false;
	self.loadedAd = nil;
	if (self.plugin) {
		os_log_debug(admob_log, "App open ad impression: %@", self.adUnitId);
		self.plugin->emit_signal(APP_OPEN_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

- (void) adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
	self.isShowing = false;
	if (self.plugin) {
		os_log_debug(admob_log, "App open ad clicked: %@", self.adUnitId);
		self.plugin->emit_signal(APP_OPEN_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

- (void) adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
	self.isShowing = false;
	self.loadedAd = nil;
	if (self.plugin) {
		os_log_debug(admob_log, "App open ad showed full screen: %@", self.adUnitId);
		self.plugin->emit_signal(APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

- (void) ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError*)error {
	self.isShowing = false;
	self.loadedAd = nil;
	if (self.plugin) {
		os_log_error(admob_log, "App open ad failed to show: %@", [error localizedDescription]);
		self.plugin->emit_signal(APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId],
				[GAPConverter nsAdErrorToGodotDictionary:error]);
	}
}

- (void) adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
	self.isShowing = false;
	if (self.plugin) {
		os_log_debug(admob_log, "App open ad dismissed: %@", self.adUnitId);
		self.plugin->emit_signal(APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adUnitId]);
	}
}

@end
