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
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions;
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd;
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback;

interface RewardedInterstitialListener {
	void onRewardedInterstitialLoaded(String adId);
	void onRewardedInterstitialFailedToLoad(String adId, LoadAdError loadAdError);
	void onRewardedInterstitialOpened(String adId);
	void onRewardedInterstitialFailedToShow(String adId, AdError adError);
	void onRewardedInterstitialClosed(String adId);
	void onRewardedClicked(String adId);
	void onRewardedAdImpression(String adId);
	void onRewarded(String adId, RewardItem reward);
}

public class RewardedInterstitial {
	private static final String CLASS_NAME = RewardedInterstitial.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private final String adId;
	private final String adUnitId;
	private final AdRequest adRequest;
	private final Activity activity;
	private final RewardedInterstitialListener listener;

	private RewardedInterstitialAd rewardedAd;
	private ServerSideVerificationOptions serverSideVerificationOptions;

	RewardedInterstitial(final String adId, final String adUnitId, final AdRequest adRequest, Activity activity,
				final RewardedInterstitialListener listener) {
		this.adId = adId;
		this.adUnitId = adUnitId;
		this.adRequest = adRequest;
		this.activity = activity;
		this.listener = listener;
		this.rewardedAd = null;
		this.serverSideVerificationOptions = null;
	}

	void load() {
		RewardedInterstitialAd.load(activity, adUnitId, adRequest, new RewardedInterstitialAdLoadCallback() {
			@Override
			public void onAdLoaded(@NonNull RewardedInterstitialAd rewardedAd) {
				super.onAdLoaded(rewardedAd);
				setAd(rewardedAd);
				Log.i(LOG_TAG, "rewarded interstitial ad loaded");
				listener.onRewardedInterstitialLoaded(RewardedInterstitial.this.adId);
			}

			@Override
			public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
				super.onAdFailedToLoad(loadAdError);
				
				setAd(null); // safety
				Log.e(LOG_TAG, "rewarded interstitial ad failed to load. errorCode: " + loadAdError.getCode());
				listener.onRewardedInterstitialFailedToLoad(RewardedInterstitial.this.adId, loadAdError);
			}
		});
	}

	void show() {
		if (rewardedAd != null) {
			rewardedAd.show(activity, rewardItem -> {
				Log.i(LOG_TAG, String.format("rewarded interstitial ad rewarded! currency: %s amount: %d", rewardItem.getType(), rewardItem.getAmount()));
				listener.onRewarded(RewardedInterstitial.this.adId, rewardItem);
			});
		}
	}

	private void setAd(RewardedInterstitialAd rewardedAd) {
		if (rewardedAd == this.rewardedAd) {
			Log.w(LOG_TAG, "setAd(): rewarded interstitial already set");
		}
		else {
			// Avoid memory leaks.
			if (this.rewardedAd != null)
				this.rewardedAd.setFullScreenContentCallback(null);

			if (rewardedAd != null) {
				rewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
					@Override
					public void onAdClicked() {
						super.onAdClicked();
						Log.i(LOG_TAG, "rewarded interstitial ad clicked");
						listener.onRewardedClicked(RewardedInterstitial.this.adId);
					}

					@Override
					public void onAdDismissedFullScreenContent() {
						super.onAdDismissedFullScreenContent();
						Log.w(LOG_TAG, "rewarded interstitial ad dismissed full screen content");
						listener.onRewardedInterstitialClosed(RewardedInterstitial.this.adId);
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						super.onAdFailedToShowFullScreenContent(adError);
						Log.e(LOG_TAG, "rewarded interstitial ad failed to show full screen content");
						listener.onRewardedInterstitialFailedToShow(RewardedInterstitial.this.adId, adError);
					}

					@Override
					public void onAdImpression() {
						super.onAdImpression();
						Log.i(LOG_TAG, "rewarded interstitial ad impression");
						listener.onRewardedAdImpression(RewardedInterstitial.this.adId);
					}

					@Override
					public void onAdShowedFullScreenContent() {
						super.onAdShowedFullScreenContent();
						Log.i(LOG_TAG, "rewarded interstitial ad showed full screen content");
						listener.onRewardedInterstitialOpened(RewardedInterstitial.this.adId);
					}
				});
			}

			if (serverSideVerificationOptions != null) {
				rewardedAd.setServerSideVerificationOptions(serverSideVerificationOptions);
			}

			this.rewardedAd = rewardedAd;
		}
	}

	void setServerSideVerificationOptions(ServerSideVerificationOptions ssvo) {
		this.serverSideVerificationOptions = ssvo;

		if (rewardedAd == null) {
			Log.w(LOG_TAG, "setServerSideVerificationOptions(): Ad is null. SSVO will be set when ad is loaded.");
		}
		else {
			rewardedAd.setServerSideVerificationOptions(ssvo);
		}
	}
}
