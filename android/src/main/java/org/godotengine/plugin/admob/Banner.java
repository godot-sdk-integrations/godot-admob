//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import android.app.Activity;
import android.graphics.Color;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.graphics.Insets;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.LoadAdError;

import org.godotengine.plugin.admob.model.AdmobAdInfo;
import org.godotengine.plugin.admob.model.LoadAdRequest;


interface BannerListener {
	void onAdLoaded(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onAdRefreshed(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onAdFailedToLoad(AdmobAdInfo adInfo, LoadAdError loadAdError);
	void onAdImpression(AdmobAdInfo adInfo);
	void onAdSizeMeasured(AdmobAdInfo adInfo);
	void onAdClicked(AdmobAdInfo adInfo);
	void onAdOpened(AdmobAdInfo adInfo);
	void onAdClosed(AdmobAdInfo adInfo);
}


public class Banner {
	private static final String CLASS_NAME = Banner.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	enum BannerSize {
		BANNER,
		LARGE_BANNER,
		MEDIUM_RECTANGLE,
		FULL_BANNER,
		LEADERBOARD,
		SKYSCRAPER,
		FLUID,
		ADAPTIVE,
		INLINE_ADAPTIVE
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
		CENTER,
		CUSTOM
	}

	private AdmobAdInfo adInfo;
	private final Activity activity;
	private final FrameLayout layout;
	private final BannerListener bannerListener;
	private final String adId;
	private final LoadAdRequest loadRequest;
	private final BannerSize bannerSize;
	private AdPosition adPosition;
	private AdView adView; // Banner view
	private FrameLayout.LayoutParams adParams;
	private AdListener adListener;
	private boolean anchorToSafeArea;

	private boolean firstLoad;


	Banner(AdmobAdInfo adInfo, final Activity activity, final FrameLayout layout, final BannerListener listener) {
		this.adInfo = adInfo;
		this.adId = adInfo.getAdId();
		this.loadRequest = adInfo.getLoadAdRequest();

		this.activity = activity;
		this.layout = layout;
		this.bannerListener = listener;

		if (this.loadRequest.hasAdSize()) {
			this.bannerSize = BannerSize.valueOf(this.loadRequest.getAdSize());
		}
		else {
			this.bannerSize = BannerSize.BANNER;
			Log.e(LOG_TAG, "Error: Banner size is required! Defaulting to BANNER.");
		}

		this.adPosition = this.loadRequest.hasAdPosition() ? AdPosition.valueOf(this.loadRequest.getAdPosition()) : AdPosition.TOP;
		this.anchorToSafeArea = this.loadRequest.doAnchorToSafeArea();

		firstLoad = true;

		this.adListener = new AdListener() {
			@Override
			public void onAdLoaded() {
				Banner.this.adInfo.setMeasuredWidth(adView.getAdSize().getWidth());
				Banner.this.adInfo.setMeasuredHeight(adView.getAdSize().getHeight());
				Banner.this.adInfo.setIsCollapsible(Banner.this.adView.isCollapsible());

				if (Banner.this.firstLoad) {
					Banner.this.firstLoad = false;
					listener.onAdLoaded(Banner.this.adInfo, Banner.this.adView.getResponseInfo());
				}
				else {
					listener.onAdRefreshed(Banner.this.adInfo, Banner.this.adView.getResponseInfo());
				}
			}

			@Override
			public void onAdFailedToLoad(@NonNull LoadAdError error) {
				listener.onAdFailedToLoad(Banner.this.adInfo, error);
			}

			public void onAdImpression() {
				listener.onAdImpression(Banner.this.adInfo);
			}

			public void onAdClicked() {
				listener.onAdClicked(Banner.this.adInfo);
			}

			public void onAdOpened() {
				listener.onAdOpened(Banner.this.adInfo);
			}

			public void onAdClosed() {
				listener.onAdClosed(Banner.this.adInfo);
			}
		};

		this.adView = null;
		this.adParams = null;
	}

	void load() {
		activity.runOnUiThread(() -> {
			addBanner(getGravity(adPosition), getAdSize(bannerSize));
		});
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
			activity.runOnUiThread(() -> {
				adView.setVisibility(View.VISIBLE);
				adView.resume();

				// Add to layout and load ad
				layout.addView(adView, adParams);

				if (anchorToSafeArea && adPosition != AdPosition.CUSTOM) {
					ViewCompat.requestApplyInsets(adView);

					// Force manual application using parent's insets
					WindowInsetsCompat rootInsets = ViewCompat.getRootWindowInsets(layout);
					if (rootInsets != null) {
						Log.d(LOG_TAG, "Banner.show: Manually applying insets from parent layout.");
						applyInsets(adView, rootInsets);
					} else {
						Log.w(LOG_TAG, "Banner.show: Parent insets are null, relying on listener (which might not fire).");
					}
				}

				adView.post(() -> {
					// Convert Pixels to DP so Godot receives logical units
					DisplayMetrics outMetrics = activity.getApplicationContext().getResources().getDisplayMetrics();
					float density = outMetrics.density;

					int widthDp = Math.round(adView.getMeasuredWidth() / density);
					int heightDp = Math.round(adView.getMeasuredHeight() / density);

					Banner.this.adInfo.setMeasuredWidth(widthDp);
					Banner.this.adInfo.setMeasuredHeight(heightDp);

					Log.d(LOG_TAG, String.format("Actual size (px): [%d,%d] -> (dp): [%d, %d]",
							adView.getMeasuredWidth(), adView.getMeasuredHeight(), widthDp, heightDp));
					
					Banner.this.bannerListener.onAdSizeMeasured(Banner.this.adInfo);
				});
			});
		}
	}

	void resize() {
		if (layout == null || adView == null || adParams == null) {
			Log.w(LOG_TAG, "resize(): Warning: banner ad not loaded.");
		}
		else {
			Log.d(LOG_TAG, String.format("resize(): %s", this.adId));

			activity.runOnUiThread(() -> {
				layout.removeView(adView); // Remove the old view

				addBanner(adParams.gravity, getAdSize(bannerSize));

				// Add to layout and load ad
				layout.addView(adView, adParams);
			});
		}
	}

	private void addBanner(final int gravity, final AdSize size) {
		adParams = new FrameLayout.LayoutParams(
				FrameLayout.LayoutParams.WRAP_CONTENT,
				FrameLayout.LayoutParams.WRAP_CONTENT
		);
		if (bannerSize == BannerSize.INLINE_ADAPTIVE) {
			adParams.width = getWidthInPixels();
		}
		if (adPosition == AdPosition.CUSTOM) {
			adParams.gravity = 0;
			adParams.leftMargin = 0;
			adParams.topMargin = 0;
		} else {
			adParams.gravity = gravity;
		}

		// Create new view & set old params
		adView = new AdView(activity);
		adView.setAdUnitId(loadRequest.getAdUnitId());
		adView.setBackgroundColor(Color.TRANSPARENT);
		adView.setAdSize(size);
		adView.setAdListener(adListener);
		adView.setVisibility(View.GONE);
		adView.pause();

		if (anchorToSafeArea && adPosition != AdPosition.CUSTOM) {
			// Set the listener to handle updates (like rotation) if the system dispatches them later
			ViewCompat.setOnApplyWindowInsetsListener(adView, (view, insets) -> {
				applyInsets(view, insets);
				return insets;
			});
		}

		// Request
		adView.loadAd(loadRequest.createAdRequest());
	}

	/**
	 * Helper method to calculate and apply safe area insets to the Banner margins.
	 */
	private void applyInsets(View view, WindowInsetsCompat insets) {
		// Get insets for System Bars (Status/Nav Bar)
		Insets systemBarInsets = insets.getInsets(WindowInsetsCompat.Type.systemBars());
		int topInset = systemBarInsets.top;
		int bottomInset = systemBarInsets.bottom;
		int leftInset = systemBarInsets.left;
		int rightInset = systemBarInsets.right;

		// This section primarily addresses device cutouts (like notches/camera holes)
		Insets cutoutInsets = insets.getInsets(WindowInsetsCompat.Type.displayCutout());

		// Combine the insets (take the max to include both system bars and cutouts)
		topInset = Math.max(topInset, cutoutInsets.top);
		bottomInset = Math.max(bottomInset, cutoutInsets.bottom);
		leftInset = Math.max(leftInset, cutoutInsets.left);
		rightInset = Math.max(rightInset, cutoutInsets.right);

		Log.d(LOG_TAG, String.format("Anchor to Safe Area: Insets (T, B, L, R) in Pixels: %d, %d, %d, %d",
				topInset, bottomInset, leftInset, rightInset));

		FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) view.getLayoutParams();
		// Reset margins
		params.topMargin = 0;
		params.bottomMargin = 0;
		params.leftMargin = 0;
		params.rightMargin = 0;

		switch (adPosition) {
			case TOP:
				params.topMargin = topInset;
				break;
			case BOTTOM:
				params.bottomMargin = bottomInset;
				break;
			case LEFT:
				params.leftMargin = leftInset;
				break;
			case RIGHT:
				params.rightMargin = rightInset;
				break;
			case TOP_LEFT:
				params.topMargin = topInset;
				params.leftMargin = leftInset;
				break;
			case TOP_RIGHT:
				params.topMargin = topInset;
				params.rightMargin = rightInset;
				break;
			case BOTTOM_LEFT:
				params.bottomMargin = bottomInset;
				params.leftMargin = leftInset;
				break;
			case BOTTOM_RIGHT:
				params.bottomMargin = bottomInset;
				params.rightMargin = rightInset;
				break;
		}
		view.setLayoutParams(params);
	}

