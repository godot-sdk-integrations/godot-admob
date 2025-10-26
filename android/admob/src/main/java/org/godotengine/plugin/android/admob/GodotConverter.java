//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;

import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions;
import com.google.android.ump.FormError;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Locale;
import java.util.Map;

import org.godotengine.godot.Dictionary;


public class GodotConverter {
	private static final String LOG_TAG = AdmobPlugin.LOG_TAG + "::" + GodotConverter.class.getSimpleName();

	public static Dictionary convert(AdSize size) {
		Dictionary dict = new Dictionary();

		dict.put("width", size.getWidth());
		dict.put("height", size.getHeight());

		return dict;
	}

	public static Dictionary convert(AdError error) {
		Dictionary dict = new Dictionary();

		dict.put("code", error.getCode());
		dict.put("domain", error.getDomain());
		dict.put("message", error.getMessage());
		dict.put("cause", error.getCause() == null ? new Dictionary() : convert(error.getCause()));

		return dict;
	}

	public static Dictionary convert(LoadAdError error) {
		Dictionary dict = convert((AdError) error);

		dict.put("response_info", error.getResponseInfo().toString());

		return dict;
	}

	public static Dictionary convert(FormError error) {
		Dictionary dict = new Dictionary();

		if (error == null) {
			dict.put("code", 0);
			dict.put("message", "");
		} else {
			dict.put("code", error.getErrorCode());
			dict.put("message", error.getMessage());
		}

		return dict;
	}

	public static Dictionary convert(RewardItem item) {
		Dictionary dict = new Dictionary();

		dict.put("amount", item.getAmount());
		dict.put("type", item.getType());

		return dict;
	}

	public static RequestConfiguration createRequestConfiguration(Dictionary data, Activity activity) {
		RequestConfiguration.Builder builder = MobileAds.getRequestConfiguration().toBuilder();

		if (data.containsKey("max_ad_content_rating"))
			builder.setMaxAdContentRating((String) data.get("max_ad_content_rating"));

		if (data.containsKey("tag_for_child_directed_treatment"))
			builder.setTagForChildDirectedTreatment((int) data.get("tag_for_child_directed_treatment"));

		if (data.containsKey("tag_for_under_age_of_consent"))
			builder.setTagForUnderAgeOfConsent((int) data.get("tag_for_under_age_of_consent"));

		if (data.containsKey("personalization_state"))
			builder.setPublisherPrivacyPersonalizationState(getPublisherPrivacyPersonalizationState((int) data.get("personalization_state")));

		ArrayList<String> testDeviceIds = new ArrayList<>();
		if (data.containsKey("test_device_ids"))
			testDeviceIds.addAll(Arrays.asList((String[]) data.get("test_device_ids")));

		if (data.containsKey("is_real")) {
			if ((boolean) data.get("is_real") == false) {
				testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);
				testDeviceIds.add(getAdMobDeviceId(activity));
			}
		}

		if (testDeviceIds.isEmpty() == false)
			builder.setTestDeviceIds(testDeviceIds);

		return builder.build();
	}

	public static AdRequest createAdRequest(Dictionary data) {
		AdRequest.Builder builder = new AdRequest.Builder();

		if (data.containsKey(Banner.REQUEST_AGENT_PROPERTY)) {
			String requestAgent = (String) data.get(Banner.REQUEST_AGENT_PROPERTY);
			if (requestAgent != null && !requestAgent.isEmpty()) {
				builder.setRequestAgent(requestAgent);
			}
		}

		// TODO: mediation support

		if (data.containsKey(Banner.KEYWORDS_PROPERTY)) {
			for (String keyword : (String[]) data.get(Banner.KEYWORDS_PROPERTY)) {
				builder.addKeyword(keyword);
			}
		}

		if (data.containsKey(Banner.COLLAPSIBLE_PROPERTY)) {
			Boolean isCollapsible = (Boolean) data.get(Banner.COLLAPSIBLE_PROPERTY);
			if (Boolean.TRUE.equals(isCollapsible)) {
				String collapsiblePosition = "top";
				if (data.containsKey(Banner.COLLAPSIBLE_POSITION_PROPERTY)) {
					collapsiblePosition = (String) data.get(Banner.COLLAPSIBLE_POSITION_PROPERTY);
				}
				else {
					Log.w(LOG_TAG, "Warning: Collapsible position not specified.");
				}
				Log.d(LOG_TAG, "Loading collapsible banner (" + collapsiblePosition + ")");
				Bundle extras = new Bundle();
				extras.putString("collapsible", collapsiblePosition);
				builder.addNetworkExtrasBundle(AdMobAdapter.class, extras);
			}
		}

		return builder.build();
	}

	public static ServerSideVerificationOptions createSSVO(Dictionary data) {
		ServerSideVerificationOptions.Builder builder = new ServerSideVerificationOptions.Builder();

		if (data.containsKey("custom_data")) {
			builder.setCustomData((String) data.get("custom_data"));
		}

		if (data.containsKey("user_id")) {
			builder.setUserId((String) data.get("user_id"));
		}

		return builder.build();
	}

	/**
	 * Generate MD5 for the deviceID (mirrors iOS hashed device ID logic).
	 *
	 * @param s The string for which to generate the MD5
	 * @return String The generated MD5
	 */
	private static String md5(final String s) {
		try {
			// Create MD5 Hash
			MessageDigest digest = MessageDigest.getInstance("MD5");
			digest.update(s.getBytes());
			byte[] messageDigest = digest.digest();

			// Create Hex String
			StringBuilder hexString = new StringBuilder();
			for (byte b : messageDigest) {
				StringBuilder h = new StringBuilder(Integer.toHexString(0xFF & b));
				while (h.length() < 2)
					h.insert(0, "0");
				hexString.append(h);
			}
			return hexString.toString();
		} catch (NoSuchAlgorithmException e) {
			Log.e(LOG_TAG, "md5() - no such algorithm");
		}
		return "";
	}

	/**
	 * Get the Device ID for AdMob (hashed ANDROID_ID, equivalent to iOS advertising/device ID fallback).
	 *
	 * @param activity The activity context
	 * @return String Hashed Device ID
	 */
	@SuppressLint("HardwareIds")
	public static String getAdMobDeviceId(Activity activity) {
		String androidId = Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
		return md5(androidId).toUpperCase(Locale.US);
	}
}
