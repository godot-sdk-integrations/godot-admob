//
// © 2024-present https://github.com/cengiz-pz
//

#import "interstitial.h"

#import "os_apple_embedded.h"
#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "admob_ad_error.h"
#import "admob_load_ad_error.h"


@implementation InterstitialAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
		self.isLoaded = NO;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	GADRequest* gadRequest = [loadAdRequest createGADRequest];

	dispatch_async(dispatch_get_main_queue(), ^{
		[GADInterstitialAd loadWithAdUnitID:[loadAdRequest adUnitId] request:gadRequest completionHandler:^(GADInterstitialAd* ad, NSError* error) {
			if (error) {
				AdmobLoadAdError *loadAdError = [[AdmobLoadAdError alloc] initWithNsError:error];
				os_log_error(admob_log, "failed to load InterstitialAd with error: %@", loadAdError.message);
				AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
							[loadAdError buildRawData]);
			}
			else {
				self.interstitial = ad;
				self.interstitial.fullScreenContentDelegate = self;

				if (self.isLoaded) {
					os_log_debug(admob_log, "InterstitialAd %@ refreshed", self.adId);
					AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_REFRESHED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
							[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
				}
				else {
					self.isLoaded = YES;
					os_log_debug(admob_log, "InterstitialAd %@ loaded successfully", self.adId);
					AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
							[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
				}
			}
		}];
    });
}

- (void) show {
	if (self.interstitial) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.interstitial presentFromRootViewController:[GDTAppDelegateService viewController]];
		});
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
	AdmobAdError *adError = [[AdmobAdError alloc] initWithNsError:error];
	os_log_debug(admob_log, "InterstitialAd didFailToPresentFullScreenContentWithError: %@", adError.message);
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[adError buildRawData]);
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
