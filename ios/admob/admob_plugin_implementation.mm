//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_plugin_implementation.h"

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

#import <UserMessagingPlatform/UserMessagingPlatform.h>

#import "admob_plugin-Swift.h"

#import "gap_converter.h"
#import "admob_ad_size.h"
#import "admob_config.h"
#import "admob_status.h"
#import "admob_logger.h"
#import "privacy_settings.h"


const String INITIALIZATION_COMPLETED_SIGNAL = "initialization_completed";
const String BANNER_AD_LOADED_SIGNAL = "banner_ad_loaded";
const String BANNER_AD_FAILED_TO_LOAD_SIGNAL = "banner_ad_failed_to_load";
const String BANNER_AD_REFRESHED_SIGNAL = "banner_ad_refreshed";
const String BANNER_AD_IMPRESSION_SIGNAL = "banner_ad_impression";
const String BANNER_AD_SIZE_MEASURED_SIGNAL = "banner_ad_size_measured";
const String BANNER_AD_CLICKED_SIGNAL = "banner_ad_clicked";
const String BANNER_AD_OPENED_SIGNAL = "banner_ad_opened";
const String BANNER_AD_CLOSED_SIGNAL = "banner_ad_closed";
const String INTERSTITIAL_AD_LOADED_SIGNAL = "interstitial_ad_loaded";
const String INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL = "interstitial_ad_failed_to_load";
const String INTERSTITIAL_AD_REFRESHED_SIGNAL = "interstitial_ad_refreshed";
const String INTERSTITIAL_AD_IMPRESSION_SIGNAL = "interstitial_ad_impression";
const String INTERSTITIAL_AD_CLICKED_SIGNAL = "interstitial_ad_clicked";
const String INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL = "interstitial_ad_showed_full_screen_content";
const String INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL = "interstitial_ad_failed_to_show_full_screen_content";
const String INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL = "interstitial_ad_dismissed_full_screen_content";
const String REWARDED_AD_LOADED_SIGNAL = "rewarded_ad_loaded";
const String REWARDED_AD_FAILED_TO_LOAD_SIGNAL = "rewarded_ad_failed_to_load";
const String REWARDED_AD_IMPRESSION_SIGNAL = "rewarded_ad_impression";
const String REWARDED_AD_CLICKED_SIGNAL = "rewarded_ad_clicked";
const String REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL = "rewarded_ad_showed_full_screen_content";
const String REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL = "rewarded_ad_failed_to_show_full_screen_content";
const String REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL = "rewarded_ad_dismissed_full_screen_content";
const String REWARDED_AD_USER_EARNED_REWARD_SIGNAL = "rewarded_ad_user_earned_reward";
const String REWARDED_INTERSTITIAL_AD_LOADED_SIGNAL = "rewarded_interstitial_ad_loaded";
const String REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL = "rewarded_interstitial_ad_failed_to_load";
const String REWARDED_INTERSTITIAL_AD_IMPRESSION_SIGNAL = "rewarded_interstitial_ad_impression";
const String REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL = "rewarded_interstitial_ad_clicked";
const String REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL = "rewarded_interstitial_ad_showed_full_screen_content";
const String REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL = "rewarded_interstitial_ad_failed_to_show_full_screen_content";
const String REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL = "rewarded_interstitial_ad_dismissed_full_screen_content";
const String REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD_SIGNAL = "rewarded_interstitial_ad_user_earned_reward";
const String APP_OPEN_AD_LOADED_SIGNAL = "app_open_ad_loaded";
const String APP_OPEN_AD_FAILED_TO_LOAD_SIGNAL = "app_open_ad_failed_to_load";
const String APP_OPEN_AD_IMPRESSION_SIGNAL = "app_open_ad_impression";
const String APP_OPEN_AD_CLICKED_SIGNAL = "app_open_ad_clicked";
const String APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL = "app_open_ad_showed_full_screen_content";
const String APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL = "app_open_ad_failed_to_show_full_screen_content";
const String APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL = "app_open_ad_dismissed_full_screen_content";
const String CONSENT_FORM_LOADED_SIGNAL = "consent_form_loaded";
const String CONSENT_FORM_FAILED_TO_LOAD_SIGNAL = "consent_form_failed_to_load";
const String CONSENT_FORM_DISMISSED_SIGNAL = "consent_form_dismissed";
const String CONSENT_INFO_UPDATED_SIGNAL = "consent_info_updated";
const String CONSENT_INFO_UPDATE_FAILED_SIGNAL = "consent_info_update_failed";
const String TRACKING_AUTHORIZATION_GRANTED = "tracking_authorization_granted";
const String TRACKING_AUTHORIZATION_DENIED = "tracking_authorization_denied";

