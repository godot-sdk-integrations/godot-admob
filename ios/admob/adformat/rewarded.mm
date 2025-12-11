//
// © 2024-present https://github.com/cengiz-pz
//

#import "rewarded.h"

#import "os_ios.h"
#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "admob_ad_error.h"
#import "admob_ad_info.h"
#import "admob_load_ad_error.h"


@interface RewardedAd ()

@property (nonatomic, strong) AdmobAdInfo *adInfo;

@end


@implementation RewardedAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	self.adInfo = [[AdmobAdInfo alloc] initWithId:self.adId request:loadAdRequest];

	GADRequest* gadRequest = [loadAdRequest createGADRequest];

	[GADRewardedAd loadWithAdUnitID:[loadAdRequest adUnitId] request:gadRequest completionHandler:^(GADRewardedAd* ad, NSError* error) {
		if (error) {
			AdmobLoadAdError *loadAdError = [[AdmobLoadAdError alloc] initWithNsError:error];
			os_log_error(admob_log, "failed to load RewardedAd with error: %@", loadAdError.message);
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_FAILED_TO_LOAD_SIGNAL,
					[self.adInfo buildRawData],
					[loadAdError buildRawData]);
		}
		else {
			self.gadAd = ad;
			self.gadAd.fullScreenContentDelegate = self;

			if ([loadAdRequest hasServerSideVerificationOptions]) {
				self.gadAd.serverSideVerificationOptions = [loadAdRequest createGADServerSideVerificationOptions];
			}

			os_log_debug(admob_log, "RewardedAd %@ loaded successfully", self.adId);
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_LOADED_SIGNAL,
					[self.adInfo buildRawData],
					[[[AdmobResponse alloc] initWithResponseInfo:ad.responseInfo] buildRawData]);
		}
	}];
}

- (void) show {
	if (self.gadAd) {
		[self.gadAd presentFromRootViewController:[GDTAppDelegateService viewController] userDidEarnRewardHandler:^{
			GADAdReward *reward = self.gadAd.adReward;
			AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_USER_EARNED_REWARD_SIGNAL, [self.adInfo buildRawData],
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
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_IMPRESSION_SIGNAL, [self.adInfo buildRawData]);
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adDidRecordClick");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_CLICKED_SIGNAL, [self.adInfo buildRawData]);
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>) ad didFailToPresentFullScreenContentWithError:(nonnull NSError *) error {
	AdmobAdError *adError = [[AdmobAdError alloc] initWithNsError:error];
	os_log_debug(admob_log, "RewardedAd didFailToPresentFullScreenContentWithError: %@", adError.message);
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData],
				[adError buildRawData]);
}

- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adWillPresentFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData]);

	if (AdFormatBase.pauseOnBackground) {
		os_log_debug(admob_log, "RewardedAd pauseOnBackground");
		OS_IOS::get_singleton()->on_focus_out();
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	os_log_debug(admob_log, "RewardedAd adDidDismissFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [self.adInfo buildRawData]);
	OS_IOS::get_singleton()->on_focus_in();
}

@end
