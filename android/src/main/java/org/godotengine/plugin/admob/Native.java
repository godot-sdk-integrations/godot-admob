package org.godotengine.plugin.admob;

import android.app.Activity;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.nativead.MediaView;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdOptions;
import com.google.android.gms.ads.nativead.NativeAdView;

import org.godotengine.plugin.admob.model.AdmobAdInfo;
import org.godotengine.plugin.admob.model.LoadAdRequest;

interface NativeListener {
	void onAdLoaded(AdmobAdInfo adInfo, ResponseInfo responseInfo);
	void onAdFailedToLoad(AdmobAdInfo adInfo, LoadAdError error);
	void onAdImpression(AdmobAdInfo adInfo);
	void onAdClicked(AdmobAdInfo adInfo);
	void onAdOpened(AdmobAdInfo adInfo);
	void onAdClosed(AdmobAdInfo adInfo);
	void onAdSwipeGestureClicked(AdmobAdInfo adInfo);
	void onAdSizeMeasured(AdmobAdInfo adInfo);
}


public class Native {
	private static final String CLASS_NAME = Native.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private final Activity activity;
	private final FrameLayout layout;
	private final NativeListener nativeListener;

	private final AdmobAdInfo adInfo;
	private final LoadAdRequest loadRequest;
	private final String adId;

	private NativeAd nativeAd;
	private NativeAdView adView;
	private FrameLayout.LayoutParams adParams;

	private FrameLayout container;
	private FrameLayout.LayoutParams layoutParams;

	private int lastX = -1;
	private int lastY = -1;
	private int lastW = -1;
	private int lastH = -1;
	private boolean lastVisible = true;


	Native(AdmobAdInfo adInfo, Activity activity, FrameLayout layout, NativeListener listener) {
		this.adInfo = adInfo;
		this.adId = adInfo.getAdId();
		this.loadRequest = adInfo.getLoadAdRequest();

		this.activity = activity;
		this.layout = layout;
		this.nativeListener = listener;

		this.nativeAd = null;
		this.adView = null;
		this.adParams = null;
	}

	void load() {
		activity.runOnUiThread(() -> {
			AdLoader adLoader = new AdLoader.Builder(activity, loadRequest.getAdUnitId())
					.forNativeAd(ad -> {
						nativeAd = ad;
						createView();
						nativeListener.onAdLoaded(adInfo, ad.getResponseInfo());
					})
					.withNativeAdOptions(new NativeAdOptions.Builder().build())
					.withAdListener(new AdListener() {
						@Override
						public void onAdFailedToLoad(@NonNull LoadAdError error) {
							nativeListener.onAdFailedToLoad(adInfo, error);
						}

						@Override
						public void onAdImpression() {
							nativeListener.onAdImpression(adInfo);
						}

						@Override
						public void onAdClicked() {
							nativeListener.onAdClicked(adInfo);
						}

						@Override
						public void onAdSwipeGestureClicked() {
							nativeListener.onAdSwipeGestureClicked(adInfo);
						}

						@Override
						public void onAdOpened() {
							nativeListener.onAdOpened(adInfo);
						}

						@Override
						public void onAdClosed() {
							nativeListener.onAdClosed(adInfo);
						}
					})
					.build();

			adLoader.loadAd(loadRequest.createAdRequest());
		});
	}

	private void createView() {
		if (container != null) return;
		LayoutInflater inflater = LayoutInflater.from(activity);
		adView = (NativeAdView) inflater.inflate(R.layout.native_ad, layout, false);
		bindNativeAd(adView, nativeAd);

		container = new FrameLayout(activity);

		layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
		container.setLayoutParams(layoutParams);
		container.addView(adView);
		container.setVisibility(View.GONE);

		layout.addView(container);

		// debug overlay just for testing...
		container.setBackgroundColor(0x33FF0000);
		adView.setBackgroundColor(0x3300FF00);

		adView.post(() -> {
			DisplayMetrics metrics = activity.getResources().getDisplayMetrics();
			float density = metrics.density;
			int widthDp = Math.round(adView.getMeasuredWidth() / density);
			int heightDp = Math.round(adView.getMeasuredHeight() / density);
			adInfo.setMeasuredWidth(widthDp);
			adInfo.setMeasuredHeight(heightDp);
			nativeListener.onAdSizeMeasured(adInfo);
		});
	}

	void show() {
		if (container == null) return;
		if (nativeAd == null) {
			Log.w(LOG_TAG, "show(): native ad not loaded.");
			return;
		}
		activity.runOnUiThread(() -> {
			container.setVisibility(View.VISIBLE);
		});
	}

	public void hide() {
		if (container == null) return;
		activity.runOnUiThread(() -> container.setVisibility(View.GONE));
	}

	public void remove() {
		activity.runOnUiThread(() -> {
			if (container != null) {
				layout.removeView(container);
				container = null;
			}
			adView = null;
			if (nativeAd != null) {
				nativeAd.destroy();
				nativeAd = null;
			}
		});
	}

	private void bindNativeAd(NativeAdView adView, NativeAd ad) {
		TextView headline = adView.findViewById(R.id.ad_headline);
		MediaView media = adView.findViewById(R.id.ad_media);
		Button cta = adView.findViewById(R.id.ad_call_to_action);
		ImageView icon = adView.findViewById(R.id.ad_app_icon);

		headline.setText(ad.getHeadline());
		adView.setHeadlineView(headline);

		if (ad.getMediaContent() != null) {
			media.setMediaContent(ad.getMediaContent());
			adView.setMediaView(media);
		}

		if (ad.getCallToAction() != null) {
			cta.setText(ad.getCallToAction());
			adView.setCallToActionView(cta);
		}

		if (ad.getIcon() != null) {
			icon.setImageDrawable(ad.getIcon().getDrawable());
			adView.setIconView(icon);
		}

		adView.setNativeAd(ad);
	}

	public void updateLayout(int xPx, int yPx, int widthPx, int heightPx, boolean visible) {
		if (container == null || layoutParams == null) return;
		container.setPadding(0, 0, 0, 0);
		adView.setPadding(0, 0, 0, 0);

		if (xPx == lastX && yPx == lastY && widthPx == lastW && heightPx == lastH && visible == lastVisible) return;

		lastX = xPx;
		lastY = yPx;
		lastW = widthPx;
		lastH = heightPx;
		lastVisible = visible;

		activity.runOnUiThread(() -> {
			layoutParams.leftMargin = xPx;
			layoutParams.topMargin = yPx;
			layoutParams.width  = widthPx  > 0 ? widthPx  : FrameLayout.LayoutParams.WRAP_CONTENT;
			layoutParams.height = heightPx > 0 ? heightPx : FrameLayout.LayoutParams.WRAP_CONTENT;
			container.setVisibility(visible ? View.VISIBLE : View.GONE);
			layout.updateViewLayout(container, layoutParams);
		});
	}

}

