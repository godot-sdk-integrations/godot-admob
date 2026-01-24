//
// © 2024-present https://github.com/cengiz-pz
//

#import "rewarded_interstitial.h"

#import "os_ios.h"
#import "admob_plugin.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "admob_ad_error.h"
#import "admob_ad_info.h"
#import "admob_load_ad_error.h"


@interface RewardedInterstitialAd ()

@property (nonatomic, strong) AdmobAdInfo *adInfo;

@end


@implementation RewardedInterstitialAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	self.adInfo = [[AdmobAdInfo alloc] initWithId:self.adId request:loadAdRequest];

	GADRequest* gadRequest = [loadAdRequest createGADRequest];

	dispatch_async(dispatch_get_main_queue(), ^{
		[GADRewardedInterstitialAd loadWithAdUnitID:[loadAdRequest adUnitId] request:gadRequest completionHandler:^(GADRewardedInterstitialAd* ad, NSError* error) {
			if (error) {
				AdmobLoadAdError *loadAdError = [[AdmobLoadAdError alloc] initWithNsError:error];
				os_log_error(admob_log, "Failed to load RewardedInterstitialAd with error: %@", loadAdError.message);
				AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL,
							[self.adInfo buildRawData],
							[loadAdError buildRawData]);
			}
			else {
				self.gadAd = ad;
				self.gadAd.fullScreenContentDelegate = self;

				if ([loadAdRequest hasServerSideVerificationOptions]) {
					self.gadAd.serverSideVerificationOptions = [loadAdRequest createGADServerSideVerificationOptions];
				}

				os_log_debug(admob_log, "RewardedInterstitialAd %@ loaded successfully", self.adId);
				AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_LOADED_SIGNAL,
						[self.adInfo buildRawData],
						[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
			}
		}];
	});
}

- (void) show {
	if (self.gadAd) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.gadAd presentFromRootViewController:[GDTAppDelegateService viewController] userDidEarnRewardHandler:^{
				GADAdReward* reward = self.gadAd.adReward;
				AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD_SIGNAL, [self.adInfo buildRawData],
							[GAPConverter adRewardToGodotDictionary:reward]);
			}];
		});
	}
	else {
		os_log_debug(admob_log, "RewardedInterstitialAd show: ad not set");
	}
}

- (void) adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd adDidRecordImpression.");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_IMPRESSION_SIGNAL, [self.adInfo buildRawData]);
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd adDidRecordClick.");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL, [self.adInfo buildRawData]);
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>) ad didFailToPresentFullScreenContentWithError:(nonnull NSError *) error {
	AdmobAdError *adError = [[AdmobAdError alloc] initWithNsError:error];
	os_log_debug(admob_log, "RewardedInterstitialAd did fail to present full screen content: %@", adError);
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData],
				[adError buildRawData]);
}

- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd will present full screen content.");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData]);

	if (AdFormatBase.pauseOnBackground) {
		os_log_debug(admob_log, "RewardedInterstitialAd pauseOnBackground");
		OS_IOS::get_singleton()->on_focus_out();
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedInterstitialAd did dismiss full screen content.");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData]);
	OS_IOS::get_singleton()->on_focus_in();
}

@end
