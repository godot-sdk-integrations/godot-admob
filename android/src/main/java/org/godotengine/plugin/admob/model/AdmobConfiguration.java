//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import android.app.Activity;
import android.provider.Settings;
import android.util.Log;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Locale;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.AdmobPlugin;
import org.godotengine.plugin.admob.GodotConverter;


public class AdmobConfiguration {
	private static final String CLASS_NAME = AdmobConfiguration.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private static String IS_REAL_PROPERTY = "is_real";
	private static String MAX_AD_CONTENT_RATING_PROPERTY = "max_ad_content_rating";
	private static String CHILD_DIRECTED_TREATMENT_PROPERTY = "tag_for_child_directed_treatment";
	private static String UNDER_AGE_OF_CONSENT_PROPERTY = "tag_for_under_age_of_consent";
	private static String FIRST_PARTY_ID_ENABLED_PROPERTY = "first_party_id_enabled";
	private static String PERSONALIZATION_STATE_PROPERTY = "personalization_state";
	private static String TEST_DEVICE_IDS_PROPERTY = "test_device_ids";

	private Dictionary _data;

	public AdmobConfiguration(Dictionary data) {
		this._data = data;
	}

	public boolean isReal() {
		return (boolean) _data.get(IS_REAL_PROPERTY);
	}

	public String getMaxContentRating() {
		return (String) _data.get(MAX_AD_CONTENT_RATING_PROPERTY);
	}

	public int getChildDirectedTreatment() {
		return (int) _data.get(CHILD_DIRECTED_TREATMENT_PROPERTY);
	}

	public int getUnderAgeOfConsent() {
		return (int) _data.get(UNDER_AGE_OF_CONSENT_PROPERTY);
	}

	public boolean getFirstPartyIdEnabled() {
		return (boolean) _data.get(FIRST_PARTY_ID_ENABLED_PROPERTY);
	}

	public int getPublisherPrivacyPersonalizationState() {
		return (int) _data.get(PERSONALIZATION_STATE_PROPERTY);
	}

	public String[] getTestDeviceIds() {
		return (String[]) _data.get(TEST_DEVICE_IDS_PROPERTY);
	}

	public RequestConfiguration createRequestConfiguration(Activity activity) {
		RequestConfiguration.Builder builder = MobileAds.getRequestConfiguration().toBuilder();

		if (_data.containsKey(MAX_AD_CONTENT_RATING_PROPERTY))
			builder.setMaxAdContentRating(getMaxContentRating());

		if (_data.containsKey(CHILD_DIRECTED_TREATMENT_PROPERTY))
			builder.setTagForChildDirectedTreatment(getChildDirectedTreatment());

		if (_data.containsKey(UNDER_AGE_OF_CONSENT_PROPERTY))
			builder.setTagForUnderAgeOfConsent(getUnderAgeOfConsent());

		if (_data.containsKey(FIRST_PARTY_ID_ENABLED_PROPERTY)) {
			// Note: Android RequestConfiguration does not have a direct equivalent for iOS's setPublisherFirstPartyIDEnabled.
			// First-party user IDs are typically set per AdRequest via setFirstPartyUserId.
			Log.d(LOG_TAG, "firstPartyIdEnabled: " + getFirstPartyIdEnabled() + " (handled per AdRequest on Android)");
		}

		if (_data.containsKey(PERSONALIZATION_STATE_PROPERTY)) {
			int state = getPublisherPrivacyPersonalizationState();
			switch (state) {
				case 1 -> builder.setPublisherPrivacyPersonalizationState(RequestConfiguration.PublisherPrivacyPersonalizationState.ENABLED);
				case 2 -> builder.setPublisherPrivacyPersonalizationState(RequestConfiguration.PublisherPrivacyPersonalizationState.DISABLED);
				default -> builder.setPublisherPrivacyPersonalizationState(RequestConfiguration.PublisherPrivacyPersonalizationState.DEFAULT);
			}
		}

		ArrayList<String> testDeviceIds = new ArrayList<>();
		if (_data.containsKey(TEST_DEVICE_IDS_PROPERTY)) {
			String[] configuredIds = getTestDeviceIds();
			if (configuredIds != null) {
				testDeviceIds.addAll(Arrays.asList(configuredIds));
			}
		}

		if (!isReal()) {
			// Add emulator ID (equivalent to iOS kGADSimulatorID)
			testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);
			// Add hashed device ID (equivalent to iOS hashed device ID)
			testDeviceIds.add(GodotConverter.getAdMobDeviceId(activity));
			// Retrieve and add Advertising ID if tracking is not limited (mirroring iOS ATTrackingManager logic)
			// Note: getAdvertisingIdInfo() must NOT be called on the main thread to avoid ANR. For production, use async retrieval.
			try {
				AdvertisingIdClient.Info adInfo = AdvertisingIdClient.getAdvertisingIdInfo(activity);
				if (!adInfo.isLimitAdTrackingEnabled() && adInfo.getId() != null) {
					testDeviceIds.add(adInfo.getId());
					Log.d(LOG_TAG, "Added Advertising ID as test device: " + adInfo.getId());
				} else {
					Log.d(LOG_TAG, "Advertising ID not added: limit tracking enabled or ID null");
				}
			} catch (IllegalStateException e) {
				Log.w(LOG_TAG, "Advertising ID retrieval blocked (likely main thread); using fallback hashed ID", e);
			} catch (Exception e) {
				Log.e(LOG_TAG, "Failed to retrieve Advertising ID", e);
			}
		}

		if (!testDeviceIds.isEmpty()) {
			builder.setTestDeviceIds(testDeviceIds);
			Log.d(LOG_TAG, "Set test device IDs: " + testDeviceIds);
		}

		return builder.build();
	}
}
