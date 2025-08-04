//
// © 2024-present https://github.com/cengiz-pz
//

#import "rewarded_interstitial.h"

#import "os_ios.h"
#import "admob_plugin_implementation.h"
#import "admob_logger.h"

@implementation RewardedInterstitialAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	GADRequest* gadRequest = [GADRequest request];
	gadRequest.requestAgent = loadAdRequest.requestAgent;
	gadRequest.keywords = loadAdRequest.keywords;

	[GADRewardedInterstitialAd loadWithAdUnitID:loadAdRequest.adUnitId request:gadRequest completionHandler:^(GADRewardedInterstitialAd* ad, NSError* error) {
		if (error) {
			os_log_error(admob_log, "Failed to load RewardedInterstitialAd with error: %@", [error localizedDescription]);
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
						[GAPConverter nsLoadErrorToGodotDictionary:error]);
		}
		else {
			self.gadAd = ad;
			self.gadAd.fullScreenContentDelegate = self;

			if (loadAdRequest.userId || loadAdRequest.customData) {
				GADServerSideVerificationOptions *gadOptions = [[GADServerSideVerificationOptions alloc] init];

				if (loadAdRequest.customData && [loadAdRequest.userId length] != 0) {
					gadOptions.customRewardString = loadAdRequest.customData;
				}

				if (loadAdRequest.userId && [loadAdRequest.userId length] != 0) {
					gadOptions.userIdentifier = loadAdRequest.userId;
				}

				self.gadAd.serverSideVerificationOptions = gadOptions;
			}
		
			os_log_debug(admob_log, "RewardedInterstitialAd %@ loaded successfully", self.adId);
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
		}
	}];
}

- (void) show {
	if (self.gadAd) {
		 [self.gadAd presentFromRootViewController:[GDTAppDelegateService viewController] userDidEarnRewardHandler:^{
			 GADAdReward* reward = self.gadAd.adReward;
			 AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
						[GAPConverter adRewardToGodotDictionary:reward]);
		 }];
	}
	else {
		os_log_debug(admob_log, "RewardedInterstitialAd show: ad not set");
	}
}

- (void) adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd adDidRecordImpression.");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString: self.adId]);
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd adDidRecordClick.");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString: self.adId]);
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>) ad didFailToPresentFullScreenContentWithError:(nonnull NSError *) error {
	os_log_debug(admob_log, "RewardedInterstitialAd did fail to present full screen content.");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[GAPConverter nsAdErrorToGodotDictionary:error]);
}

- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd will present full screen content.");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);

	if (AdFormatBase.pauseOnBackground) {
		os_log_debug(admob_log, "RewardedInterstitialAd pauseOnBackground");
		OS_IOS::get_singleton()->on_focus_out();
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd did dismiss full screen content.");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	OS_IOS::get_singleton()->on_focus_in();
}

@end
