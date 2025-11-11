//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.collection.ArraySet;
import androidx.lifecycle.ProcessLifecycleOwner;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.ump.ConsentForm;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.UserMessagingPlatform;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import org.godotengine.plugin.android.admob.mediation.PrivacySettings;
import org.godotengine.plugin.android.admob.model.AdmobConfiguration;
import org.godotengine.plugin.android.admob.model.AdmobResponse;
import org.godotengine.plugin.android.admob.model.AdmobStatus;
import org.godotengine.plugin.android.admob.model.ConsentConfiguration;
import org.godotengine.plugin.android.admob.model.LoadAdRequest;

public class AdmobPlugin extends GodotPlugin {
	public static final String CLASS_NAME = AdmobPlugin.class.getSimpleName();
	static final String LOG_TAG = "godot::" + CLASS_NAME;

	static final String SIGNAL_INITIALIZATION_COMPLETED = "initialization_completed";
	static final String SIGNAL_BANNER_AD_LOADED = "banner_ad_loaded";
	static final String SIGNAL_BANNER_AD_FAILED_TO_LOAD = "banner_ad_failed_to_load";
	static final String SIGNAL_BANNER_AD_REFRESHED = "banner_ad_refreshed";
	static final String SIGNAL_BANNER_AD_IMPRESSION = "banner_ad_impression";
	static final String SIGNAL_BANNER_AD_CLICKED = "banner_ad_clicked";
	static final String SIGNAL_BANNER_AD_OPENED = "banner_ad_opened";
	static final String SIGNAL_BANNER_AD_CLOSED = "banner_ad_closed";
	static final String SIGNAL_INTERSTITIAL_AD_LOADED = "interstitial_ad_loaded";
	static final String SIGNAL_INTERSTITIAL_AD_FAILED_TO_LOAD = "interstitial_ad_failed_to_load";
	static final String SIGNAL_INTERSTITIAL_AD_REFRESHED = "interstitial_ad_refreshed";
	static final String SIGNAL_INTERSTITIAL_AD_IMPRESSION = "interstitial_ad_impression";
	static final String SIGNAL_INTERSTITIAL_AD_CLICKED = "interstitial_ad_clicked";
	static final String SIGNAL_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT = "interstitial_ad_showed_full_screen_content";
	static final String SIGNAL_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "interstitial_ad_failed_to_show_full_screen_content";
	static final String SIGNAL_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT = "interstitial_ad_dismissed_full_screen_content";
	static final String SIGNAL_REWARDED_AD_LOADED = "rewarded_ad_loaded";
	static final String SIGNAL_REWARDED_AD_FAILED_TO_LOAD = "rewarded_ad_failed_to_load";
	static final String SIGNAL_REWARDED_AD_IMPRESSION = "rewarded_ad_impression";
	static final String SIGNAL_REWARDED_AD_CLICKED = "rewarded_ad_clicked";
	static final String SIGNAL_REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT = "rewarded_ad_showed_full_screen_content";
	static final String SIGNAL_REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "rewarded_ad_failed_to_show_full_screen_content";
	static final String SIGNAL_REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT = "rewarded_ad_dismissed_full_screen_content";
	static final String SIGNAL_REWARDED_AD_USER_EARNED_REWARD = "rewarded_ad_user_earned_reward";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_LOADED = "rewarded_interstitial_ad_loaded";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD = "rewarded_interstitial_ad_failed_to_load";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_IMPRESSION = "rewarded_interstitial_ad_impression";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_CLICKED = "rewarded_interstitial_ad_clicked";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT = "rewarded_interstitial_ad_showed_full_screen_content";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "rewarded_interstitial_ad_failed_to_show_full_screen_content";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT = "rewarded_interstitial_ad_dismissed_full_screen_content";
	static final String SIGNAL_REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD = "rewarded_interstitial_ad_user_earned_reward";
	static final String SIGNAL_APP_OPEN_AD_LOADED = "app_open_ad_loaded";
	static final String SIGNAL_APP_OPEN_AD_FAILED_TO_LOAD = "app_open_ad_failed_to_load";
	static final String SIGNAL_APP_OPEN_AD_IMPRESSION = "app_open_ad_impression";
	static final String SIGNAL_APP_OPEN_AD_CLICKED = "app_open_ad_clicked";
	static final String SIGNAL_APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT = "app_open_ad_showed_full_screen_content";
	static final String SIGNAL_APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "app_open_ad_failed_to_show_full_screen_content";
	static final String SIGNAL_APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT = "app_open_ad_dismissed_full_screen_content";
	static final String SIGNAL_CONSENT_FORM_LOADED = "consent_form_loaded";
	static final String SIGNAL_CONSENT_FORM_FAILED_TO_LOAD = "consent_form_failed_to_load";
	static final String SIGNAL_CONSENT_FORM_DISMISSED = "consent_form_dismissed";
	static final String SIGNAL_CONSENT_INFO_UPDATED = "consent_info_updated";
	static final String SIGNAL_CONSENT_INFO_UPDATE_FAILED = "consent_info_update_failed";

