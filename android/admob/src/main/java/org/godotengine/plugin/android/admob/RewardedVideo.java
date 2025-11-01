//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions;

import org.godotengine.plugin.android.admob.model.LoadAdRequest;


interface RewardedVideoListener {
	void onRewardedVideoLoaded(String adId);
	void onRewardedVideoFailedToLoad(String adId, LoadAdError loadAdError);
	void onRewardedVideoOpened(String adId);
	void onRewardedVideoFailedToShow(String adId, AdError adError);
	void onRewardedVideoClosed(String adId);
	void onRewardedClicked(String adId);
	void onRewardedAdImpression(String adId);
	void onRewarded(String adId, RewardItem reward);
}


public class RewardedVideo {
	private static final String CLASS_NAME = RewardedVideo.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private final String adId;
	private final LoadAdRequest loadRequest;
	private final Activity activity;
	private final RewardedVideoListener listener;

	private RewardedAd rewardedAd;
	private ServerSideVerificationOptions serverSideVerificationOptions;

	RewardedVideo(final String adId, final LoadAdRequest loadRequest, Activity activity,
				final RewardedVideoListener listener) {
		this.adId = adId;
		this.loadRequest = loadRequest;
		this.activity = activity;
		this.listener = listener;
		this.rewardedAd = null;
		this.serverSideVerificationOptions = null;
	}

	void load() {
		activity.runOnUiThread(() -> {
			RewardedAd.load(activity, loadRequest.getAdUnitId(), loadRequest.createAdRequest(), new RewardedAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull RewardedAd rewardedAd) {
					super.onAdLoaded(rewardedAd);
					setAd(rewardedAd);
					Log.i(LOG_TAG, "rewarded video ad loaded");
					listener.onRewardedVideoLoaded(RewardedVideo.this.adId);
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					super.onAdFailedToLoad(loadAdError);
					// safety
					setAd(null);
					Log.e(LOG_TAG, "rewarded video ad failed to load. errorCode: " + loadAdError.getCode());
					listener.onRewardedVideoFailedToLoad(RewardedVideo.this.adId, loadAdError);
				}
			});
		});
	}

	void show() {
		if (rewardedAd != null) {
			activity.runOnUiThread(() -> {
				rewardedAd.show(activity, rewardItem -> {
					Log.i(LOG_TAG, String.format("rewarded video ad reward received! currency: %s amount: %d", rewardItem.getType(), rewardItem.getAmount()));
					listener.onRewarded(RewardedVideo.this.adId, rewardItem);
				});
			});
		}
	}

	private void setAd(RewardedAd rewardedAd) {
		if (rewardedAd == this.rewardedAd) {
			Log.w(LOG_TAG, "setAd(): rewarded already set");
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
						Log.i(LOG_TAG, "rewarded video ad clicked");
						listener.onRewardedClicked(RewardedVideo.this.adId);
					}

					@Override
					public void onAdDismissedFullScreenContent() {
						super.onAdDismissedFullScreenContent();
						Log.w(LOG_TAG, "rewarded video ad dismissed full screen content");
						listener.onRewardedVideoClosed(RewardedVideo.this.adId);
					}

					@Override
					public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
						super.onAdFailedToShowFullScreenContent(adError);
						Log.e(LOG_TAG, "rewarded video ad failed to show full screen content");
						listener.onRewardedVideoFailedToShow(RewardedVideo.this.adId, adError);
					}

					@Override
					public void onAdImpression() {
						super.onAdImpression();
						Log.i(LOG_TAG, "rewarded video ad impression");
						listener.onRewardedAdImpression(RewardedVideo.this.adId);
					}

					@Override
					public void onAdShowedFullScreenContent() {
						super.onAdShowedFullScreenContent();
						Log.i(LOG_TAG, "rewarded video ad showed full screen content");
						listener.onRewardedVideoOpened(RewardedVideo.this.adId);
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
