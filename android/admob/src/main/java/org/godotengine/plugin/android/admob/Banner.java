//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.app.Activity;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.LoadAdError;

import org.godotengine.godot.Dictionary;

interface BannerListener {
	void onAdLoaded(String adId);
	void onAdRefreshed(String adId);
	void onAdFailedToLoad(String adId, LoadAdError loadAdError);
	void onAdImpression(String adId);
	void onAdClicked(String adId);
	void onAdOpened(String adId);
	void onAdClosed(String adId);
}


public class Banner {
	private static final String CLASS_NAME = Banner.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private static final String AD_SIZE_PROPERTY = "ad_size";
	private static final String AD_POSITION_PROPERTY = "ad_position";
	static final String REQUEST_AGENT_PROPERTY = "request_agent";
	static final String KEYWORDS_PROPERTY = "keywords";
	static final String COLLAPSIBLE_PROPERTY = "collapsible";
	static final String COLLAPSIBLE_POSITION_PROPERTY = "collapsible_position";

	enum BannerSize {
		BANNER,
		LARGE_BANNER,
		MEDIUM_RECTANGLE,
		FULL_BANNER,
		LEADERBOARD,
		SKYSCRAPER,
		FLUID
	}

	enum AdPosition {
		TOP,
		BOTTOM,
		LEFT,
		RIGHT,
		TOP_LEFT,
		TOP_RIGHT,
		BOTTOM_LEFT,
		BOTTOM_RIGHT,
		CENTER
	}

	private final String adId;
	private final String adUnitId;
	private final AdRequest adRequest;
	private final Activity activity;
	private final FrameLayout layout;
	private final BannerSize bannerSize;
	private AdPosition adPosition;
	private AdView adView; // Banner view
	private FrameLayout.LayoutParams adParams;
	private AdListener adListener;

	private boolean firstLoad;


	Banner(final String adId, final String adUnitId, final Dictionary adData, final AdRequest adRequest,
				final Activity activity, final FrameLayout layout, BannerListener listener) {
		this.adId = adId;
		this.adUnitId = adUnitId;

		if (adData.containsKey(AD_SIZE_PROPERTY)) {
			this.bannerSize = BannerSize.valueOf((String) adData.get(AD_SIZE_PROPERTY));
		}
		else {
			this.bannerSize = BannerSize.BANNER;
			Log.e(LOG_TAG, "Error: Banner size is required!");
		}

		if (adData.containsKey(AD_POSITION_PROPERTY)) {
			this.adPosition = AdPosition.valueOf((String) adData.get(AD_POSITION_PROPERTY));
		}
		else {
			this.adPosition = AdPosition.TOP;
			Log.w(LOG_TAG, "Warning: Ad position not specified.");
		}

		this.adRequest = adRequest;
		this.activity = activity;
		this.layout = layout;

		firstLoad = true;

		this.adListener = new AdListener() {
			@Override
			public void onAdLoaded() {
				Log.d(LOG_TAG, "Ad loaded. isCollapsible = " + (adView != null && adView.isCollapsible()));
				if (Banner.this.firstLoad) {
					Banner.this.firstLoad = false;
					listener.onAdLoaded(Banner.this.adId);
				}
				else {
					listener.onAdRefreshed(Banner.this.adId);
				}
			}

			@Override
			public void onAdFailedToLoad(@NonNull LoadAdError error) {
				listener.onAdFailedToLoad(Banner.this.adId, error);
			}

			public void onAdImpression() {
				listener.onAdImpression(Banner.this.adId);
			}

			public void onAdClicked() {
				listener.onAdClicked(Banner.this.adId);
			}

			public void onAdOpened() {
				listener.onAdOpened(Banner.this.adId);
			}

			public void onAdClosed() {
				listener.onAdClosed(Banner.this.adId);
			}
		};

		this.adView = null;
		this.adParams = null;
	}

	void load() {
		addBanner(getGravity(adPosition), getAdSize(bannerSize));
	}

	void show() {
		if (adView == null) {
			Log.w(LOG_TAG, "show(): Warning: banner ad not loaded.");
		}
		else if (adView.getVisibility() == View.VISIBLE) {
			Log.w(LOG_TAG, "show(): Warning: banner ad already visible.");
		}
		else {
			Log.d(LOG_TAG, String.format("show(): %s", this.adId));
			adView.setVisibility(View.VISIBLE);
			adView.resume();

			// Add to layout and load ad
			layout.addView(adView, adParams);
		}
	}

