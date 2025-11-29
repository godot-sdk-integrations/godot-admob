//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.appopen.AppOpenAd;
import com.google.android.gms.ads.appopen.AppOpenAd.AppOpenAdLoadCallback;

import java.util.Date;

import org.godotengine.plugin.admob.model.LoadAdRequest;


interface AppOpenListener {
	void onAdLoaded(String adUnitId, ResponseInfo responseInfo);
	void onAdFailedToLoad(String adUnitId, LoadAdError loadAdError);
	void onAdShowed(String adUnitId);
	void onAdFailedToShow(String adUnitId, AdError adError);
	void onAdImpression(String adUnitId);
	void onAdClicked(String adUnitId);
	void onAdClosed(String adUnitId);
}


public class AppOpenAdManager implements DefaultLifecycleObserver {
	private static final String LOG_TAG = AdmobPlugin.LOG_TAG + "::" + AppOpenAdManager.class.getSimpleName();

	private static final int AD_LIFETIME_HOURS = 4;
	private static final long ONE_HOUR_IN_MILLISECONDS = 3600000L;

	public boolean autoShowOnResume;
	public boolean isLoadingAd;
	public boolean isShowingAd;

	private Activity activity;
	private AppOpenListener listener;

	private String adUnitId;
	private AppOpenAd appOpenAd;
	private long loadTime;

	public AppOpenAdManager(Activity activity, AppOpenListener listener) {
		this.activity = activity;
		this.listener = listener;
		this.appOpenAd = null;
		this.autoShowOnResume = false;
		this.isLoadingAd = false;
		this.isShowingAd = false;
		this.loadTime = 0L;
	}

	public void loadAd(LoadAdRequest loadAdRequest) {
		this.adUnitId = loadAdRequest.getAdUnitId();

		if (isLoadingAd) {
			Log.e(LOG_TAG, "Cannot load app open ad: loading already in progress");
		} else if (isAdAvailable()) {
			Log.e(LOG_TAG, "Cannot load app open ad: already loaded");
			isLoadingAd = false;
		} else if (this.activity == null) {
			Log.e(LOG_TAG, "Cannot load app open ad: activity is null");
			isLoadingAd = false;
		} else if (this.activity.isFinishing()) {
			Log.e(LOG_TAG, "Cannot load app open ad: activity is finishing");
			isLoadingAd = false;
		} else {
			isLoadingAd = true;
			Log.d(LOG_TAG, "Loading app open ad: " + adUnitId);
			this.activity.runOnUiThread(() -> {
				AdRequest request = loadAdRequest.createAdRequest();
				AppOpenAd.load(AppOpenAdManager.this.activity, adUnitId, request, new AppOpenAdLoadCallback() {
					@Override
					public void onAdLoaded(@NonNull AppOpenAd ad) {
						Log.d(LOG_TAG, "App open ad loaded.");
						appOpenAd = ad;
						isLoadingAd = false;
						loadTime = (new Date()).getTime();
						AppOpenAdManager.this.listener.onAdLoaded(ad.getAdUnitId(), ad.getResponseInfo());
					}

					@Override
					public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
						Log.e(LOG_TAG, "App open ad failed to load: " + loadAdError.getMessage());
						isLoadingAd = false;
						AppOpenAdManager.this.listener.onAdFailedToLoad(AppOpenAdManager.this.adUnitId, loadAdError);
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
			this.activity.runOnUiThread(() -> {
				appOpenAd.setFullScreenContentCallback(new FullScreenContentCallback() {
					@Override
					public void onAdDismissedFullScreenContent() {
						Log.d(LOG_TAG, "App open ad dismissed fullscreen content.");
						AppOpenAdManager.this.listener.onAdClosed(AppOpenAdManager.this.adUnitId);
						AppOpenAdManager.this.isShowingAd = false;
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						Log.e(LOG_TAG, "App open ad failed to show fullscreen content: " + adError.getMessage());
						AppOpenAdManager.this.listener.onAdFailedToShow(AppOpenAdManager.this.adUnitId, adError);
						AppOpenAdManager.this.appOpenAd = null;
					}

					@Override
					public void onAdShowedFullScreenContent() {
						Log.d(LOG_TAG, "App open ad showed fullscreen content.");
						AppOpenAdManager.this.listener.onAdShowed(AppOpenAdManager.this.adUnitId);
						AppOpenAdManager.this.appOpenAd = null;
						AppOpenAdManager.this.isShowingAd = true;
					}

					@Override
					public void onAdImpression() {
						Log.d(LOG_TAG, "App open ad recorded an impression.");
						AppOpenAdManager.this.listener.onAdImpression(AppOpenAdManager.this.adUnitId);
						AppOpenAdManager.this.appOpenAd = null;
						AppOpenAdManager.this.isShowingAd = true;
					}

					@Override
					public void onAdClicked() {
						Log.d(LOG_TAG, "App open ad was clicked.");
						AppOpenAdManager.this.listener.onAdClicked(AppOpenAdManager.this.adUnitId);
					}
				});

				if (this.activity == null || this.activity.isFinishing()) {
					Log.w(LOG_TAG, "Cannot show ad: invalid activity");
				} else {
					Log.d(LOG_TAG, "Showing app open ad.");
					appOpenAd.show(this.activity);
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
		Log.i(LOG_TAG, "App moved to foreground");
		if (autoShowOnResume) {
			Log.d(LOG_TAG, "App has resumed and autoShowOnResume is true. Attempting to show app open ad.");

			// Wait for app to be moved to foreground
			new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
				@Override
				public void run() {
					showAd();
				}
			}, 100); // Delay in milliseconds
		} else {
			Log.d(LOG_TAG, "App has resumed, but autoShowOnResume is false. Not showing app open ad.");
		}
	}

	@Override
	public void onStop(@NonNull LifecycleOwner owner) {
		Log.i(LOG_TAG, "App moved to background");
	}
}
