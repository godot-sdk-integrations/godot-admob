//
// © 2024-present https://github.com/cengiz-pz
//

#import "rewarded.h"

#import "os_ios.h"
#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"


@implementation RewardedAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	GADRequest* gadRequest = [loadAdRequest createGADRequest];

	[GADRewardedAd loadWithAdUnitID:[loadAdRequest adUnitId] request:gadRequest completionHandler:^(GADRewardedAd* ad, NSError* error) {
		if (error) {
			os_log_error(admob_log, "failed to load RewardedAd with error: %@", [error localizedDescription]);
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
						[GAPConverter nsLoadErrorToGodotDictionary:error]);
		}
		else {
			self.gadAd = ad;
			self.gadAd.fullScreenContentDelegate = self;

			NSString* userId = [loadAdRequest userId];
			NSString* customData = [loadAdRequest customData];
			if ([userId length] > 0 || [customData length] > 0) {
				GADServerSideVerificationOptions *gadOptions = [[GADServerSideVerificationOptions alloc] init];

				if ([customData length] > 0) {
					gadOptions.customRewardString = customData;
				}

				if ([userId length] > 0) {
					gadOptions.userIdentifier = userId;
				}

				self.gadAd.serverSideVerificationOptions = gadOptions;
			}
			
			os_log_debug(admob_log, "RewardedAd %@ loaded successfully", self.adId);
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
					[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
		}
	}];
}

- (void) show {
	if (self.gadAd) {
		 [self.gadAd presentFromRootViewController:[GDTAppDelegateService viewController] userDidEarnRewardHandler:^{
			 GADAdReward *reward = self.gadAd.adReward;
			 AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_USER_EARNED_REWARD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
						[GAPConverter adRewardToGodotDictionary:reward]);
		 }];
	}
	else {
		os_log_debug(admob_log, "RewardedAd show: ad not set");
	}
}

- (void) setServerSideVerificationOptions:(GADServerSideVerificationOptions *) options {
	if (self.gadAd) {
		os_log_debug(admob_log, "RewardedAd setServerSideVerificationOptions");
		self.gadAd.serverSideVerificationOptions = options;
	}
}

- (void) adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adDidRecordImpression");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adDidRecordClick");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>) ad didFailToPresentFullScreenContentWithError:(nonnull NSError *) error {
	os_log_debug(admob_log, "RewardedAd didFailToPresentFullScreenContentWithError");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[GAPConverter nsAdErrorToGodotDictionary:error]);
}

- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adWillPresentFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);

	if (AdFormatBase.pauseOnBackground) {
		os_log_debug(admob_log, "RewardedAd pauseOnBackground");
		OS_IOS::get_singleton()->on_focus_out();
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adDidDismissFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	OS_IOS::get_singleton()->on_focus_in();
}

@end
