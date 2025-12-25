//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_plugin_h
#define admob_plugin_h

#import <Foundation/Foundation.h>

#import "banner.h"
#import "interstitial.h"
#import "rewarded.h"
#import "rewarded_interstitial.h"
#import "app_open.h"


@class ConsentManager;


extern const String INITIALIZATION_COMPLETED_SIGNAL;
extern const String BANNER_AD_LOADED_SIGNAL;
extern const String BANNER_AD_FAILED_TO_LOAD_SIGNAL;
extern const String BANNER_AD_REFRESHED_SIGNAL;
extern const String BANNER_AD_IMPRESSION_SIGNAL;
extern const String BANNER_AD_SIZE_MEASURED_SIGNAL;
extern const String BANNER_AD_CLICKED_SIGNAL;
extern const String BANNER_AD_OPENED_SIGNAL;
extern const String BANNER_AD_CLOSED_SIGNAL;
extern const String INTERSTITIAL_AD_LOADED_SIGNAL;
extern const String INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL;
extern const String INTERSTITIAL_AD_REFRESHED_SIGNAL;
extern const String INTERSTITIAL_AD_IMPRESSION_SIGNAL;
extern const String INTERSTITIAL_AD_CLICKED_SIGNAL;
extern const String INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL;
extern const String INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_AD_LOADED_SIGNAL;
extern const String REWARDED_AD_FAILED_TO_LOAD_SIGNAL;
extern const String REWARDED_AD_IMPRESSION_SIGNAL;
extern const String REWARDED_AD_CLICKED_SIGNAL;
extern const String REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_AD_USER_EARNED_REWARD_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_LOADED_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_IMPRESSION_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD_SIGNAL;
extern const String APP_OPEN_AD_LOADED_SIGNAL;
extern const String APP_OPEN_AD_FAILED_TO_LOAD_SIGNAL;
extern const String APP_OPEN_AD_IMPRESSION_SIGNAL;
extern const String APP_OPEN_AD_CLICKED_SIGNAL;
extern const String APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL;
extern const String APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL;
extern const String CONSENT_FORM_LOADED_SIGNAL;
extern const String CONSENT_FORM_FAILED_TO_LOAD_SIGNAL;
extern const String CONSENT_FORM_DISMISSED_SIGNAL;
extern const String CONSENT_INFO_UPDATED_SIGNAL;
extern const String CONSENT_INFO_UPDATE_FAILED_SIGNAL;
extern const String TRACKING_AUTHORIZATION_GRANTED;
extern const String TRACKING_AUTHORIZATION_DENIED;


class AdmobPlugin : public Object {
	GDCLASS(AdmobPlugin, Object);

private:
	static AdmobPlugin* instance; // Singleton instance
	bool initialized; // Tracks initialization status
	int bannerAdSequence; // Sequence for banner ad IDs
	int interstitialAdSequence; // Sequence for interstitial ad IDs
	int rewardedAdSequence; // Sequence for rewarded ad IDs
	int rewardedInterstitialAdSequence; // Sequence for rewarded interstitial ad IDs

	NSMutableDictionary<NSString*, BannerAd*>* bannerAds;
	NSMutableDictionary<NSString*, InterstitialAd*>* interstitialAds;
	NSMutableDictionary<NSString*, RewardedAd*>* rewardedAds;
	NSMutableDictionary<NSString*, RewardedInterstitialAd*>* rewardedInterstitialAds;

	ConsentManager* consentManager;

	AppOpenAd* appOpenAd; // One app open ad per app (if enabled)
	id<NSObject> foregroundObserver; // Notification observer token

	Error initialize();
	Error set_request_configuration(Dictionary configData);
	Dictionary get_initialization_status();
	void set_app_pause_on_background(bool pause);

	Dictionary get_current_adaptive_banner_size(int width);
	Dictionary get_portrait_adaptive_banner_size(int width);
	Dictionary get_landscape_adaptive_banner_size(int width);
	Error load_banner_ad(Dictionary adData);
	void show_banner_ad(String adId);
	void hide_banner_ad(String adId);
	void remove_banner_ad(String adId);
	void move_banner_ad(String adId, real_t x, real_t y);
	int get_banner_width(String adId);
	int get_banner_height(String adId);
	int get_banner_width_in_pixels(String adId);
	int get_banner_height_in_pixels(String adId);

	Error load_interstitial_ad(Dictionary adData);
	void show_interstitial_ad(String adId);
	void remove_interstitial_ad(String adId);

	Error load_rewarded_ad(Dictionary adData);
	void show_rewarded_ad(String adId);
	void remove_rewarded_ad(String adId);

	Error load_rewarded_interstitial_ad(Dictionary adData);
	void show_rewarded_interstitial_ad(String adId);
	void remove_rewarded_interstitial_ad(String adId);

	Error load_app_open_ad(Dictionary requestDict, bool autoShowOnResume);
	void show_app_open_ad();
	bool is_app_open_ad_available();

	Error load_consent_form();
	Error show_consent_form();
	String get_consent_status();
	bool is_consent_form_available();
	void update_consent_info(Dictionary consentRequestParameters);
	void reset_consent_info();

	void set_mediation_privacy_settings(Dictionary settings);

	void request_tracking_authorization();
	void open_app_settings();

	// Lifecycle handler
	void applicationDidBecomeActive();

	// Helper method for adaptive banner sizing
	CGFloat getAdWidth();

	static void _bind_methods();

public:

	static AdmobPlugin* get_singleton();

	AdmobPlugin();
	~AdmobPlugin();
};

#endif /* admob_plugin_h */