	public void move(final float x, final float y) {
		this.adParams.leftMargin = (int) x;
		this.adParams.topMargin = (int) y;
		this.adParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
		if (this.bannerSize == Banner.BannerSize.INLINE_ADAPTIVE) {
			// adInfo holds DP, but LayoutParams needs Pixels. Convert back.
			int measuredWidthDp = this.adInfo.getMeasuredWidth();
			int measuredWidthPx = (int) (measuredWidthDp * activity.getResources().getDisplayMetrics().density);

			this.adParams.width = measuredWidthDp > 0 ? measuredWidthPx : this.getWidthInPixels();
		} else {
			this.adParams.width = ViewGroup.LayoutParams.WRAP_CONTENT;
		}
		activity.runOnUiThread(() -> {
			layout.updateViewLayout(this.adView, this.adParams);
		});
	}

	public void remove() {
		if (adView == null) {
			Log.w(LOG_TAG, "remove(): Warning: adView is null.");
		}
		else {
			activity.runOnUiThread(() -> {
				layout.removeView(adView);
			});
		}
	}

	public void hide() {
		if (adView.getVisibility() != View.GONE) {
			activity.runOnUiThread(() -> {
				adView.setVisibility(View.GONE);
				adView.pause();
				layout.removeView(adView);
			});
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
		result = switch (bannerSize) {
			case BANNER -> AdSize.BANNER;
			case LARGE_BANNER -> AdSize.LARGE_BANNER;
			case MEDIUM_RECTANGLE -> AdSize.MEDIUM_RECTANGLE;
			case FULL_BANNER -> AdSize.FULL_BANNER;
			case LEADERBOARD -> AdSize.LEADERBOARD;
			case SKYSCRAPER -> AdSize.WIDE_SKYSCRAPER;
			case FLUID -> AdSize.FLUID;
			case ADAPTIVE -> {
				int widthDp = loadRequest.getAdaptiveWidth() != -1 ? loadRequest.getAdaptiveWidth() : getAdWidth(activity);
				yield AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, widthDp);
			}
			case INLINE_ADAPTIVE -> {
				int widthDp = loadRequest.getAdaptiveWidth() != -1 ? loadRequest.getAdaptiveWidth() : getAdWidth(activity);
				int maxHeight = loadRequest.getAdaptiveMaxHeight() != -1 ? loadRequest.getAdaptiveMaxHeight() : AdSize.AUTO_HEIGHT;
				yield AdSize.getInlineAdaptiveBannerAdSize(widthDp, maxHeight);
			}
			default -> AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, getAdWidth(activity));
		};
		Log.d(LOG_TAG, String.format("getAdSize('%s'): result = [width: %d; height: %d].", bannerSize.name(), result.getWidth(), result.getHeight()));
		return result;
	}

	private int getGravity(final AdPosition position) {
		int result;
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
			case CUSTOM -> 0;
		};
		Log.d(LOG_TAG, String.format("getGravity('%s'): result = %d.", position.name(), result));
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
