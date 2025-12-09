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
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

import org.godotengine.plugin.admob.model.AdmobAdInfo;
import org.godotengine.plugin.admob.model.LoadAdRequest;


interface RewardedVideoListener {
	void onRewardedVideoLoaded(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onRewardedVideoFailedToLoad(AdmobAdInfo adInfo, LoadAdError loadAdError);
	void onRewardedVideoOpened(AdmobAdInfo adInfo);
	void onRewardedVideoFailedToShow(AdmobAdInfo adInfo, AdError adError);
	void onRewardedVideoClosed(AdmobAdInfo adInfo);
	void onRewardedClicked(AdmobAdInfo adInfo);
	void onRewardedAdImpression(AdmobAdInfo adInfo);
	void onRewarded(AdmobAdInfo adInfo, RewardItem reward);
}


public class RewardedVideo {
	private static final String CLASS_NAME = RewardedVideo.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private AdmobAdInfo adInfo;
	private final String adId;
	private final LoadAdRequest loadRequest;
	private final Activity activity;
	private final RewardedVideoListener listener;

	private RewardedAd rewardedAd;

	RewardedVideo(AdmobAdInfo adInfo, Activity activity, final RewardedVideoListener listener) {
		this.adInfo = adInfo;
		this.adId = adInfo.getAdId();
		this.loadRequest = adInfo.getLoadAdRequest();

		this.activity = activity;
		this.listener = listener;
		this.rewardedAd = null;
	}

	void load() {
		activity.runOnUiThread(() -> {
			RewardedAd.load(activity, loadRequest.getAdUnitId(), loadRequest.createAdRequest(), new RewardedAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull RewardedAd rewardedAd) {
					super.onAdLoaded(rewardedAd);
					setAd(rewardedAd);
					Log.i(LOG_TAG, "rewarded video ad loaded");
					listener.onRewardedVideoLoaded(RewardedVideo.this.adInfo, rewardedAd.getResponseInfo());
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					super.onAdFailedToLoad(loadAdError);
					// safety
					setAd(null);
					Log.e(LOG_TAG, "rewarded video ad failed to load. errorCode: " + loadAdError.getCode());
					listener.onRewardedVideoFailedToLoad(RewardedVideo.this.adInfo, loadAdError);
				}
			});
		});
	}

	void show() {
		if (rewardedAd != null) {
			activity.runOnUiThread(() -> {
				rewardedAd.show(activity, rewardItem -> {
					Log.i(LOG_TAG, String.format("rewarded video ad reward received! currency: %s amount: %d", rewardItem.getType(), rewardItem.getAmount()));
					listener.onRewarded(RewardedVideo.this.adInfo, rewardItem);
				});
			});
		}
	}

	private void setAd(RewardedAd rewardedAd) {
		if (rewardedAd == this.rewardedAd) {
			Log.w(LOG_TAG, "setAd(): rewarded already set");
		}
		else {
			if (rewardedAd != null) {
				rewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
					@Override
					public void onAdClicked() {
						super.onAdClicked();
						Log.i(LOG_TAG, "rewarded video ad clicked");
						listener.onRewardedClicked(RewardedVideo.this.adInfo);
					}

					@Override
					public void onAdDismissedFullScreenContent() {
						super.onAdDismissedFullScreenContent();
						Log.i(LOG_TAG, "rewarded video ad dismissed full screen content");
						listener.onRewardedVideoClosed(RewardedVideo.this.adInfo);
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						super.onAdFailedToShowFullScreenContent(adError);
						Log.e(LOG_TAG, "rewarded video ad failed to show full screen content");
						listener.onRewardedVideoFailedToShow(RewardedVideo.this.adInfo, adError);
					}

					@Override
					public void onAdImpression() {
						super.onAdImpression();
						Log.i(LOG_TAG, "rewarded video ad impression");
						listener.onRewardedAdImpression(RewardedVideo.this.adInfo);
					}

					@Override
					public void onAdShowedFullScreenContent() {
						super.onAdShowedFullScreenContent();
						Log.i(LOG_TAG, "rewarded video ad showed full screen content");
						listener.onRewardedVideoOpened(RewardedVideo.this.adInfo);
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
