//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.provider.Settings;
import android.util.Log;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions;
import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.FormError;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Locale;
import java.util.Map;

import org.godotengine.godot.Dictionary;

public class GodotConverter {
	private static final String LOG_TAG = AdmobPlugin.LOG_TAG + "::" + GodotConverter.class.getSimpleName();


	public static Dictionary convert(InitializationStatus initializationStatus) {
		Dictionary dict = new Dictionary();

		Map<String, AdapterStatus> adapterMap = initializationStatus.getAdapterStatusMap();
		for (String adapterClass : adapterMap.keySet()) {
			AdapterStatus adapterStatus = adapterMap.get(adapterClass);

			Dictionary statusDict = new Dictionary();
			statusDict.put("latency", adapterStatus.getLatency());
			statusDict.put("initializationState", adapterStatus.getInitializationState());
			statusDict.put("description", adapterStatus.getDescription());

			dict.put(adapterClass, statusDict);
		}

		return dict;
	}

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

		if (data.containsKey("request_agent")) {
			String requestAgent = (String) data.get("request_agent");
			if (requestAgent != null && !requestAgent.isEmpty()) {
				builder.setRequestAgent(requestAgent);
			}
		}

		// Mediation support: AdRequest extras can be added for specific networks if needed (e.g., for waterfall parameters).
		// For basic bidding/waterfall, no additional code is required as it's handled by AdMob SDK.

		if (data.containsKey("keywords")) {
			for (String keyword : (String[]) data.get("keywords")) {
				builder.addKeyword(keyword);
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

	public static ConsentRequestParameters createConsentRequestParameters(Dictionary data, Activity activity) {
		ConsentRequestParameters.Builder builder = new ConsentRequestParameters.Builder();

		if (data.containsKey("tag_for_under_age_of_consent")) {
			builder.setTagForUnderAgeOfConsent((boolean) data.get("tag_for_under_age_of_consent"));
		}

		if (data.containsKey("is_real") && (boolean) data.get("is_real") == false) {
			Log.d(LOG_TAG, "Creating debug settings for user consent.");
			ConsentDebugSettings.Builder debugSettingsBuilder = new ConsentDebugSettings.Builder(activity);

			if (data.containsKey("debug_geography")) {
				Object debugGeographyObj = data.get("debug_geography");
				if (debugGeographyObj instanceof Integer) {
					int debugGeography = (int) debugGeographyObj;
					Log.d(LOG_TAG, "Setting debug geography to: " + debugGeography);
					debugSettingsBuilder.setDebugGeography(debugGeography);
				} else {
					Log.e(LOG_TAG, "Invalid debug_geography type: " + 
						(debugGeographyObj != null ? debugGeographyObj.getClass().getSimpleName() : "null") +
						", value: " + debugGeographyObj);
				}
			} else {
				Log.w(LOG_TAG, "debug_geography key not found in dictionary");
			}

			if (data.containsKey("test_device_hashed_ids")) {
				Object deviceIdsObj = data.get("test_device_hashed_ids");
				if (deviceIdsObj instanceof Object[]) {
					Object[] deviceIds = (Object[]) deviceIdsObj;
					Log.d(LOG_TAG, "Found " + deviceIds.length + " device IDs in Object array.");
					for (Object deviceId : deviceIds) {
						if (deviceId instanceof String && !((String) deviceId).isEmpty()) {
							Log.d(LOG_TAG, "Adding test device id: " + deviceId);
							debugSettingsBuilder.addTestDeviceHashedId((String) deviceId);
						} else {
							Log.w(LOG_TAG, "Skipping invalid device ID: " + deviceId);
						}
					}
				} else {
					Log.e(LOG_TAG, "Invalid test_device_hashed_ids type: " + 
						(deviceIdsObj != null ? deviceIdsObj.getClass().getName() : "null") +
						", value: " + deviceIdsObj);
				}
			} else {
				Log.w(LOG_TAG, "test_device_hashed_ids key not found in dictionary");
			}

			debugSettingsBuilder.addTestDeviceHashedId(getAdMobDeviceId(activity));

			builder.setConsentDebugSettings(debugSettingsBuilder.build());
		}

		return builder.build();
	}

	public static RequestConfiguration.PublisherPrivacyPersonalizationState getPublisherPrivacyPersonalizationState(int intValue) {
		return switch (intValue) {
			case 1 -> RequestConfiguration.PublisherPrivacyPersonalizationState.ENABLED;
			case 2 -> RequestConfiguration.PublisherPrivacyPersonalizationState.DISABLED;
			default -> RequestConfiguration.PublisherPrivacyPersonalizationState.DEFAULT;
		};
	}

	/**
	 * Generate MD5 for the deviceID
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
	 * Get the Device ID for AdMob
	 *
	 * @return String Device ID
	 */
	private static String getAdMobDeviceId(Activity activity) {
		@SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
		return md5(androidId).toUpperCase(Locale.US);
	}
}
