//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd;
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback;

import org.godotengine.plugin.admob.model.AdmobAdInfo;
import org.godotengine.plugin.admob.model.LoadAdRequest;

interface RewardedInterstitialListener {
	void onRewardedInterstitialLoaded(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onRewardedInterstitialFailedToLoad(AdmobAdInfo adInfo, LoadAdError loadAdError);
	void onRewardedInterstitialOpened(AdmobAdInfo adInfo);
	void onRewardedInterstitialFailedToShow(AdmobAdInfo adInfo, AdError adError);
	void onRewardedInterstitialClosed(AdmobAdInfo adInfo);
	void onRewardedClicked(AdmobAdInfo adInfo);
	void onRewardedAdImpression(AdmobAdInfo adInfo);
	void onRewarded(AdmobAdInfo adInfo, RewardItem reward);
}

public class RewardedInterstitial {
	private static final String CLASS_NAME = RewardedInterstitial.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private AdmobAdInfo adInfo;
	private final String adId;
	private final LoadAdRequest loadRequest;
	private final Activity activity;
	private final RewardedInterstitialListener listener;

	private RewardedInterstitialAd rewardedAd;

	RewardedInterstitial(AdmobAdInfo adInfo, Activity activity, final RewardedInterstitialListener listener) {
		this.adInfo = adInfo;
		this.adId = adInfo.getAdId();
		this.loadRequest = adInfo.getLoadAdRequest();

		this.activity = activity;
		this.listener = listener;
		this.rewardedAd = null;
	}

	void load() {
		activity.runOnUiThread(() -> {
			RewardedInterstitialAd.load(activity, loadRequest.getAdUnitId(), loadRequest.createAdRequest(), new RewardedInterstitialAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull RewardedInterstitialAd rewardedAd) {
					super.onAdLoaded(rewardedAd);
					setAd(rewardedAd);
					Log.i(LOG_TAG, "rewarded interstitial ad loaded");
					listener.onRewardedInterstitialLoaded(RewardedInterstitial.this.adInfo, rewardedAd.getResponseInfo());
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					super.onAdFailedToLoad(loadAdError);

					setAd(null); // safety
					Log.e(LOG_TAG, "rewarded interstitial ad failed to load. errorCode: " + loadAdError.getCode());
					listener.onRewardedInterstitialFailedToLoad(RewardedInterstitial.this.adInfo, loadAdError);
				}
			});
		});
	}

	void show() {
		if (rewardedAd != null) {
			activity.runOnUiThread(() -> {
				rewardedAd.show(activity, rewardItem -> {
					Log.i(LOG_TAG, String.format("rewarded interstitial ad rewarded! currency: %s amount: %d", rewardItem.getType(), rewardItem.getAmount()));
					listener.onRewarded(RewardedInterstitial.this.adInfo, rewardItem);
				});
			});
		}
	}

	private void setAd(RewardedInterstitialAd rewardedAd) {
		if (rewardedAd == this.rewardedAd) {
			Log.w(LOG_TAG, "setAd(): rewarded interstitial already set");
		}
		else {
			if (rewardedAd != null) {
				rewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
					@Override
					public void onAdClicked() {
						super.onAdClicked();
						Log.i(LOG_TAG, "rewarded interstitial ad clicked");
						listener.onRewardedClicked(RewardedInterstitial.this.adInfo);
					}

					@Override
					public void onAdDismissedFullScreenContent() {
						super.onAdDismissedFullScreenContent();
						Log.i(LOG_TAG, "rewarded interstitial ad dismissed full screen content");
						listener.onRewardedInterstitialClosed(RewardedInterstitial.this.adInfo);
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						super.onAdFailedToShowFullScreenContent(adError);
						Log.e(LOG_TAG, "rewarded interstitial ad failed to show full screen content");
						listener.onRewardedInterstitialFailedToShow(RewardedInterstitial.this.adInfo, adError);
					}

					@Override
					public void onAdImpression() {
						super.onAdImpression();
						Log.i(LOG_TAG, "rewarded interstitial ad impression");
						listener.onRewardedAdImpression(RewardedInterstitial.this.adInfo);
					}

					@Override
					public void onAdShowedFullScreenContent() {
						super.onAdShowedFullScreenContent();
						Log.i(LOG_TAG, "rewarded interstitial ad showed full screen content");
						listener.onRewardedInterstitialOpened(RewardedInterstitial.this.adInfo);
					}
				});

				if (this.loadRequest.hasServerSideVerificationOptions()) {
					rewardedAd.setServerSideVerificationOptions(this.loadRequest.createServerSideVerificationOptions());
				}
			}
			// Avoid memory leaks
			if (this.rewardedAd != null)
				this.rewardedAd.setFullScreenContentCallback(null);

			this.rewardedAd = rewardedAd;
		}
	}
}
