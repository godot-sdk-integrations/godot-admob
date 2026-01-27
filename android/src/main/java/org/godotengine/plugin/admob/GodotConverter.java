//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.provider.Settings;
import android.util.Log;

import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.ump.FormError;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Locale;

import org.godotengine.godot.Dictionary;


public class GodotConverter {
	private static final String LOG_TAG = AdmobPlugin.LOG_TAG + "::" + GodotConverter.class.getSimpleName();

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
