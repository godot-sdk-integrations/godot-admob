//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;

import org.godotengine.plugin.admob.model.AdmobAdInfo;
import org.godotengine.plugin.admob.model.LoadAdRequest;

interface InterstitialListener {
	void onInterstitialLoaded(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onInterstitialReloaded(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onInterstitialFailedToLoad(AdmobAdInfo adInfo, LoadAdError loadAdError);
	void onInterstitialFailedToShow(AdmobAdInfo adInfo, AdError adError);
	void onInterstitialOpened(AdmobAdInfo adInfo);
	void onInterstitialClosed(AdmobAdInfo adInfo);
	void onInterstitialClicked(AdmobAdInfo adInfo);
	void onInterstitialImpression(AdmobAdInfo adInfo);
}

public class Interstitial {
	private static final String CLASS_NAME = Interstitial.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private AdmobAdInfo adInfo;
	private final String adId;
	private final LoadAdRequest loadRequest;
	private final Activity activity;
	private final InterstitialListener listener;

	private InterstitialAd interstitialAd = null;

	boolean firstLoad;

	Interstitial(AdmobAdInfo adInfo, final Activity activity, final InterstitialListener listener) {
		this.adInfo = adInfo;
		this.adId = adInfo.getAdId();
		this.loadRequest = adInfo.getLoadAdRequest();

		this.activity = activity;
		this.listener = listener;
		this.firstLoad = true;
	}

	void load() {
		activity.runOnUiThread(() -> {
			InterstitialAd.load(activity, loadRequest.getAdUnitId(), loadRequest.createAdRequest(),
					new InterstitialAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull InterstitialAd interstitialAd) {
					super.onAdLoaded(interstitialAd);
					setAd(interstitialAd);
					if (firstLoad) {
						Log.i(LOG_TAG, "interstitial ad loaded");
						firstLoad = false;
						listener.onInterstitialLoaded(Interstitial.this.adInfo, interstitialAd.getResponseInfo());
					}
					else {
						Log.i(LOG_TAG, "interstitial ad refreshed");
						listener.onInterstitialReloaded(Interstitial.this.adInfo, interstitialAd.getResponseInfo());
					}
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					super.onAdFailedToLoad(loadAdError);
					setAd(null);	// safety
					Log.e(LOG_TAG, "interstitial ad failed to load - error code: " + loadAdError.getCode());
					listener.onInterstitialFailedToLoad(Interstitial.this.adInfo, loadAdError);
				}
			});
		});
	}

	void show() {
		if (interstitialAd != null) {
			activity.runOnUiThread(() -> {
				Window window = activity.getWindow();

				// Force Layout No Limits prevents the system from forcing the window within safe areas (cutouts/bars)
				window.setFlags(
					WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
					WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
				);

				// Handle Display Cutout (API 28+) - explicitly allow drawing into the cutout area.
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
					WindowManager.LayoutParams layoutParams = window.getAttributes();
					layoutParams.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
					window.setAttributes(layoutParams);
				}

				// Use WindowCompat for Immersive Mode (API agnostic)
				WindowCompat.setDecorFitsSystemWindows(window, false);
				WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());
				if (controller != null) {
					// Hide system bars (status bar and navigation bar)
					controller.hide(WindowInsetsCompat.Type.systemBars());
					// Allow swipe to temporarily show bars
					controller.setSystemBarsBehavior(WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
				}

				// Post the show call to the next UI loop to give the WindowManager time to apply the attribute changes
				// before the AdMob SDK captures the window state
				new Handler(Looper.getMainLooper()).post(() -> {
					if (interstitialAd != null) {
						interstitialAd.show(activity);
					}
				});
			});
		} else {
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
						listener.onInterstitialClicked(Interstitial.this.adInfo);
					}

					@Override
					public void onAdDismissedFullScreenContent() {
						super.onAdDismissedFullScreenContent();
						setAd(null);
						Log.i(LOG_TAG, "interstitial ad dismissed full screen content");
						listener.onInterstitialClosed(Interstitial.this.adInfo);
						load();
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						super.onAdFailedToShowFullScreenContent(adError);
						Log.e(LOG_TAG, "interstitial ad failed to show full screen content");
						listener.onInterstitialFailedToShow(Interstitial.this.adInfo, adError);
					}

					@Override
					public void onAdShowedFullScreenContent() {
						super.onAdShowedFullScreenContent();
						Log.i(LOG_TAG, "interstitial ad showed full screen content");
						listener.onInterstitialOpened(Interstitial.this.adInfo);
					}

					@Override
					public void onAdImpression() {
						super.onAdImpression();
						Log.i(LOG_TAG, "interstitial ad impression");
						listener.onInterstitialImpression(Interstitial.this.adInfo);
					}
				});
			}

			this.interstitialAd = interstitialAd;
		}
	}
}
