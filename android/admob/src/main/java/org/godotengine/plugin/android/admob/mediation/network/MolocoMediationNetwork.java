//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;
import android.util.Log;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.AdmobPlugin;
import org.godotengine.plugin.android.admob.mediation.PrivacySettings;
import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class MolocoMediationNetwork extends MediationNetwork {
	private static final String CLASS_NAME = MolocoMediationNetwork.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	public static final String TAG = "moloco";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.moloco.MolocoMediationAdapter";

	public MolocoMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		// not used as GDPR is handled in the overridden applyPrivacySettings() method
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		// not used as age-restricted user setting is handled in the overridden applyPrivacySettings() method
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		// not used as CCPA is handled in the overridden applyPrivacySettings() method
	}

	@Override
	public void applyPrivacySettings(PrivacySettings settings, Context context) {
		Log.d(LOG_TAG, "Applying privacy settings for Moloco");

		try {
			/*
			 * PrivacySettings privacySettings = new PrivacySettings(
			 *           / isUserConsent /         false,
			 *           / isAgeRestrictedUser /   false,
			 *           / isDoNotSell /           true);
			 * MolocoPrivacy.setPrivacy(privacySettings);
			 */

			//  Get the required Classes using the fully qualified names
			Class<?> privacySettingsClass = Class.forName("com.moloco.sdk.publisher.privacy.MolocoPrivacy$PrivacySettings");
			Class<?> molocoPrivacyClass = Class.forName("com.moloco.sdk.publisher.privacy.MolocoPrivacy");

			// Instantiate PrivacySettings: new PrivacySettings(false, false, true) constructor
			Constructor<?> settingsConstructor = privacySettingsClass.getConstructor(
				Boolean.class, // isUserConsent
				Boolean.class, // isAgeRestrictedUser
				Boolean.class  // isDoNotSell
			);

			// Create the new object instance, passing the argument values
			Object privacySettingsInstance = settingsConstructor.newInstance(
				settings.containsGdprConsentData() ? settings.hasGdprConsent() : false,
				settings.containsAgeRestrictedUserData() ? settings.isAgeRestrictedUser() : false,
				settings.containsCcpaSaleConsentData() ? !settings.hasCcpaSaleConsent() : true
			);

			// Invoke MolocoPrivacy.setPrivacy(privacySettings)
			Method setPrivacyMethod = molocoPrivacyClass.getMethod("setPrivacy", privacySettingsClass);
			setPrivacyMethod.invoke(null, privacySettingsInstance);

			Log.d(LOG_TAG, "MolocoPrivacy.setPrivacy(new PrivacySettings(isUserConsent, isAgeRestrictedUser, isDoNotSell)) called successfully.");
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set GDPR settings for " + tag);
		}
	}
}
