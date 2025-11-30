//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import android.app.Activity;
import android.provider.Settings;
import android.util.Log;

import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentRequestParameters;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.AdmobPlugin;
import org.godotengine.plugin.admob.GodotConverter;


public class ConsentConfiguration {
	private static final String CLASS_NAME = ConsentConfiguration.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private static final String IS_REAL_PROPERTY = "is_real";
	private static final String TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY = "tag_for_under_age_of_consent";
	private static final String DEBUG_GEOGRAPHY_PROPERTY = "debug_geography";
	private static final String TEST_DEVICE_HASHED_IDS_PROPERTY = "test_device_hashed_ids";

	private Dictionary _data;

	public ConsentConfiguration(Dictionary data) {
		this._data = data;
	}

	public boolean isReal() {
		Object val = _data.get(IS_REAL_PROPERTY);
		return val == null ? false : (boolean) val;
	}

	public boolean getTagForUnderAgeOfConsent() {
		Object val = _data.get(TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY);
		return val == null ? false : (boolean) val;
	}

	public ConsentRequestParameters createConsentRequestParameters(Activity activity) {
		ConsentRequestParameters.Builder builder = new ConsentRequestParameters.Builder();

		if (_data.containsKey(TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY)) {
			builder.setTagForUnderAgeOfConsent(getTagForUnderAgeOfConsent());
		}

		if (_data.containsKey(IS_REAL_PROPERTY) && !isReal()) {
			Log.d(LOG_TAG, "Creating debug settings for user consent.");
			ConsentDebugSettings.Builder debugSettingsBuilder = new ConsentDebugSettings.Builder(activity);

			if (_data.containsKey(DEBUG_GEOGRAPHY_PROPERTY)) {
				Object debugGeographyObj = _data.get(DEBUG_GEOGRAPHY_PROPERTY);
				if (debugGeographyObj instanceof Integer) {
					int debugGeography = (int) debugGeographyObj;
					Log.d(LOG_TAG, "Setting debug geography to: " + debugGeography);
					debugSettingsBuilder.setDebugGeography(debugGeography);
				} else {
					Log.e(LOG_TAG, "Invalid " + DEBUG_GEOGRAPHY_PROPERTY + " type: " + 
						(debugGeographyObj != null ? debugGeographyObj.getClass().getSimpleName() : "null") +
						", value: " + debugGeographyObj);
				}
			} else {
				Log.w(LOG_TAG, DEBUG_GEOGRAPHY_PROPERTY + " key not found in dictionary");
			}

			if (_data.containsKey(TEST_DEVICE_HASHED_IDS_PROPERTY)) {
				Object deviceIdsObj = _data.get(TEST_DEVICE_HASHED_IDS_PROPERTY);
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
					Log.e(LOG_TAG, "Invalid " + TEST_DEVICE_HASHED_IDS_PROPERTY + " type: " + 
						(deviceIdsObj != null ? deviceIdsObj.getClass().getName() : "null") +
						", value: " + deviceIdsObj);
				}
			} else {
				Log.w(LOG_TAG, TEST_DEVICE_HASHED_IDS_PROPERTY + " key not found in dictionary");
			}

			debugSettingsBuilder.addTestDeviceHashedId(GodotConverter.getAdMobDeviceId(activity));

			builder.setConsentDebugSettings(debugSettingsBuilder.build());
		}

		return builder.build();
	}

	public String toString() {
		StringBuilder sb = new StringBuilder(CLASS_NAME);
		sb.append("{");
		sb.append(IS_REAL_PROPERTY).append("=").append(valueToString(IS_REAL_PROPERTY)).append(", ");
		sb.append(TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY).append("=").append(valueToString(TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY)).append(", ");
		sb.append(DEBUG_GEOGRAPHY_PROPERTY).append("=").append(valueToString(DEBUG_GEOGRAPHY_PROPERTY)).append(", ");
		sb.append(TEST_DEVICE_HASHED_IDS_PROPERTY);
		if (_data.containsKey(TEST_DEVICE_HASHED_IDS_PROPERTY)) {
			sb.append("=[");
			Object deviceIdsObj = _data.get(TEST_DEVICE_HASHED_IDS_PROPERTY);
			if (deviceIdsObj instanceof Object[]) {
				boolean isFirst = true;
				for (Object deviceId : (Object[]) deviceIdsObj) {
					if (deviceId instanceof String) {
						if (isFirst) isFirst = false; else sb.append(", ");
						sb.append((String) deviceId);
					} else {
						Log.w(LOG_TAG, "invalid id:" + deviceId);
					}
				}
			} else {
				sb.append("invalid array");
			}
			sb.append("]");
		} else {
			sb.append("null");
		} 
		sb.append("}");
		return sb.toString();
	}

	private String valueToString(String tag) {
		return _data.containsKey(tag) ? "" + _data.get(tag) : "null";
	}
}