	Activity activity;

	/**
	 * Whether app is being tested (isReal=false) or app is in production (isReal=true)
	 */
	private boolean isReal = false;


	private boolean isForChildDirectedTreatment = false;

	/**
	 * Ads are personalized by default, GDPR compliance within the European Economic Area may require disabling of personalization.
	 */
	private boolean isPersonalized = true;
	private String maxAdContentRating = "";
	private Bundle extras = null;

	private FrameLayout layout = null;

	private int bannerAdIdSequence;
	private int interstitialAdIdSequence;
	private int rewardedAdIdSequence;
	private int rewardedInterstitialAdIdSequence;

	private boolean isInitialized;

	private Map<String, Banner> bannerAds;
	private Map<String, Interstitial> interstitialAds;
	private Map<String, RewardedVideo> rewardedAds;
	private Map<String, RewardedInterstitial> rewardedInterstitialAds;
	
	private AppOpenAdManager appOpenAdManager;

	private ConsentForm consentForm;


	public AdmobPlugin(Godot godot) {
		super(godot);

		bannerAds = new HashMap<>();
		interstitialAds = new HashMap<>();
		rewardedAds = new HashMap<>();
		rewardedInterstitialAds = new HashMap<>();

		isInitialized = false;

		appOpenAdManager = new AppOpenAdManager(this);
		ProcessLifecycleOwner.get().getLifecycle().addObserver(appOpenAdManager);
	}

	@NonNull
	@Override
	public String getPluginName() {
		return CLASS_NAME;
	}

