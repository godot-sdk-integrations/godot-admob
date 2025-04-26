//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;

interface InterstitialListener {
	void onInterstitialLoaded(String adId);
	void onInterstitialReloaded(String adId);
	void onInterstitialFailedToLoad(String adId, LoadAdError loadAdError);
	void onInterstitialFailedToShow(String adId, AdError adError);
	void onInterstitialOpened(String adId);
	void onInterstitialClosed(String adId);
	void onInterstitialClicked(String adId);
	void onInterstitialImpression(String adId);
}

public class Interstitial {
	private static final String CLASS_NAME = Interstitial.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private final String adId;
	private final String adUnitId;
	private final AdRequest adRequest;
	private final Activity activity;
	private final InterstitialListener listener;

	private InterstitialAd interstitialAd = null;

	boolean firstLoad;

	Interstitial(final String adId, final String adUnitId, final AdRequest adRequest, final Activity activity,
				final InterstitialListener listener) {
		this.adId = adId;
		this.adUnitId = adUnitId;
		this.adRequest = adRequest;
		this.activity = activity;
		this.listener = listener;
		this.firstLoad = true;
	}

	void show() {
		if (interstitialAd != null) {
			interstitialAd.show(activity);
		}
		else {
			Log.w(LOG_TAG, "show(): interstitial not loaded");
		}
	}

	private void setAd(InterstitialAd interstitialAd) {
		if (interstitialAd == this.interstitialAd) {
			Log.w(LOG_TAG, "setAd(): interstitial already set");
		}
		else {
			// Avoid memory leaks
			if (this.interstitialAd != null) {
				this.interstitialAd.setFullScreenContentCallback(null);
				this.interstitialAd.setOnPaidEventListener(null);
			}

			if (interstitialAd != null) {
				interstitialAd.setFullScreenContentCallback(new FullScreenContentCallback() {
					@Override
					public void onAdClicked() {
						super.onAdClicked();
						Log.i(LOG_TAG, "interstitial ad clicked");
						listener.onInterstitialClicked(Interstitial.this.adId);
					}

					@Override
					public void onAdDismissedFullScreenContent() {
						super.onAdDismissedFullScreenContent();
						setAd(null);
						Log.w(LOG_TAG, "interstitial ad dismissed full screen content");
						listener.onInterstitialClosed(Interstitial.this.adId);
						load();
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						super.onAdFailedToShowFullScreenContent(adError);
						Log.e(LOG_TAG, "interstitial ad failed to show full screen content");
						listener.onInterstitialFailedToShow(Interstitial.this.adId, adError);
					}

					@Override
					public void onAdShowedFullScreenContent() {
						super.onAdShowedFullScreenContent();
						Log.i(LOG_TAG, "interstitial ad showed full screen content");
						listener.onInterstitialOpened(Interstitial.this.adId);
					}

					@Override
					public void onAdImpression() {
						super.onAdImpression();
						Log.i(LOG_TAG, "interstitial ad impression");
						listener.onInterstitialImpression(Interstitial.this.adId);
					}
				});
			}

			this.interstitialAd = interstitialAd;
		}
	}

	void load() {
		InterstitialAd.load(activity, adUnitId, adRequest, new InterstitialAdLoadCallback() {
			@Override
			public void onAdLoaded(@NonNull InterstitialAd interstitialAd) {
				super.onAdLoaded(interstitialAd);
				setAd(interstitialAd);
				if (firstLoad) {
					Log.i(LOG_TAG, "interstitial ad loaded");
					firstLoad = false;
					listener.onInterstitialLoaded(Interstitial.this.adId);
				}
				else {
					Log.i(LOG_TAG, "interstitial ad refreshed");
					listener.onInterstitialReloaded(Interstitial.this.adId);
				}
			}

			@Override
			public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
				super.onAdFailedToLoad(loadAdError);
				setAd(null);	// safety
				Log.e(LOG_TAG, "interstitial ad failed to load - error code: " + loadAdError.getCode());
				listener.onInterstitialFailedToLoad(Interstitial.this.adId, loadAdError);
			}
		});
	}
}