static NSString *const kLogTag = @"AdmobPlugin::";

static const int FULL_WIDTH = -1;

AdmobPlugin* AdmobPlugin::instance = NULL;

void AdmobPlugin::_bind_methods() {
	ClassDB::bind_method(D_METHOD("initialize"), &AdmobPlugin::initialize);
	ClassDB::bind_method(D_METHOD("set_request_configuration"), &AdmobPlugin::set_request_configuration);
	ClassDB::bind_method(D_METHOD("get_initialization_status"), &AdmobPlugin::get_initialization_status);
	ClassDB::bind_method(D_METHOD("set_app_pause_on_background"), &AdmobPlugin::set_app_pause_on_background);

	ADD_SIGNAL(MethodInfo(INITIALIZATION_COMPLETED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "status_data")));

	ClassDB::bind_method(D_METHOD("get_current_adaptive_banner_size"), &AdmobPlugin::get_current_adaptive_banner_size);
	ClassDB::bind_method(D_METHOD("get_portrait_adaptive_banner_size"), &AdmobPlugin::get_portrait_adaptive_banner_size);
	ClassDB::bind_method(D_METHOD("get_landscape_adaptive_banner_size"), &AdmobPlugin::get_landscape_adaptive_banner_size);
	ClassDB::bind_method(D_METHOD("load_banner_ad"), &AdmobPlugin::load_banner_ad);
	ClassDB::bind_method(D_METHOD("show_banner_ad"), &AdmobPlugin::show_banner_ad);
	ClassDB::bind_method(D_METHOD("hide_banner_ad"), &AdmobPlugin::hide_banner_ad);
	ClassDB::bind_method(D_METHOD("remove_banner_ad"), &AdmobPlugin::remove_banner_ad);
	ClassDB::bind_method(D_METHOD("move_banner_ad", "ad_id", "x", "y"), &AdmobPlugin::move_banner_ad);
	ClassDB::bind_method(D_METHOD("get_banner_width"), &AdmobPlugin::get_banner_width);
	ClassDB::bind_method(D_METHOD("get_banner_height"), &AdmobPlugin::get_banner_height);
	ClassDB::bind_method(D_METHOD("get_banner_width_in_pixels"), &AdmobPlugin::get_banner_width_in_pixels);
	ClassDB::bind_method(D_METHOD("get_banner_height_in_pixels"), &AdmobPlugin::get_banner_height_in_pixels);

	ADD_SIGNAL(MethodInfo(BANNER_AD_LOADED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_FAILED_TO_LOAD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "load_error_data")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_REFRESHED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_IMPRESSION_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_SIZE_MEASURED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_CLICKED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_OPENED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(BANNER_AD_CLOSED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));

	ClassDB::bind_method(D_METHOD("load_interstitial_ad"), &AdmobPlugin::load_interstitial_ad);
	ClassDB::bind_method(D_METHOD("show_interstitial_ad"), &AdmobPlugin::show_interstitial_ad);
	ClassDB::bind_method(D_METHOD("remove_interstitial_ad"), &AdmobPlugin::remove_interstitial_ad);

	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_LOADED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "load_error_data")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_REFRESHED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_IMPRESSION_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_CLICKED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "ad_error_data")));
	ADD_SIGNAL(MethodInfo(INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "ad_error_data")));

	ClassDB::bind_method(D_METHOD("load_rewarded_ad"), &AdmobPlugin::load_rewarded_ad);
	ClassDB::bind_method(D_METHOD("show_rewarded_ad"), &AdmobPlugin::show_rewarded_ad);
	ClassDB::bind_method(D_METHOD("remove_rewarded_ad"), &AdmobPlugin::remove_rewarded_ad);

	ADD_SIGNAL(MethodInfo(REWARDED_AD_LOADED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_FAILED_TO_LOAD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "load_error_data")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_IMPRESSION_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_CLICKED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "ad_error_data")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_AD_USER_EARNED_REWARD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "reward_data")));

	ClassDB::bind_method(D_METHOD("load_rewarded_interstitial_ad"), &AdmobPlugin::load_rewarded_interstitial_ad);
	ClassDB::bind_method(D_METHOD("show_rewarded_interstitial_ad"), &AdmobPlugin::show_rewarded_interstitial_ad);
	ClassDB::bind_method(D_METHOD("remove_rewarded_interstitial_ad"), &AdmobPlugin::remove_rewarded_interstitial_ad);

	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_LOADED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "load_error_data")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_IMPRESSION_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "ad_error_data")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "reward_data")));

	ClassDB::bind_method(D_METHOD("load_app_open_ad", "load_ad_request", "auto_show_on_resume"), &AdmobPlugin::load_app_open_ad, DEFVAL(Variant(false)));
	ClassDB::bind_method(D_METHOD("show_app_open_ad"), &AdmobPlugin::show_app_open_ad);
	ClassDB::bind_method(D_METHOD("is_app_open_ad_available"), &AdmobPlugin::is_app_open_ad_available);

	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_LOADED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "response_info")));
	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_FAILED_TO_LOAD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "load_error_data")));
	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_IMPRESSION_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_CLICKED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));
	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info"), PropertyInfo(Variant::DICTIONARY, "error")));
	ADD_SIGNAL(MethodInfo(APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, PropertyInfo(Variant::DICTIONARY, "ad_info")));

	ClassDB::bind_method(D_METHOD("load_consent_form"), &AdmobPlugin::load_consent_form);
	ClassDB::bind_method(D_METHOD("show_consent_form"), &AdmobPlugin::show_consent_form);

	ADD_SIGNAL(MethodInfo(CONSENT_FORM_LOADED_SIGNAL));
	ADD_SIGNAL(MethodInfo(CONSENT_FORM_FAILED_TO_LOAD_SIGNAL, PropertyInfo(Variant::DICTIONARY, "form_error_data")));
	ADD_SIGNAL(MethodInfo(CONSENT_FORM_DISMISSED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "form_error_data")));

	ClassDB::bind_method(D_METHOD("get_consent_status"), &AdmobPlugin::get_consent_status);
	ClassDB::bind_method(D_METHOD("is_consent_form_available"), &AdmobPlugin::is_consent_form_available);
	ClassDB::bind_method(D_METHOD("update_consent_info"), &AdmobPlugin::update_consent_info);
	ClassDB::bind_method(D_METHOD("reset_consent_info"), &AdmobPlugin::reset_consent_info);

	ClassDB::bind_method(D_METHOD("set_mediation_privacy_settings", "settings"), &AdmobPlugin::set_mediation_privacy_settings);

	ADD_SIGNAL(MethodInfo(CONSENT_INFO_UPDATED_SIGNAL));
	ADD_SIGNAL(MethodInfo(CONSENT_INFO_UPDATE_FAILED_SIGNAL, PropertyInfo(Variant::DICTIONARY, "form_error_data")));

	ClassDB::bind_method(D_METHOD("request_tracking_authorization"), &AdmobPlugin::request_tracking_authorization);

	ADD_SIGNAL(MethodInfo(TRACKING_AUTHORIZATION_GRANTED));
	ADD_SIGNAL(MethodInfo(TRACKING_AUTHORIZATION_DENIED));

	ClassDB::bind_method(D_METHOD("open_app_settings"), &AdmobPlugin::open_app_settings);
}