	void move(final String position) {
		if (layout == null || adView == null || adParams == null) {
			Log.w(LOG_TAG, "move(): Warning: banner ad not loaded.");
		}
		else {
			Log.d(LOG_TAG, "banner ad moved");

			layout.removeView(adView); // Remove the old view

			adPosition = AdPosition.valueOf(position);
			addBanner(getGravity(adPosition), adView.getAdSize());

			// Add to layout and load ad
			layout.addView(adView, adParams);
		}
	}

	void resize() {
		if (layout == null || adView == null || adParams == null) {
			Log.w(LOG_TAG, "move(): Warning: banner ad not loaded.");
		}
		else {
			Log.d(LOG_TAG, String.format("resize(): %s", this.adId));

			layout.removeView(adView); // Remove the old view

			addBanner(adParams.gravity, getAdSize(bannerSize));

			// Add to layout and load ad
			layout.addView(adView, adParams);
		}
	}

	private void addBanner(final int gravity, final AdSize size) {
		adParams = new FrameLayout.LayoutParams(
				FrameLayout.LayoutParams.WRAP_CONTENT,
				FrameLayout.LayoutParams.WRAP_CONTENT
		);
		adParams.gravity = gravity;

		// Create new view & set old params
		adView = new AdView(activity);
		adView.setAdUnitId(adUnitId);
		adView.setBackgroundColor(Color.TRANSPARENT);
		adView.setAdSize(size);
		adView.setAdListener(adListener);
		adView.setVisibility(View.GONE);
		adView.pause();

		// Request
		adView.loadAd(adRequest);
	}

	public void remove() {
		if (adView == null) {
			Log.w(LOG_TAG, "remove(): Warning: adView is null.");
		}
		else {
			layout.removeView(adView);
		}
	}

	public void hide() {
		if (adView.getVisibility() != View.GONE) {
			adView.setVisibility(View.GONE);
			adView.pause();
			layout.removeView(adView);
		}
		else {
			Log.e(LOG_TAG, "Error: can't hide banner ad. Ad is not visible.");
		}
	}

	static int getAdWidth(Activity activity) {
		DisplayMetrics outMetrics = activity.getApplicationContext().getResources().getDisplayMetrics();
		return Math.round((float) outMetrics.widthPixels / outMetrics.density);
	}

	private AdSize getAdSize(final BannerSize bannerSize) {
		AdSize result;
		Log.d(LOG_TAG, String.format("getAdSize(): for value '%s'.", bannerSize.name()));
		result = switch (bannerSize) {
			case BANNER -> AdSize.BANNER;
			case LARGE_BANNER -> AdSize.LARGE_BANNER;
			case MEDIUM_RECTANGLE -> AdSize.MEDIUM_RECTANGLE;
			case FULL_BANNER -> AdSize.FULL_BANNER;
			case LEADERBOARD -> AdSize.LEADERBOARD;
			case SKYSCRAPER -> AdSize.WIDE_SKYSCRAPER;
			case FLUID -> AdSize.FLUID;
			default -> AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, getAdWidth(activity));
		};
		Log.d(LOG_TAG, String.format("getAdSize(): ad size [width: %d; height: %d].", result.getWidth(), result.getHeight()));
		return result;
	}

	private int getGravity(final AdPosition position) {
		int result;
		Log.d(LOG_TAG, String.format("getGravity(): for value '%s'.", position.name()));
		result = switch (position) {
			case TOP -> Gravity.TOP | Gravity.CENTER_HORIZONTAL;
			case BOTTOM -> Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
			case LEFT -> Gravity.START | Gravity.CENTER_VERTICAL;
			case RIGHT -> Gravity.END | Gravity.CENTER_VERTICAL;
			case TOP_LEFT -> Gravity.TOP | Gravity.START;
			case TOP_RIGHT -> Gravity.TOP | Gravity.END;
			case BOTTOM_LEFT -> Gravity.BOTTOM | Gravity.START;
			case BOTTOM_RIGHT -> Gravity.BOTTOM | Gravity.END;
			case CENTER -> Gravity.CENTER;
		};
		Log.d(LOG_TAG, String.format("getGravity(): result = %d.", result));
		return result;
	}

	public int getWidth() {
		return getAdSize(bannerSize).getWidth();
	}

	public int getHeight() {
		return getAdSize(bannerSize).getHeight();
	}

	public int getWidthInPixels() {
		return getAdSize(bannerSize).getWidthInPixels(activity);
	}

	public int getHeightInPixels() {
		return getAdSize(bannerSize).getHeightInPixels(activity);
	}
}
