//
// © 2024-present https://github.com/cengiz-pz
//

#import "interstitial.h"

#import "os_apple_embedded.h"
#import "admob_plugin_implementation.h"
#import "admob_logger.h"


@implementation InterstitialAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
		self.isLoaded = NO;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	GADRequest* gadRequest = [GADRequest request];
	gadRequest.requestAgent = loadAdRequest.requestAgent;
	gadRequest.keywords = loadAdRequest.keywords;

	[GADInterstitialAd loadWithAdUnitID:loadAdRequest.adUnitId request:gadRequest completionHandler:^(GADInterstitialAd* ad, NSError* error) {
		if (error) {
			os_log_error(admob_log, "failed to load InterstitialAd with error: %@", [error localizedDescription]);
			AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
						[GAPConverter nsLoadErrorToGodotDictionary:error]);
		}
		else {
			self.interstitial = ad;
			self.interstitial.fullScreenContentDelegate = self;

			if (self.isLoaded) {
				os_log_debug(admob_log, "InterstitialAd %@ refreshed", self.adId);
				AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_REFRESHED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
			}
			else {
				self.isLoaded = YES;
				os_log_debug(admob_log, "InterstitialAd %@ loaded successfully", self.adId);
				AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
			}
		}
	}];
}

- (void) show {
	if (self.interstitial) {
		[self.interstitial presentFromRootViewController:[GDTAppDelegateService viewController]];
	}
	else {
		os_log_debug(admob_log, "InterstitialAd show: ad not set");
	}
}

- (void) adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "InterstitialAd adDidRecordImpression");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "InterstitialAd adDidRecordClick");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *) error {
	os_log_debug(admob_log, "InterstitialAd didFailToPresentFullScreenContentWithError");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[GAPConverter nsAdErrorToGodotDictionary:error]);
}

- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "InterstitialAd adWillPresentFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	
	if (AdFormatBase.pauseOnBackground) {
		os_log_debug(admob_log, "InterstitialAd pauseOnBackground is true");
		OS_AppleEmbedded::get_singleton()->on_focus_out();
	}
	else {
		os_log_debug(admob_log, "InterstitialAd pauseOnBackground is false");
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "InterstitialAd adDidDismissFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	OS_AppleEmbedded::get_singleton()->on_focus_in();
}

@end