Error AdmobPlugin::initialize() {
	os_log_debug(admob_log, "%@ initialize", kLogTag);

	if (initialized) {
		os_log_error(admob_log, "%@ already initialized", kLogTag);
		return FAILED;
	}

	bannerAds = [NSMutableDictionary dictionaryWithCapacity:10];
	bannerAdSequence = 0;
	interstitialAds = [NSMutableDictionary dictionaryWithCapacity:10];
	interstitialAdSequence = 0;
	rewardedInterstitialAds = [NSMutableDictionary dictionaryWithCapacity:10];
	rewardedInterstitialAdSequence = 0;
	rewardedAds = [NSMutableDictionary dictionaryWithCapacity:10];
	rewardedAdSequence = 0;

	os_log_debug(admob_log, "%@ Starting GADMobileAds initialization", kLogTag);

	[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
		initialized = true;
		os_log_debug(admob_log, "%@ initialization completed for %tu adapters.", kLogTag, [status.adapterStatusesByClassName count]);
		Dictionary dictionary = [[[AdmobStatus alloc] initWithStatus:status] buildRawData];
		emit_signal(INITIALIZATION_COMPLETED_SIGNAL, dictionary);
	}];

	return OK;
}

Error AdmobPlugin::set_request_configuration(Dictionary configData) {
	os_log_debug(admob_log, "%@ set_request_configuration", kLogTag);

	if (initialized == false) {
		os_log_error(admob_log, "%@ has not been initialized", kLogTag);
		return FAILED;
	}

	AdmobConfig* admobConfig = [[AdmobConfig alloc] initWithDictionary: configData];

	[admobConfig applyToGADRequestConfiguration:GADMobileAds.sharedInstance.requestConfiguration];

	return OK;
}

