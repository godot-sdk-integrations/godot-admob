//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.collection.ArraySet;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions;
import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentForm;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.FormError;
import com.google.android.ump.UserMessagingPlatform;

import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class AdmobPlugin extends GodotPlugin {
	static final String CLASS_NAME = AdmobPlugin.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + CLASS_NAME;

	private static final String SIGNAL_INITIALIZATION_COMPLETED = "initialization_completed";
	private static final String SIGNAL_BANNER_AD_LOADED = "banner_ad_loaded";
	private static final String SIGNAL_BANNER_AD_FAILED_TO_LOAD = "banner_ad_failed_to_load";
	private static final String SIGNAL_BANNER_AD_REFRESHED = "banner_ad_refreshed";
	private static final String SIGNAL_BANNER_AD_IMPRESSION = "banner_ad_impression";
	private static final String SIGNAL_BANNER_AD_CLICKED = "banner_ad_clicked";
	private static final String SIGNAL_BANNER_AD_OPENED = "banner_ad_opened";
	private static final String SIGNAL_BANNER_AD_CLOSED = "banner_ad_closed";
	private static final String SIGNAL_INTERSTITIAL_AD_LOADED = "interstitial_ad_loaded";
	private static final String SIGNAL_INTERSTITIAL_AD_FAILED_TO_LOAD = "interstitial_ad_failed_to_load";
	private static final String SIGNAL_INTERSTITIAL_AD_REFRESHED = "interstitial_ad_refreshed";
	private static final String SIGNAL_INTERSTITIAL_AD_IMPRESSION = "interstitial_ad_impression";
	private static final String SIGNAL_INTERSTITIAL_AD_CLICKED = "interstitial_ad_clicked";
	private static final String SIGNAL_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT = "interstitial_ad_showed_full_screen_content";
	private static final String SIGNAL_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "interstitial_ad_failed_to_show_full_screen_content";
	private static final String SIGNAL_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT = "interstitial_ad_dismissed_full_screen_content";
	private static final String SIGNAL_REWARDED_AD_LOADED = "rewarded_ad_loaded";
	private static final String SIGNAL_REWARDED_AD_FAILED_TO_LOAD = "rewarded_ad_failed_to_load";
	private static final String SIGNAL_REWARDED_AD_IMPRESSION = "rewarded_ad_impression";
	private static final String SIGNAL_REWARDED_AD_CLICKED = "rewarded_ad_clicked";
	private static final String SIGNAL_REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT = "rewarded_ad_showed_full_screen_content";
	private static final String SIGNAL_REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "rewarded_ad_failed_to_show_full_screen_content";
	private static final String SIGNAL_REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT = "rewarded_ad_dismissed_full_screen_content";
	private static final String SIGNAL_REWARDED_AD_USER_EARNED_REWARD = "rewarded_ad_user_earned_reward";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_LOADED = "rewarded_interstitial_ad_loaded";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD = "rewarded_interstitial_ad_failed_to_load";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_IMPRESSION = "rewarded_interstitial_ad_impression";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_CLICKED = "rewarded_interstitial_ad_clicked";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT = "rewarded_interstitial_ad_showed_full_screen_content";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT = "rewarded_interstitial_ad_failed_to_show_full_screen_content";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT = "rewarded_interstitial_ad_dismissed_full_screen_content";
	private static final String SIGNAL_REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD = "rewarded_interstitial_ad_user_earned_reward";
	private static final String SIGNAL_CONSENT_FORM_LOADED = "consent_form_loaded";
	private static final String SIGNAL_CONSENT_FORM_FAILED_TO_LOAD = "consent_form_failed_to_load";
	private static final String SIGNAL_CONSENT_FORM_DISMISSED = "consent_form_dismissed";
	private static final String SIGNAL_CONSENT_INFO_UPDATED = "consent_info_updated";
	private static final String SIGNAL_CONSENT_INFO_UPDATE_FAILED = "consent_info_update_failed";

	private Activity activity;

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

	private ConsentForm consentForm;


	public AdmobPlugin(Godot godot) {
		super(godot);

		bannerAds = new HashMap<>();
		interstitialAds = new HashMap<>();
		rewardedAds = new HashMap<>();
		rewardedInterstitialAds = new HashMap<>();

		isInitialized = false;
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

		signals.add(new SignalInfo(SIGNAL_BANNER_AD_LOADED, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_REFRESHED, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_OPENED, String.class));
		signals.add(new SignalInfo(SIGNAL_BANNER_AD_CLOSED, String.class));
		
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_LOADED, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_REFRESHED, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));
		
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_LOADED, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_AD_USER_EARNED_REWARD, String.class, Dictionary.class));
		
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_LOADED, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_IMPRESSION, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_CLICKED, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, String.class, Dictionary.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT, String.class));
		signals.add(new SignalInfo(SIGNAL_REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD, String.class, Dictionary.class));
		
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

		MobileAds.initialize(activity, new OnInitializationCompleteListener() {
			@Override
			public void onInitializationComplete(InitializationStatus initializationStatus) {
				isInitialized = true;
				emitSignal(SIGNAL_INITIALIZATION_COMPLETED, convert(initializationStatus));
			}
		});
	}

	@UsedByGodot
	public void set_request_configuration(Dictionary configData) {
		Log.d(LOG_TAG, "set_request_configuration()");
		MobileAds.setRequestConfiguration(createRequestConfiguration(configData));
	}

	@UsedByGodot
	public Dictionary get_initialization_status() {
		Log.d(LOG_TAG, "get_initialization_status()");
		return convert(MobileAds.getInitializationStatus());
	}

	@UsedByGodot
	public Dictionary get_current_adaptive_banner_size(int width) {
		Log.d(LOG_TAG, "get_current_adaptive_banner_size()");
		int currentWidth = (width == AdSize.FULL_WIDTH) ? Banner.getAdWidth(activity) : width;
		return convert(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, currentWidth));
	}

	@UsedByGodot
	public Dictionary get_portrait_adaptive_banner_size(int width) {
		Log.d(LOG_TAG, "get_portrait_adaptive_banner_size()");
		int currentWidth = (width == AdSize.FULL_WIDTH) ? Banner.getAdWidth(activity) : width;
		return convert(AdSize.getPortraitAnchoredAdaptiveBannerAdSize(activity, currentWidth));
	}

	@UsedByGodot
	public Dictionary get_landscape_adaptive_banner_size(int width) {
		Log.d(LOG_TAG, "get_landscape_adaptive_banner_size()");
		int currentWidth = (width == AdSize.FULL_WIDTH) ? Banner.getAdWidth(activity) : width;
		return convert(AdSize.getLandscapeAnchoredAdaptiveBannerAdSize(activity, currentWidth));
	}

	@UsedByGodot
	public void load_banner_ad(Dictionary adData) {
		if (isInitialized) {
			Log.d(LOG_TAG, "load_banner_ad()");

			if (adData.containsKey("ad_unit_id")) {
				String adUnitId = (String) adData.get("ad_unit_id");
				String adId = String.format("%s-%d", adUnitId, ++bannerAdIdSequence);
				Banner banner = new Banner(adId, adUnitId, adData, createAdRequest(adData), activity, layout,
						new BannerListener() {
							@Override
							public void onAdLoaded(String adId) {
								emitSignal(SIGNAL_BANNER_AD_LOADED, adId);
							}

							@Override
							public void onAdRefreshed(String adId) {
								Log.d(LOG_TAG, String.format("onAdRefreshed(%s) banner", adId));
								emitSignal(SIGNAL_BANNER_AD_REFRESHED, adId);
							}

							@Override
							public void onAdFailedToLoad(String adId, LoadAdError adError) {
								emitSignal(SIGNAL_BANNER_AD_FAILED_TO_LOAD, adId, convert(adError));
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
				activity.runOnUiThread(() -> {
					banner.load();
				});
			} else {
				Log.e(LOG_TAG, "load_banner_ad(): Error: Ad unit id is required!");
			}
		}
		else {
				Log.e(LOG_TAG, "load_banner_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_banner_ad(String adId) {
		activity.runOnUiThread(() -> {
			if (bannerAds.containsKey(adId)) {
				Log.d(LOG_TAG, String.format("show_banner_ad(): %s", adId));
				Banner bannerAd = bannerAds.get(adId);
				bannerAd.show();
			}
			else {
				Log.e(LOG_TAG, String.format("show_banner_ad(): Error: banner ad %s not found", adId));
			}
		});
	}

	@UsedByGodot
	public void hide_banner_ad(String adId) {
		activity.runOnUiThread(() -> {
			if (bannerAds.containsKey(adId)) {
				Log.d(LOG_TAG, String.format("hide_banner_ad(): %s", adId));
				Banner bannerAd = bannerAds.get(adId);
				bannerAd.hide();
			}
			else {
				Log.e(LOG_TAG, String.format("hide_banner_ad(): Error: banner ad %s not found", adId));
			}
		});
	}

	@UsedByGodot
	public void remove_banner_ad(String adId) {
		activity.runOnUiThread(() -> {
			if (bannerAds.containsKey(adId)) {
				Log.d(LOG_TAG, String.format("remove_banner_ad(): %s", adId));
				Banner bannerAd = bannerAds.remove(adId);
				bannerAd.remove();
			}
			else {
				Log.e(LOG_TAG, String.format("remove_banner_ad(): Error: banner ad %s not found", adId));
			}
		});
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

			if (adData.containsKey("ad_unit_id")) {
				String adUnitId = (String) adData.get("ad_unit_id");
				String adId = String.format("%s-%d", adUnitId, ++interstitialAdIdSequence);

				activity.runOnUiThread(() -> {
					Interstitial ad = new Interstitial(adId, adUnitId, createAdRequest(adData), activity, new InterstitialListener() {
						@Override
						public void onInterstitialLoaded(String adId) {
							emitSignal(SIGNAL_INTERSTITIAL_AD_LOADED, adId);
						}

						@Override
						public void onInterstitialReloaded(String adId) {
							emitSignal(SIGNAL_INTERSTITIAL_AD_REFRESHED, adId);
						}

						@Override
						public void onInterstitialFailedToLoad(String adId, LoadAdError loadAdError) {
							emitSignal(SIGNAL_INTERSTITIAL_AD_FAILED_TO_LOAD, adId, convert(loadAdError));
						}

						@Override
						public void onInterstitialFailedToShow(String adId, AdError adError) {
							emitSignal(SIGNAL_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, adId, convert(adError));
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
				});
			} else {
				Log.e(LOG_TAG, "load_interstitial_ad(): Error: Ad unit id is required!");
			}
		}
		else {
			Log.e(LOG_TAG, "load_interstitial_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_interstitial_ad(String adId) {
		activity.runOnUiThread(() -> {
			if (interstitialAds.containsKey(adId)) {
				Log.d(LOG_TAG, String.format("show_interstitial_ad(): %s", adId));
				Interstitial ad = interstitialAds.get(adId);
				assert ad != null;
				ad.show();
			}
			else {
				Log.e(LOG_TAG, String.format("show_interstitial_ad(): Error: ad %s not found", adId));
			}
		});
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

			if (adData.containsKey("ad_unit_id")) {
				String adUnitId = (String) adData.get("ad_unit_id");
				String adId = String.format("%s-%d", adUnitId, ++rewardedAdIdSequence);

				activity.runOnUiThread(() -> {
					RewardedVideo ad = new RewardedVideo(adId, adUnitId, createAdRequest(adData), activity, new RewardedVideoListener() {
						@Override
						public void onRewardedVideoLoaded(String adId) {
							emitSignal(SIGNAL_REWARDED_AD_LOADED, adId);
						}

						@Override
						public void onRewardedVideoFailedToLoad(String adId, LoadAdError loadAdError) {
							emitSignal(SIGNAL_REWARDED_AD_FAILED_TO_LOAD, adId, convert(loadAdError));
						}

						@Override
						public void onRewardedVideoOpened(String adId) {
							emitSignal(SIGNAL_REWARDED_AD_SHOWED_FULL_SCREEN_CONTENT, adId);
						}

						@Override
						public void onRewardedVideoFailedToShow(String adId, AdError adError) {
							emitSignal(SIGNAL_REWARDED_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, adId, convert(adError));
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
							emitSignal(SIGNAL_REWARDED_AD_USER_EARNED_REWARD, adId, convert(reward));
						}
					});
					ad.setServerSideVerificationOptions(createSSVO(adData));
					rewardedAds.put(adId, ad);
					Log.d(LOG_TAG, String.format("load_rewarded_ad(): %s", adId));
					ad.load();
				});
			} else {
				Log.e(LOG_TAG, "load_rewarded_ad(): Error: Ad unit id is required!");
			}
		}
		else {
				Log.e(LOG_TAG, "load_rewarded_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_rewarded_ad(String adId) {
		activity.runOnUiThread(() -> {
			if (rewardedAds.containsKey(adId)) {
				Log.d(LOG_TAG, String.format("show_rewarded_ad(): %s", adId));
				RewardedVideo ad = rewardedAds.get(adId);
				ad.show();
			}
			else {
				Log.e(LOG_TAG, String.format("show_rewarded_ad(): Error: ad %s not found", adId));
			}
		});
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

			if (adData.containsKey("ad_unit_id")) {
				String adUnitId = (String) adData.get("ad_unit_id");
				String adId = String.format("%s-%d", adUnitId, ++rewardedInterstitialAdIdSequence);

				activity.runOnUiThread(() -> {
					RewardedInterstitial ad = new RewardedInterstitial(adId, adUnitId, createAdRequest(adData), activity,
							new RewardedInterstitialListener() {
								@Override
								public void onRewardedInterstitialLoaded(String adId) {
									emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_LOADED, adId);
								}

								@Override
								public void onRewardedInterstitialFailedToLoad(String adId, LoadAdError loadAdError) {
									emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_LOAD, adId, convert(loadAdError));
								}

								@Override
								public void onRewardedInterstitialOpened(String adId) {
									emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT, adId);
								}

								@Override
								public void onRewardedInterstitialFailedToShow(String adId, AdError adError) {
									emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, adId, convert(adError));
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
									emitSignal(SIGNAL_REWARDED_INTERSTITIAL_AD_USER_EARNED_REWARD, adId, convert(reward));
								}
							});
					ad.setServerSideVerificationOptions(createSSVO(adData));
					rewardedInterstitialAds.put(adId, ad);
					Log.d(LOG_TAG, String.format("load_rewarded_interstitial_ad(): %s", adId));
					ad.load();
				});
			} else {
				Log.e(LOG_TAG, "load_rewarded_interstitial_ad(): Error: Ad unit id is required!");
			}
		}
		else {
			Log.e(LOG_TAG, "load_rewarded_interstitial_ad(): Error: Plugin is not initialized!");
		}
	}

	@UsedByGodot
	public void show_rewarded_interstitial_ad(String adId) {
		activity.runOnUiThread(() -> {
			if (rewardedInterstitialAds.containsKey(adId)) {
				Log.d(LOG_TAG, String.format("show_rewarded_interstitial_ad(): %s", adId));
				RewardedInterstitial ad = rewardedInterstitialAds.get(adId);
				ad.show();
			} else {
				Log.e(LOG_TAG, String.format("show_rewarded_interstitial_ad(): Error: ad %s not found", adId));
			}
		});
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
					emitSignal(SIGNAL_CONSENT_FORM_FAILED_TO_LOAD, convert(formError));
				}
			);
		});
	}

	@UsedByGodot
	public void show_consent_form() {
		activity.runOnUiThread(() -> {
			if (consentForm == null) {
				Log.e(LOG_TAG, "show_consent_form(): Error: consent form not found!");
			} else {
				Log.d(LOG_TAG, "show_consent_form()");
				consentForm.show(activity, (ConsentForm.OnConsentFormDismissedListener) formError -> {
					emitSignal(SIGNAL_CONSENT_FORM_DISMISSED, convert(formError));
				});
			}
		});
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
			createConsentRequestParameters(consentRequestParameters),
			(ConsentInformation.OnConsentInfoUpdateSuccessListener) () -> {
				emitSignal(SIGNAL_CONSENT_INFO_UPDATED);
			},
			(ConsentInformation.OnConsentInfoUpdateFailureListener) requestConsentError -> {
				emitSignal(SIGNAL_CONSENT_INFO_UPDATE_FAILED, convert(requestConsentError));
				Log.w(LOG_TAG, String.format("%s: %s", requestConsentError.getErrorCode(), requestConsentError.getMessage()));
			}
		);
	}

	@UsedByGodot
	public void reset_consent_info() {
		Log.d(LOG_TAG, "reset_consent_info()");
		UserMessagingPlatform.getConsentInformation(activity).reset();
	}


	@Override
	public View onMainCreate(Activity activity) {
		this.activity = activity;
		this.activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING);
		this.layout = new FrameLayout(activity); // create and add a new layout to Godot
		return layout;
	}


	private Dictionary convert(InitializationStatus initializationStatus) {
		Dictionary dict = new Dictionary();

		Map<String, AdapterStatus> adapterMap = initializationStatus.getAdapterStatusMap();
		for (String adapterClass : adapterMap.keySet()) {
			AdapterStatus adapterStatus = adapterMap.get(adapterClass);

			Dictionary statusDict = new Dictionary();
			statusDict.put("latency", adapterStatus.getLatency());
			statusDict.put("initializationState", adapterStatus.getInitializationState());
			statusDict.put("description", adapterStatus.getDescription());

			dict.put(adapterClass, statusDict);
		}

		return dict;
	}

	private Dictionary convert(AdSize size) {
		Dictionary dict = new Dictionary();

		dict.put("width", size.getWidth());
		dict.put("height", size.getHeight());

		return dict;
	}

	private Dictionary convert(AdError error) {
		Dictionary dict = new Dictionary();

		dict.put("code", error.getCode());
		dict.put("domain", error.getDomain());
		dict.put("message", error.getMessage());
		dict.put("cause", error.getCause() == null ? new Dictionary() : convert(error.getCause()));

		return dict;
	}

	private Dictionary convert(LoadAdError error) {
		Dictionary dict = convert((AdError) error);

		dict.put("response_info", error.getResponseInfo().toString());

		return dict;
	}

	private Dictionary convert(FormError error) {
		Dictionary dict = new Dictionary();

		if (error == null) {
			dict.put("code", 0);
			dict.put("message", "");
		} else {
			dict.put("code", error.getErrorCode());
			dict.put("message", error.getMessage());
		}

		return dict;
	}

	private Dictionary convert(RewardItem item) {
		Dictionary dict = new Dictionary();

		dict.put("amount", item.getAmount());
		dict.put("type", item.getType());

		return dict;
	}

	private RequestConfiguration createRequestConfiguration(Dictionary data) {
		RequestConfiguration.Builder builder = MobileAds.getRequestConfiguration().toBuilder();

		if (data.containsKey("max_ad_content_rating"))
			builder.setMaxAdContentRating((String) data.get("max_ad_content_rating"));

		if (data.containsKey("tag_for_child_directed_treatment"))
			builder.setTagForChildDirectedTreatment((int) data.get("tag_for_child_directed_treatment"));

		if (data.containsKey("tag_for_under_age_of_consent"))
			builder.setTagForUnderAgeOfConsent((int) data.get("tag_for_under_age_of_consent"));

		if (data.containsKey("personalization_state"))
			builder.setPublisherPrivacyPersonalizationState(getPublisherPrivacyPersonalizationState((int) data.get("personalization_state")));

		ArrayList<String> testDeviceIds = new ArrayList<>();
		if (data.containsKey("test_device_ids"))
			testDeviceIds.addAll(Arrays.asList((String[]) data.get("test_device_ids")));

		if (data.containsKey("is_real")) {
			if ((boolean) data.get("is_real") == false) {
				testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);
				testDeviceIds.add(getAdMobDeviceId());
			}
		}

		if (testDeviceIds.isEmpty() == false)
			builder.setTestDeviceIds(testDeviceIds);

		return builder.build();
	}

	private AdRequest createAdRequest(Dictionary data) {
		AdRequest.Builder builder = new AdRequest.Builder();

		if (data.containsKey("request_agent")) {
			String requestAgent = (String) data.get("request_agent");
			if (requestAgent != null && !requestAgent.isEmpty()) {
				builder.setRequestAgent(requestAgent);
			}
		}

		// TODO: mediation support

		if (data.containsKey("keywords")) {
			for (String keyword : (String[]) data.get("keywords")) {
				builder.addKeyword(keyword);
			}
		}

		return builder.build();
	}

	private ServerSideVerificationOptions createSSVO(Dictionary data) {
		ServerSideVerificationOptions.Builder builder = new ServerSideVerificationOptions.Builder();

		if (data.containsKey("custom_data")) {
			builder.setCustomData((String) data.get("custom_data"));
		}

		if (data.containsKey("user_id")) {
			builder.setUserId((String) data.get("user_id"));
		}

		return builder.build();
	}

	private ConsentRequestParameters createConsentRequestParameters(Dictionary data) {
		ConsentRequestParameters.Builder builder = new ConsentRequestParameters.Builder();

		if (data.containsKey("tag_for_under_age_of_consent")) {
			builder.setTagForUnderAgeOfConsent((boolean) data.get("tag_for_under_age_of_consent"));
		}

		if (data.containsKey("is_real") && (boolean) data.get("is_real") == false) {
			Log.d(LOG_TAG, "Creating debug settings for user consent.");
			ConsentDebugSettings.Builder debugSettingsBuilder = new ConsentDebugSettings.Builder(activity);

			if (data.containsKey("debug_geography")) {
				debugSettingsBuilder.setDebugGeography((int) data.get("debug_geography"));
			}

			debugSettingsBuilder.addTestDeviceHashedId(getAdMobDeviceId());

			builder.setConsentDebugSettings(debugSettingsBuilder.build());
		}

		return builder.build();
	}

	private RequestConfiguration.PublisherPrivacyPersonalizationState getPublisherPrivacyPersonalizationState(int intValue) {
		return switch (intValue) {
			case 1 -> RequestConfiguration.PublisherPrivacyPersonalizationState.ENABLED;
			case 2 -> RequestConfiguration.PublisherPrivacyPersonalizationState.DISABLED;
			default -> RequestConfiguration.PublisherPrivacyPersonalizationState.DEFAULT;
		};
	}

	/**
	 * Generate MD5 for the deviceID
	 *
	 * @param s The string for which to generate the MD5
	 * @return String The generated MD5
	 */
	private static String md5(final String s) {
		try {
			// Create MD5 Hash
			MessageDigest digest = MessageDigest.getInstance("MD5");
			digest.update(s.getBytes());
			byte[] messageDigest = digest.digest();

			// Create Hex String
			StringBuilder hexString = new StringBuilder();
			for (byte b : messageDigest) {
				StringBuilder h = new StringBuilder(Integer.toHexString(0xFF & b));
				while (h.length() < 2)
					h.insert(0, "0");
				hexString.append(h);
			}
			return hexString.toString();
		} catch (NoSuchAlgorithmException e) {
			Log.e(LOG_TAG, "md5() - no such algorithm");
		}
		return "";
	}

	/**
	 * Get the Device ID for AdMob
	 *
	 * @return String Device ID
	 */
	private String getAdMobDeviceId() {
		@SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
		return md5(androidId).toUpperCase(Locale.US);
	}
}