	@NonNull
	@Override
	public Set<SignalInfo> getPluginSignals() {
		Set<SignalInfo> signals = new ArraySet<>();

		signals.add(new SignalInfo(SIGNAL_INITIALIZATION_COMPLETED, Dictionary.class));

		signals.add(new SignalInfo(SIGNAL_BANNER_AD_LOADED, String.class, Dictionary.class, Boolean.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_REFRESHED, String.class, Dictionary.class, Boolean.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_OPENED, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_CLOSED, String.class));

		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_LOADED, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_REFRESHED, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));

		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_LOADED, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_USER_EARNED_REWARD, String.class, Dictionary.class));

		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_LOADED, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD, String.class, Dictionary.class));

		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_LOADED, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));

		signals.add(new SignalInfo(SIGNAL_CONSENT_FORM_LOADED));
		signals.add(new SignalInfo(SIGNAL_CONSENT_FORM_FAILED_TO_LOAD, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_CONSENT_FORM_DISMISSED, Dictionary.class));

		signals.add(new SignalInfo(SIGNAL_CONSENT_INFO_UPDATED));
		signals.add(new SignalInfo(SIGNAL_CONSENT_INFO_UPDATE_FAILED, Dictionary.class));

		return signals;
	}

	@UsedByGodot
	public void initialize() {
		Log.d(LOG_TAG, "initialize()");

		bannerAdIdSequence = 0;
		interstitialAdIdSequence = 0;
		rewardedAdIdSequence = 0;
		rewardedInterstitialAdIdSequence = 0;

		bannerAds.clear();
		interstitialAds.clear();
		rewardedAds.clear();
		rewardedInterstitialAds.clear();

		isInitialized = false;

		// Initialize Mobile Ads SDK on a background thread
		new Thread(new Runnable() {
			@Override
			public void run() {
				MobileAds.initialize(activity, new OnInitializationCompleteListener() {
					@Override
					public void onInitializationComplete(InitializationStatus initializationStatus) {
						isInitialized = true;
						emitSignal(SIGNAL_INITIALIZATION_COMPLETED, new AdmobStatus(initializationStatus).buildRawData());
					}
				});
			}
		}).start();
	}

	@UsedByGodot
	public void set_request_configuration(Dictionary configData) {
		Log.d(LOG_TAG, "set_request_configuration()");
		AdmobConfiguration config = new AdmobConfiguration(configData);
		MobileAds.setRequestConfiguration(config.createRequestConfiguration(activity));
	}

	@UsedByGodot
	public Dictionary get_initialization_status() {
		Log.d(LOG_TAG, "get_initialization_status()");
		return new AdmobStatus(MobileAds.getInitializationStatus()).buildRawData();
	}

	@UsedByGodot
	public Dictionary get_current_adaptive_banner_size(int width) {
		Log.d(LOG_TAG, "get_current_adaptive_banner_size()");
		int currentWidth = (width == AdSize.FULL_WIDTH) ? Banner.getAdWidth(activity) : width;
		return GodotConverter.convert(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, currentWidth));
	}

	@UsedByGodot
	public Dictionary get_portrait_adaptive_banner_size(int width) {
		Log.d(LOG_TAG, "get_portrait_adaptive_banner_size()");
		int currentWidth = (width == AdSize.FULL_WIDTH) ? Banner.getAdWidth(activity) : width;
		return GodotConverter.convert(AdSize.getPortraitAnchoredAdaptiveBannerAdSize(activity, currentWidth));
	}

	@UsedByGodot
	public Dictionary get_landscape_adaptive_banner_size(int width) {
		Log.d(LOG_TAG, "get_landscape_adaptive_banner_size()");
		int currentWidth = (width == AdSize.FULL_WIDTH) ? Banner.getAdWidth(activity) : width;
		return GodotConverter.convert(AdSize.getLandscapeAnchoredAdaptiveBannerAdSize(activity, currentWidth));
	}

	@UsedByGodot
	public void load_banner_ad(Dictionary adData) {
		if (isInitialized) {
			Log.d(LOG_TAG, "load_banner_ad()");

			LoadAdRequest loadAdRequest = new LoadAdRequest(adData);
			if (loadAdRequest.isValid()) {
				String adId = loadAdRequest.generateAdId(++bannerAdIdSequence);
				Banner banner = new Banner(adId, loadAdRequest, activity, layout,
						new BannerListener() {
							@Override
							public void onAdLoaded(String adId, ResponseInfo responseInfo, boolean isCollapsible) {
								emitSignal(SIGNAL_BANNER_AD_LOADED, adId, new AdmobResponse(responseInfo).buildRawData(), isCollapsible);
							}

							@Override
							public void onAdRefreshed(String adId, ResponseInfo responseInfo, boolean isCollapsible) {
								Log.d(LOG_TAG, String.format("onAdRefreshed(%s) banner", adId));
								emitSignal(SIGNAL_BANNER_AD_REFRESHED, adId, new AdmobResponse(responseInfo).buildRawData(), isCollapsible);
							}

							@Override
							public void onAdFailedToLoad(String adId, LoadAdError adError) {
								emitSignal(SIGNAL_BANNER_AD_FAILED_TO_LOAD, adId, GodotConverter.convert(adError));
							}

							@Override
							public void onAdClicked(String adId) {
								emitSignal(SIGNAL_BANNER_AD_CLICKED, adId);
							}

							@Override
							public void onAdClosed(String adId) {
								emitSignal(SIGNAL_BANNER_AD_CLOSED, adId);
							}

							@Override
							public void onAdImpression(String adId) {
								emitSignal(SIGNAL_BANNER_AD_IMPRESSION, adId);
							}

							@Override
							public void onAdOpened(String adId) {
								emitSignal(SIGNAL_BANNER_AD_OPENED, adId);
							}
						});
				bannerAds.put(adId, banner);
				banner.load();
			} else {
				Log.e(LOG_TAG, "load_banner_ad(): Error: Ad request data is invalid.");
			}
		}
		else {
				Log.e(LOG_TAG, "load_banner_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_banner_ad(String adId) {
		if (bannerAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("show_banner_ad(): %s", adId));
			Banner bannerAd = bannerAds.get(adId);
			bannerAd.show();
		}
		else {
			Log.e(LOG_TAG, String.format("show_banner_ad(): Error: banner ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void hide_banner_ad(String adId) {
		if (bannerAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("hide_banner_ad(): %s", adId));
			Banner bannerAd = bannerAds.get(adId);
			bannerAd.hide();
		}
		else {
			Log.e(LOG_TAG, String.format("hide_banner_ad(): Error: banner ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void remove_banner_ad(String adId) {
		if (bannerAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("remove_banner_ad(): %s", adId));
			Banner bannerAd = bannerAds.remove(adId);
			bannerAd.remove();
		}
		else {
			Log.e(LOG_TAG, String.format("remove_banner_ad(): Error: banner ad %s not found", adId));
		}
	}

	@UsedByGodot
	public int get_banner_width(String adId) {
		int result = 0;

		if (bannerAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("get_banner_width(): %s", adId));
			Banner bannerAd = bannerAds.get(adId);
			result = bannerAd.getWidth();
		}
		else {
			Log.e(LOG_TAG, String.format("get_banner_width(): Error: banner ad %s not found", adId));
		}

		return result;
	}

	@UsedByGodot
	public int get_banner_height(String adId) {
		int result = 0;

		if (bannerAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("get_banner_height(): %s", adId));
			Banner bannerAd = bannerAds.get(adId);
			result = bannerAd.getHeight();
		}
		else {
			Log.e(LOG_TAG, String.format("get_banner_height(): Error: banner ad %s not found", adId));
		}

		return result;
	}

	@UsedByGodot
	public int get_banner_width_in_pixels(String adId) {
		int result = 0;

		if (bannerAds.containsKey(adId)) {
			Banner bannerAd = bannerAds.get(adId);
			result = bannerAd.getWidthInPixels();
			Log.d(LOG_TAG, String.format("get_banner_width_in_pixels(): %s - %d", adId, result));
		}
		else {
			Log.e(LOG_TAG, String.format("get_banner_width_in_pixels(): Error: banner ad %s not found", adId));
		}

		return result;
	}

	@UsedByGodot
	public int get_banner_height_in_pixels(String adId) {
		int result = 0;

		if (bannerAds.containsKey(adId)) {
			Banner bannerAd = bannerAds.get(adId);
			result = bannerAd.getHeightInPixels();
			Log.d(LOG_TAG, String.format("get_banner_height_in_pixels(): %s - %d", adId, result));
		}
		else {
			Log.e(LOG_TAG, String.format("get_banner_height_in_pixels(): Error: banner ad %s not found", adId));
		}

		return result;
	}

	@UsedByGodot
	public void load_interstitial_ad(Dictionary adData) {
		if (isInitialized) {
			Log.d(LOG_TAG, "load_interstitial_ad()");

			LoadAdRequest loadAdRequest = new LoadAdRequest(adData);
			if (loadAdRequest.isValid()) {
				String adId = loadAdRequest.generateAdId(++interstitialAdIdSequence);

				Interstitial ad = new Interstitial(adId, loadAdRequest, activity, new InterstitialListener() {
					@Override
					public void onInterstitialLoaded(String adId, ResponseInfo responseInfo) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_LOADED, adId, new AdmobResponse(responseInfo).buildRawData());
					}

					@Override
					public void onInterstitialReloaded(String adId, ResponseInfo responseInfo) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_REFRESHED, adId, new AdmobResponse(responseInfo).buildRawData());
					}

					@Override
					public void onInterstitialFailedToLoad(String adId, LoadAdError loadAdError) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_FAILED_TO_LOAD, adId, GodotConverter.convert(loadAdError));
					}

					@Override
					public void onInterstitialFailedToShow(String adId, AdError adError) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, adId, GodotConverter.convert(adError));
					}

					@Override
					public void onInterstitialOpened(String adId) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, adId);
					}

					@Override
					public void onInterstitialClosed(String adId) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT, adId);
					}

					@Override
					public void onInterstitialClicked(String adId) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_CLICKED, adId);
					}

					@Override
					public void onInterstitialImpression(String adId) {
						emitSignal(SIGNAL_INTERSTITIAL_AD_IMPRESSION, adId);
					}
				});
				interstitialAds.put(adId, ad);
				Log.d(LOG_TAG, String.format("load_interstitial_ad(): %s", adId));
				ad.load();
			} else {
				Log.e(LOG_TAG, "load_interstitial_ad(): Error: Ad request data is invalid.");
			}
		}
		else {
			Log.e(LOG_TAG, "load_interstitial_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_interstitial_ad(String adId) {
		if (interstitialAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("show_interstitial_ad(): %s", adId));
			Interstitial ad = interstitialAds.get(adId);
			assert ad != null;
			ad.show();
		}
		else {
			Log.e(LOG_TAG, String.format("show_interstitial_ad(): Error: ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void remove_interstitial_ad(String adId) {
		if (interstitialAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("remove_interstitial_ad(): %s", adId));
			interstitialAds.remove(adId);
		}
		else {
			Log.e(LOG_TAG, String.format("remove_interstitial_ad(): Error: ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void load_rewarded_ad(Dictionary adData) {
		if (isInitialized) {
			Log.d(LOG_TAG, "load_rewarded_ad()");

			LoadAdRequest loadAdRequest = new LoadAdRequest(adData);
			if (loadAdRequest.isValid()) {
				String adId = loadAdRequest.generateAdId(++rewardedAdIdSequence);

				RewardedVideo ad = new RewardedVideo(adId, loadAdRequest, activity, new RewardedVideoListener() {
					@Override
					public void onRewardedVideoLoaded(String adId, ResponseInfo responseInfo) {
						emitSignal(SIGNAL_REWARDED_AD_LOADED, adId, new AdmobResponse(responseInfo).buildRawData());
					}

					@Override
					public void onRewardedVideoFailedToLoad(String adId, LoadAdError loadAdError) {
						emitSignal(SIGNAL_REWARDED_AD_FAILED_TO_LOAD, adId, GodotConverter.convert(loadAdError));
					}

					@Override
					public void onRewardedVideoOpened(String adId) {
						emitSignal(SIGNAL_REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT, adId);
					}

					@Override
					public void onRewardedVideoFailedToShow(String adId, AdError adError) {
						emitSignal(SIGNAL_REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, adId, GodotConverter.convert(adError));
					}

					@Override
					public void onRewardedVideoClosed(String adId) {
						emitSignal(SIGNAL_REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT, adId);
					}

					@Override
					public void onRewardedClicked(String adId) {
						emitSignal(SIGNAL_REWARDED_AD_CLICKED, adId);
					}

					@Override
					public void onRewardedAdImpression(String adId) {
						emitSignal(SIGNAL_REWARDED_AD_IMPRESSION, adId);
					}

					@Override
					public void onRewarded(String adId, RewardItem reward) {
						emitSignal(SIGNAL_REWARDED_AD_USER_EARNED_REWARD, adId, GodotConverter.convert(reward));
					}
				});
				ad.setServerSideVerificationOptions(GodotConverter.createSSVO(adData));
				rewardedAds.put(adId, ad);
				Log.d(LOG_TAG, String.format("load_rewarded_ad(): %s", adId));
				ad.load();
			} else {
				Log.e(LOG_TAG, "load_rewarded_ad(): Error: Ad request data is invalid.");
			}
		}
		else {
			Log.e(LOG_TAG, "load_rewarded_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_rewarded_ad(String adId) {
		if (rewardedAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("show_rewarded_ad(): %s", adId));
			RewardedVideo ad = rewardedAds.get(adId);
			ad.show();
		}
		else {
			Log.e(LOG_TAG, String.format("show_rewarded_ad(): Error: ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void remove_rewarded_ad(String adId) {
		if (rewardedAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("remove_rewarded_ad(): %s", adId));
			rewardedAds.remove(adId);
		}
		else {
			Log.e(LOG_TAG, String.format("remove_rewarded_ad(): Error: ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void load_rewarded_interstitial_ad(Dictionary adData) {
		if (isInitialized) {
			Log.d(LOG_TAG, "load_rewarded_interstitial_ad()");

			LoadAdRequest loadAdRequest = new LoadAdRequest(adData);
			if (loadAdRequest.isValid()) {
				String adId = loadAdRequest.generateAdId(++rewardedInterstitialAdIdSequence);

				RewardedInterstitial ad = new RewardedInterstitial(adId, loadAdRequest, activity, new RewardedInterstitialListener() {
					@Override
					public void onRewardedInterstitialLoaded(String adId, ResponseInfo responseInfo) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_LOADED, adId, new AdmobResponse(responseInfo).buildRawData());
					}

					@Override
					public void onRewardedInterstitialFailedToLoad(String adId, LoadAdError loadAdError) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD, adId, GodotConverter.convert(loadAdError));
					}

					@Override
					public void onRewardedInterstitialOpened(String adId) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, adId);
					}

					@Override
					public void onRewardedInterstitialFailedToShow(String adId, AdError adError) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, adId, GodotConverter.convert(adError));
					}

					@Override
					public void onRewardedInterstitialClosed(String adId) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT, adId);
					}

					@Override
					public void onRewardedClicked(String adId) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_CLICKED, adId);
					}

					@Override
					public void onRewardedAdImpression(String adId) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_IMPRESSION, adId);
					}

					@Override
					public void onRewarded(String adId, RewardItem reward) {
						emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD, adId, GodotConverter.convert(reward));
					}
				});
				ad.setServerSideVerificationOptions(GodotConverter.createSSVO(adData));
				rewardedInterstitialAds.put(adId, ad);
				Log.d(LOG_TAG, String.format("load_rewarded_interstitial_ad(): %s", adId));
				ad.load();
			} else {
				Log.e(LOG_TAG, "load_rewarded_interstitial_ad(): Error: Ad request data is invalid.");
			}
		}
		else {
			Log.e(LOG_TAG, "load_rewarded_interstitial_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_rewarded_interstitial_ad(String adId) {
		if (rewardedInterstitialAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("show_rewarded_interstitial_ad(): %s", adId));
			RewardedInterstitial ad = rewardedInterstitialAds.get(adId);
			ad.show();
		} else {
			Log.e(LOG_TAG, String.format("show_rewarded_interstitial_ad(): Error: ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void remove_rewarded_interstitial_ad(String adId) {
		if (rewardedInterstitialAds.containsKey(adId)) {
			Log.d(LOG_TAG, String.format("remove_rewarded_interstitial_ad(): %s", adId));
			rewardedInterstitialAds.remove(adId);
		}
		else {
			Log.e(LOG_TAG, String.format("remove_rewarded_interstitial_ad(): Error: ad %s not found", adId));
		}
	}

	@UsedByGodot
	public void load_app_open_ad(Dictionary adRequest, boolean autoShowOnResume) {
		LoadAdRequest loadAdRequest = new LoadAdRequest(adRequest);
		Log.d(LOG_TAG, String.format("load_app_open_ad('%s', %b)", loadAdRequest.getAdUnitId(), autoShowOnResume));
		appOpenAdManager.autoShowOnResume = autoShowOnResume;
		appOpenAdManager.loadAd(loadAdRequest);
	}

	@UsedByGodot
	public void show_app_open_ad() {
		Log.d(LOG_TAG, "show_app_open_ad()");
		appOpenAdManager.showAd();
	}

	@UsedByGodot
	public boolean is_app_open_ad_available() {
		return appOpenAdManager.isAdAvailable();
	}

	@UsedByGodot
	public void load_consent_form() {
		Log.d(LOG_TAG, "load_consent_form()");
		activity.runOnUiThread(() -> {
			UserMessagingPlatform.loadConsentForm(
				activity,
				(UserMessagingPlatform.OnConsentFormLoadSuccessListener) loadedForm -> {
					consentForm = loadedForm;
					emitSignal(SIGNAL_CONSENT_FORM_LOADED);
				},
				(UserMessagingPlatform.OnConsentFormLoadFailureListener) formError -> {
					emitSignal(SIGNAL_CONSENT_FORM_FAILED_TO_LOAD, GodotConverter.convert(formError));
				}
			);
		});
	}

	@UsedByGodot
	public void show_consent_form() {
		if (consentForm == null) {
			Log.e(LOG_TAG, "show_consent_form(): Error: consent form not found!");
		} else {
			Log.d(LOG_TAG, "show_consent_form()");
			activity.runOnUiThread(() -> {
				consentForm.show(activity, (ConsentForm.OnConsentFormDismissedListener) formError -> {
					emitSignal(SIGNAL_CONSENT_FORM_DISMISSED, GodotConverter.convert(formError));
				});
			});
		}
	}

	@UsedByGodot
	public String get_consent_status() {
		int consentStatus = UserMessagingPlatform.getConsentInformation(activity).getConsentStatus();
		Log.d(LOG_TAG, String.format("get_consent_status(): %s", consentStatus));
		return switch (consentStatus) {
			case ConsentInformation.ConsentStatus.NOT_REQUIRED -> "NOT_REQUIRED";
			case ConsentInformation.ConsentStatus.REQUIRED -> "REQUIRED";
			case ConsentInformation.ConsentStatus.OBTAINED -> "OBTAINED";
			default -> "UNKNOWN";
		};
	}

	@UsedByGodot
	public boolean is_consent_form_available() {
		Log.d(LOG_TAG, "is_consent_form_available()");
		return UserMessagingPlatform.getConsentInformation(activity).isConsentFormAvailable();
	}

	@UsedByGodot
	public void update_consent_info(Dictionary consentRequestParameters) {
		Log.d(LOG_TAG, "update_consent_info()");
		ConsentInformation consentInformation = UserMessagingPlatform.getConsentInformation(activity);

		consentInformation.requestConsentInfoUpdate(
			activity,
			new ConsentConfiguration(consentRequestParameters).createConsentRequestParameters(activity),
			(ConsentInformation.OnConsentInfoUpdateSuccessListener) () -> {
				emitSignal(SIGNAL_CONSENT_INFO_UPDATED);
			},
			(ConsentInformation.OnConsentInfoUpdateFailureListener) requestConsentError -> {
				emitSignal(SIGNAL_CONSENT_INFO_UPDATE_FAILED, GodotConverter.convert(requestConsentError));
				Log.w(LOG_TAG, String.format("%s: %s", requestConsentError.getErrorCode(), requestConsentError.getMessage()));
			}
		);
	}

	@UsedByGodot
	public void reset_consent_info() {
		Log.d(LOG_TAG, "reset_consent_info()");
		UserMessagingPlatform.getConsentInformation(activity).reset();
	}

	@UsedByGodot
	public void set_mediation_privacy_settings(Dictionary settings) {
		Log.d(LOG_TAG, "set_mediation_privacy_settings()");

		PrivacySettings privacySettings = new PrivacySettings(settings);
		privacySettings.applyPrivacySettings(activity.getApplicationContext());
	}

	@Override
	public View onMainCreate(Activity activity) {
		this.activity = activity;
		try {
			this.activity.getApplication().registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
				@Override
				public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {}

				// Implement as in doc, but since single activity, minimal
				@Override
				public void onActivityStarted(@NonNull Activity activity) {
					if (!appOpenAdManager.isShowingAd) {
						// Update currentActivity if needed; but use plugin's activity
					}
				}

				@Override
				public void onActivityResumed(@NonNull Activity activity) {}

				@Override
				public void onActivityPaused(@NonNull Activity activity) {}

				@Override
				public void onActivityStopped(@NonNull Activity activity) {}

				@Override
				public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {}

				@Override
				public void onActivityDestroyed(@NonNull Activity activity) {}
			});
		} catch (Exception e) {
			Log.e(LOG_TAG, "Failed to register lifecycle: " + e);
		}
		this.activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING);
		this.layout = new FrameLayout(activity); // create and add a new layout to Godot
		return layout;
	}


	@Override
	public void onMainResume() {
		super.onMainResume();
		if (appOpenAdManager.autoShowOnResume) {
			if (appOpenAdManager.appHasResumedAfterShowing) {
				Log.d(LOG_TAG, "App has resumed and autoShowOnResume is true. Attempting to show app open ad.");

				// Wait for app to be moved to foreground
				new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
					@Override
					public void run() {
						appOpenAdManager.showAd();
					}
				}, 100); // Delay in milliseconds
			} else {
				Log.d(LOG_TAG, "App has resumed and autoShowOnResume is true, but this is the app resuming after showing an app open ad. Won't show ad.");
				appOpenAdManager.appHasResumedAfterShowing = true; // Show upon next app resumption
			}
		} else {
			Log.d(LOG_TAG, "App has resumed, but autoShowOnResume is false. Not showing app open ad.");
		}
	}


	void emitGodotSignal(String signalName, Object... arguments) {
		emitSignal(signalName, arguments);
	}
}