Dictionary AdmobPlugin::get_initialization_status() {
	GADInitializationStatus *status = [GADMobileAds sharedInstance].initializationStatus;
	return [[[AdmobStatus alloc] initWithStatus:status] buildRawData];
}

void AdmobPlugin::set_app_pause_on_background(bool pause) {
	[AdFormatBase setPauseOnBackground:pause];
}

Dictionary AdmobPlugin::get_current_adaptive_banner_size(int width) {
	os_log_debug(admob_log, "AdmobPlugin get_current_adaptive_banner_size");
	int currentWidth = (width == FULL_WIDTH) ? getAdWidth() : width;

	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentWidth)];
	Dictionary dictionary = [adSize buildRawData];

	return dictionary;
}

Dictionary AdmobPlugin::get_portrait_adaptive_banner_size(int width) {
	os_log_debug(admob_log, "AdmobPlugin get_portrait_adaptive_banner_size");
	int currentWidth = (width == FULL_WIDTH) ? getAdWidth() : width;

	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(currentWidth)];
	Dictionary dictionary = [adSize buildRawData];

	return dictionary;
}

Dictionary AdmobPlugin::get_landscape_adaptive_banner_size(int width) {
	os_log_debug(admob_log, "AdmobPlugin get_landscape_adaptive_banner_size");
	int currentWidth = (width == FULL_WIDTH) ? getAdWidth() : width;

	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize: GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(currentWidth)];
	Dictionary dictionary = [adSize buildRawData];

	return dictionary;
}

CGFloat AdmobPlugin::getAdWidth() {
	UIWindow *window = nil;
	for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
		if (windowScene.activationState == UISceneActivationStateForegroundActive) {
			for (UIWindow *w in windowScene.windows) {
				if (w.isKeyWindow) {
					window = w;
					break;
				}
			}
			if (window) break;
		}
	}

	CGRect frame = CGRectZero;
	if (window){
		UIView* rootView = window.rootViewController.view;
		frame = rootView.frame;

		UIEdgeInsets safeAreaInsets = rootView.safeAreaInsets;
		frame = UIEdgeInsetsInsetRect(frame, safeAreaInsets);
	}
	else {
		os_log_error(admob_log, "AdmobPlugin getAdWidth(): key window not found");
	}

	return frame.size.width;
}

