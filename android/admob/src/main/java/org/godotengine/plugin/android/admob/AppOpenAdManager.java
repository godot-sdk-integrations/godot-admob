//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.util.Log;

import androidx.annotation.NonNull;

import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.appopen.AppOpenAd;
import com.google.android.gms.ads.appopen.AppOpenAd.AppOpenAdLoadCallback;

import java.util.Date;


public class AppOpenAdManager implements DefaultLifecycleObserver {
	private static final String LOG_TAG = AdmobPlugin.LOG_TAG + "::" + AppOpenAdManager.class.getSimpleName();

	private static final int AD_LIFETIME_HOURS = 4;
	private static final long ONE_HOUR_IN_MILLISECONDS = 3600000L;

	public boolean autoShowOnResume;
	public boolean isLoadingAd;
	public boolean isShowingAd;
	public boolean appHasResumedAfterShowing;

	private AdmobPlugin plugin;

	private String adUnitId;
	private AppOpenAd appOpenAd;
	private long loadTime;

	public AppOpenAdManager(AdmobPlugin plugin) {
		this.plugin = plugin;
		this.appOpenAd = null;
		this.autoShowOnResume = false;
		this.isLoadingAd = false;
		this.isShowingAd = false;
		this.appHasResumedAfterShowing = true;
		this.loadTime = 0L;
	}

	public void loadAd(String adUnitId) {
		this.adUnitId = adUnitId;

		if (isLoadingAd) {
			Log.e(LOG_TAG, "Cannot load app open ad: loading already in progress");
		} else if (isAdAvailable()) {
			Log.e(LOG_TAG, "Cannot load app open ad: already loaded");
			isLoadingAd = false;
		} else if (this.plugin.activity == null) {
			Log.e(LOG_TAG, "Cannot load app open ad: activity is null");
			isLoadingAd = false;
		} else if (this.plugin.activity.isFinishing()) {
			Log.e(LOG_TAG, "Cannot load app open ad: activity is finishing");
			isLoadingAd = false;
		} else {
			isLoadingAd = true;
			Log.d(LOG_TAG, "Loading app open ad: " + adUnitId);
			this.plugin.activity.runOnUiThread(() -> {
				AdRequest request = new AdRequest.Builder().build();
				AppOpenAd.load(AppOpenAdManager.this.plugin.activity, adUnitId, request, new AppOpenAdLoadCallback() {
					@Override
					public void onAdLoaded(@NonNull AppOpenAd ad) {
						Log.d(LOG_TAG, "App open ad loaded.");
						appOpenAd = ad;
						isLoadingAd = false;
						loadTime = (new Date()).getTime();
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_LOADED, ad.getAdUnitId());
					}

					@Override
					public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
						Log.e(LOG_TAG, "App open ad failed to load: " + loadAdError.getMessage());
						isLoadingAd = false;
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_FAILED_TO_LOAD, AppOpenAdManager.this.adUnitId, GodotConverter.convert(loadAdError));
					}
				});
			});
		}
	}

	public void showAd() {
		if (isShowingAd) {
			Log.d(LOG_TAG, "Cannot show app open ad: The app open ad is already showing.");
		} else if (!isAdAvailable()) {
			Log.d(LOG_TAG, "Cannot show app open ad: The app open ad is not ready yet.");
		} else {
			this.plugin.activity.runOnUiThread(() -> {
				appOpenAd.setFullScreenContentCallback(new FullScreenContentCallback() {
					@Override
					public void onAdDismissedFullScreenContent() {
						Log.d(LOG_TAG, "App open ad dismissed fullscreen content.");
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_DISMISSED_FULL_SCREEN_CONTENT, appOpenAd.getAdUnitId());
						isShowingAd = false;
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						Log.e(LOG_TAG, "App open ad failed to show fullscreen content: " + adError.getMessage());
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT, appOpenAd.getAdUnitId(), GodotConverter.convert(adError));
						appOpenAd = null;
						isShowingAd = false;
					}

					@Override
					public void onAdShowedFullScreenContent() {
						Log.d(LOG_TAG, "App open ad showed fullscreen content.");
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_SHOWED_FULL_SCREEN_CONTENT, appOpenAd.getAdUnitId());
						appOpenAd = null;
						appHasResumedAfterShowing = false;
					}

					@Override
					public void onAdImpression() {
						Log.d(LOG_TAG, "App open ad recorded an impression.");
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_IMPRESSION, appOpenAd.getAdUnitId());
						appOpenAd = null;
						appHasResumedAfterShowing = false;
					}

					@Override
					public void onAdClicked() {
						Log.d(LOG_TAG, "App open ad was clicked.");
						AppOpenAdManager.this.plugin.emitGodotSignal(AdmobPlugin.SIGNAL_APP_OPEN_AD_CLICKED, appOpenAd.getAdUnitId());
					}
				});

				if (this.plugin.activity == null || this.plugin.activity.isFinishing()) {
					Log.w(LOG_TAG, "Cannot show ad: invalid activity");
				} else {
					Log.d(LOG_TAG, "Showing app open ad.");
					isShowingAd = true;
					appOpenAd.show(this.plugin.activity);
				}
			});
		}
	}

	private boolean wasLoadTimeLessThanNHoursAgo(long numHours) {
		long dateDifference = (new Date()).getTime() - loadTime;
		return (dateDifference < (ONE_HOUR_IN_MILLISECONDS * numHours));
	}

	public boolean isAdAvailable() {
		return appOpenAd != null && wasLoadTimeLessThanNHoursAgo(AD_LIFETIME_HOURS);
	}

	@Override
	public void onStart(@NonNull LifecycleOwner owner) {
		// Optionally show on foreground, but we'll use Godot's onMainResume instead
	}
}