Error AdmobPlugin::load_banner_ad(Dictionary adData) {
	os_log_debug(admob_log, "AdmobPlugin load_banner_ad");

	if (initialized == false) {
		os_log_error(admob_log, "AdmobPlugin has not been initialized");
		return FAILED;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		LoadAdRequest* loadAdRequest = [[LoadAdRequest alloc] initWithDictionary: adData];
		NSString* adId = [GAPConverter toAdId:loadAdRequest.adUnitId withSequence:++bannerAdSequence];

		BannerAd* ad = [[BannerAd alloc] initWithID:adId];

		bannerAds[adId] = ad;

		[ad load: loadAdRequest];
    });

	return OK;
}

void AdmobPlugin::show_banner_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin show_banner_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		BannerAd* ad = (BannerAd*) bannerAds[[GAPConverter toNsString:adId]];
		if (ad) {
			[ad show];
		} else {
			os_log_error(admob_log, "AdmobPlugin show_banner_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

void AdmobPlugin::hide_banner_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin hide_banner_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		BannerAd* ad = (BannerAd*) bannerAds[[GAPConverter toNsString:adId]];
		if (ad) {
			[ad hide];
		} else {
			os_log_error(admob_log, "AdmobPlugin hide_banner_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

void AdmobPlugin::remove_banner_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin remove_banner_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		NSString* key = [GAPConverter toNsString:adId];
		if (bannerAds[key]) {
			[bannerAds[key] destroy];
			[bannerAds removeObjectForKey:key];
		} else {
			os_log_error(admob_log, "AdmobPlugin remove_banner_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

void AdmobPlugin::move_banner_ad(String adId, real_t x, real_t y) {
	os_log_debug(admob_log, "AdmobPlugin move_banner_ad('%s',%.2f,%.2f)", adId.utf8().get_data(), x, y);

	dispatch_async(dispatch_get_main_queue(), ^{
		BannerAd* banner = [bannerAds objectForKey:[GAPConverter toNsString:adId]];
		if (banner) {
			[banner moveToX:x y:y];
		} else {
			os_log_error(admob_log, "AdmobPlugin remove_banner_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

int AdmobPlugin::get_banner_width(String adId) {
	os_log_debug(admob_log, "AdmobPlugin get_banner_width %s", adId.utf8().get_data());

	BannerAd* ad = (BannerAd*) bannerAds[[GAPConverter toNsString:adId]];
	if (ad) {
		return [ad getWidth];
	} else {
		os_log_error(admob_log, "AdmobPlugin get_banner_width: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
	}

	return -1;
}

int AdmobPlugin::get_banner_height(String adId) {
	os_log_debug(admob_log, "AdmobPlugin get_banner_height %s", adId.utf8().get_data());

	BannerAd* ad = (BannerAd*) bannerAds[[GAPConverter toNsString:adId]];
	if (ad) {
		return [ad getHeight];
	} else {
		os_log_error(admob_log, "AdmobPlugin get_banner_height: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
	}

	return -1;
}

int AdmobPlugin::get_banner_width_in_pixels(String adId) {
	os_log_debug(admob_log, "AdmobPlugin get_width_in_pixels %s", adId.utf8().get_data());

	BannerAd* ad = (BannerAd*) bannerAds[[GAPConverter toNsString:adId]];
	if (ad) {
		return [ad getWidthInPixels];
	} else {
		os_log_error(admob_log, "AdmobPlugin get_width_in_pixels: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
	}

	return -1;
}

int AdmobPlugin::get_banner_height_in_pixels(String adId) {
	os_log_debug(admob_log, "AdmobPlugin get_height_in_pixels %s", adId.utf8().get_data());

	BannerAd* ad = (BannerAd*) bannerAds[[GAPConverter toNsString:adId]];
	if (ad) {
		return [ad getHeightInPixels];
	} else {
		os_log_error(admob_log, "AdmobPlugin get_width_in_pixels: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
	}

	return -1;
}

Error AdmobPlugin::load_interstitial_ad(Dictionary adData) {
	os_log_debug(admob_log, "AdmobPlugin load_interstitial_ad");

	if (initialized == false) {
		os_log_error(admob_log, "AdmobPlugin has not been initialized");
		return FAILED;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		LoadAdRequest* loadAdRequest = [[LoadAdRequest alloc] initWithDictionary: adData];
		NSString* adId = [GAPConverter toAdId:loadAdRequest.adUnitId withSequence:++interstitialAdSequence];

		InterstitialAd *ad = [[InterstitialAd alloc] initWithID:adId];

		interstitialAds[adId] = ad;

		[ad load: loadAdRequest];
    });

	return OK;
}

void AdmobPlugin::show_interstitial_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin show_interstitial_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		InterstitialAd* ad = (InterstitialAd*) interstitialAds[[GAPConverter toNsString:adId]];
		if (ad) {
			[ad show];
		} else {
			os_log_error(admob_log, "AdmobPlugin show_interstitial_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

void AdmobPlugin::remove_interstitial_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin remove_interstitial_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		NSString* key = [GAPConverter toNsString:adId];
		if (interstitialAds[key]) {
			[interstitialAds removeObjectForKey:key];
		} else {
			os_log_error(admob_log, "AdmobPlugin remove_interstitial_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

Error AdmobPlugin::load_rewarded_ad(Dictionary adData) {
	os_log_debug(admob_log, "AdmobPlugin load_rewarded_ad");

	if (initialized == false) {
		os_log_error(admob_log, "AdmobPlugin has not been initialized");
		return FAILED;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		LoadAdRequest* loadAdRequest = [[LoadAdRequest alloc] initWithDictionary: adData];
		NSString* adId = [GAPConverter toAdId:loadAdRequest.adUnitId withSequence:++rewardedAdSequence];

		RewardedAd *ad = [[RewardedAd alloc] initWithID:adId];

		rewardedAds[adId] = ad;

		[ad load: loadAdRequest];
    });

	return OK;
}

void AdmobPlugin::show_rewarded_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin show_rewarded_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		RewardedAd* ad = (RewardedAd*) rewardedAds[[GAPConverter toNsString:adId]];
		if (ad) {
			[ad show];
		} else {
			os_log_error(admob_log, "AdmobPlugin show_rewarded_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

void AdmobPlugin::remove_rewarded_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin remove_rewarded_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		NSString* key = [GAPConverter toNsString:adId];
		if (rewardedAds[key]) {
			[rewardedAds removeObjectForKey:key];
		} else {
			os_log_error(admob_log, "AdmobPlugin remove_rewarded_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

Error AdmobPlugin::load_rewarded_interstitial_ad(Dictionary adData) {
	os_log_debug(admob_log, "AdmobPlugin load_rewarded_interstitial_ad");

	if (initialized == false) {
		os_log_error(admob_log, "AdmobPlugin has not been initialized");
		return FAILED;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		LoadAdRequest* loadAdRequest = [[LoadAdRequest alloc] initWithDictionary: adData];
		NSString* adId = [GAPConverter toAdId:loadAdRequest.adUnitId withSequence:++rewardedInterstitialAdSequence];

		RewardedInterstitialAd *ad = [[RewardedInterstitialAd alloc] initWithID:adId];

		rewardedInterstitialAds[adId] = ad;

		[ad load: loadAdRequest];
    });

	return OK;
}

void AdmobPlugin::show_rewarded_interstitial_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin show_rewarded_interstitial_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		RewardedInterstitialAd* ad = (RewardedInterstitialAd*) rewardedInterstitialAds[[GAPConverter toNsString:adId]];
		if (ad) {
			[ad show];
		} else {
			os_log_error(admob_log, "AdmobPlugin show_rewarded_interstitial_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

void AdmobPlugin::remove_rewarded_interstitial_ad(String adId) {
	os_log_debug(admob_log, "AdmobPlugin remove_rewarded_interstitial_ad %s", adId.utf8().get_data());

	dispatch_async(dispatch_get_main_queue(), ^{
		NSString* key = [GAPConverter toNsString:adId];
		if (rewardedInterstitialAds[key]) {
			[rewardedInterstitialAds removeObjectForKey:key];
		}
		else {
			os_log_error(admob_log, "AdmobPlugin remove_rewarded_interstitial_ad: ERROR: ad with id '%s' not found!", adId.utf8().get_data());
		}
    });
}

Error AdmobPlugin::load_app_open_ad(Dictionary requestDict, bool autoShowOnResume) {
	os_log_debug(admob_log, "AdmobPlugin load_app_open_ad");

	if (initialized == false) {
		os_log_error(admob_log, "AdmobPlugin has not been initialized");
		return FAILED;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		LoadAdRequest* loadAdRequest = [[LoadAdRequest alloc] initWithDictionary: requestDict];
		NSString* nsAdUnitId = [loadAdRequest adUnitId];
		os_log_debug(admob_log, "%@ load_app_open_ad: %@", kLogTag, nsAdUnitId);
		if (this->appOpenAd == nil) {
			this->appOpenAd = [[AppOpenAd alloc] initWithPlugin:this];
		}
		[this->appOpenAd loadWithRequest:loadAdRequest autoShowOnResume:autoShowOnResume];
    });

	return OK;
}

void AdmobPlugin::show_app_open_ad() {
	os_log_debug(admob_log, "%@ show_app_open_ad", kLogTag);

	dispatch_async(dispatch_get_main_queue(), ^{
		if (this->appOpenAd == nil) {
			os_log_debug(admob_log, "%@ Cannot show app open ad: ad instance is nil", kLogTag);
		} else {
			[this->appOpenAd show];
		}
    });
}

bool AdmobPlugin::is_app_open_ad_available() {
	os_log_debug(admob_log, "%@ is_app_open_ad_available", kLogTag);

	bool isAvailable;

	if (this->appOpenAd == nil) {
		os_log_debug(admob_log, "%@ Cannot show app open ad: ad instance is nil", kLogTag);
		isAvailable = false;
	} else {
		isAvailable = [this->appOpenAd isAvailable];
	}

	return isAvailable;
}

void AdmobPlugin::applicationDidBecomeActive() {
	if (appOpenAd) {
		if (appOpenAd.autoShowOnResume) {
			if ([appOpenAd isAvailable] && !appOpenAd.isShowing) {
				os_log_debug(admob_log, "%@ Auto-showing app open ad with 100ms delay", kLogTag);

				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					if ([appOpenAd isAvailable] && !appOpenAd.isShowing) {
						[appOpenAd show];
					}
				});
			} else {
				os_log_debug(admob_log, "%@ App open ad not available or already showing", kLogTag);
			}
		} else {
			os_log_debug(admob_log, "%@ Wont show app open ad: autoShowOnResume is false", kLogTag);
		}
	} else {
		os_log_debug(admob_log, "%@ Cannot check app open ad: ad instance is nil", kLogTag);
	}
}

Error AdmobPlugin::load_consent_form() {
	os_log_debug(admob_log, "AdmobPlugin load_consent_form");

	if (initialized == false) {
		os_log_error(admob_log, "AdmobPlugin has not been initialized");
		return FAILED;
	}

	[consentManager loadFormWithCompletion:^(NSError * _Nullable error) {
		if (error) {
			os_log_error(admob_log, "AdmobPlugin load_consent_form: Error loading ConsentForm. Error code: %ld", (long)error.code);
			Dictionary errorDictionary = [GAPConverter nsFormErrorToGodotDictionary:error];
			AdmobPlugin::get_singleton()->emit_signal(CONSENT_FORM_FAILED_TO_LOAD_SIGNAL, errorDictionary);
		} else {
			AdmobPlugin::get_singleton()->emit_signal(CONSENT_FORM_LOADED_SIGNAL);
		}
	}];

	return OK;
}

Error AdmobPlugin::show_consent_form() {
	os_log_debug(admob_log, "AdmobPlugin show_consent_form");

	UIViewController *rootVC = GDTAppDelegateService.viewController;

	if (rootVC) {
		[consentManager showFormFrom:rootVC completion:^(NSError * _Nullable error) {
			Dictionary formErrorDictionary;
			if (error) {
				os_log_error(admob_log, "AdmobPlugin show_consent_form: Error presenting ConsentForm");
				formErrorDictionary = [GAPConverter nsFormErrorToGodotDictionary:error];
			}
			os_log_debug(admob_log, "AdmobPlugin show_consent_form: completion handler");

			AdmobPlugin::get_singleton()->emit_signal(CONSENT_FORM_DISMISSED_SIGNAL, formErrorDictionary);
		}];
	} else {
		os_log_error(admob_log, "AdmobPlugin show_consent_form: ERROR: Root View Controller not found!");
		return FAILED;
	}

	return OK;
}

String AdmobPlugin::get_consent_status() {
	NSString* status = [consentManager getConsentStatusString];
	os_log_debug(admob_log, "AdmobPlugin get_consent_status: %@", status);
	return [status UTF8String];
}

bool AdmobPlugin::is_consent_form_available() {
	return [consentManager isFormAvailable];
}

void AdmobPlugin::update_consent_info(Dictionary consentRequestParameters) {
	os_log_debug(admob_log, "AdmobPlugin update_consent_info");

	UMPRequestParameters* parameters = [GAPConverter godotDictionaryToUMPRequestParameters:consentRequestParameters];

	[consentManager requestConsentInfoUpdateWith:parameters completion:^(NSError * _Nullable error) {
		if (error) {
			Dictionary formErrorDictionary = [GAPConverter nsFormErrorToGodotDictionary:error];
			AdmobPlugin::get_singleton()->emit_signal(CONSENT_INFO_UPDATE_FAILED_SIGNAL, formErrorDictionary);
		}
		else {
			AdmobPlugin::get_singleton()->emit_signal(CONSENT_INFO_UPDATED_SIGNAL);
		}
	}];
}

void AdmobPlugin::reset_consent_info() {
	os_log_debug(admob_log, "AdmobPlugin reset_consent_info");
	[consentManager reset];
}

void AdmobPlugin::set_mediation_privacy_settings(Dictionary settings) {
	os_log_debug(admob_log, "AdmobPlugin set_mediation_privacy_settings");

	PrivacySettings* privacySettings = [[PrivacySettings alloc] initWithDictionary: settings];
	[privacySettings applyPrivacySettings];
}

void AdmobPlugin::request_tracking_authorization() {
	os_log_debug(admob_log, "AdmobPlugin request_tracking_authorization");
	[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
		if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
			os_log_debug(admob_log, "Tracking has been authorized for %@", [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
			dispatch_async(dispatch_get_main_queue(), ^{
				instance->emit_signal(TRACKING_AUTHORIZATION_GRANTED);
			});
		} else {
			os_log_debug(admob_log, "Tracking has been denied for %@ with status '%@'", [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString],
				[GAPConverter convertTrackingStatusToString: status]);
			dispatch_async(dispatch_get_main_queue(), ^{
				instance->emit_signal(TRACKING_AUTHORIZATION_DENIED);
			});
		}
	}];
}

void AdmobPlugin::open_app_settings() {
	// Create the URL that deep links to app's custom settings.
	NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
	// Ask the system to open that URL.
	[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

AdmobPlugin* AdmobPlugin::get_singleton() {
	return instance;
}

AdmobPlugin::AdmobPlugin() {
	os_log_debug(admob_log, "%@ constructor", kLogTag);

	ERR_FAIL_COND(instance != NULL);

	instance = this;

	initialized = false;
	bannerAdSequence = 0;
	interstitialAdSequence = 0;
	rewardedAdSequence = 0;
	rewardedInterstitialAdSequence = 0;
	bannerAds = [[NSMutableDictionary alloc] init];
	interstitialAds = [[NSMutableDictionary alloc] init];
	rewardedAds = [[NSMutableDictionary alloc] init];
	rewardedInterstitialAds = [[NSMutableDictionary alloc] init];
	appOpenAd = nil;
	consentManager = [[ConsentManager alloc] init];
	foregroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
													object:nil
													queue:[NSOperationQueue mainQueue]
													usingBlock:^(NSNotification * _Nonnull note) {
		this->applicationDidBecomeActive();
	}];
}

AdmobPlugin::~AdmobPlugin() {
	os_log_debug(admob_log, "%@ destructor", kLogTag);

	if (instance == this) {
		instance = nullptr;
	}
	if (foregroundObserver) {
		[[NSNotificationCenter defaultCenter] removeObserver:foregroundObserver];
	}
}
