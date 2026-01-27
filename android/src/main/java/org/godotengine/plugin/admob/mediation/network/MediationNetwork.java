//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation.network;

import android.content.Context;
import android.util.Log;

import org.godotengine.plugin.admob.AdmobPlugin;
import org.godotengine.plugin.admob.mediation.PrivacySettings;

/**
 * The base class for any mediation network integrated into the system.
 *
 * Subclasses combine the responsibilities of providing the Google Mediation Adapter
 * class name and applying network-specific privacy settings.
 */
public abstract class MediationNetwork {
	private static final String CLASS_NAME = MediationNetwork.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	protected String tag; // network tag

	public MediationNetwork(String tag) {
		this.tag = tag;
	}

	/**
	 * Gets the fully qualified class name of the Google Mobile Ads mediation adapter
	 * required for this network (e.g., "com.google.ads.mediation.applovin.AppLovinMediationAdapter")
	 *
	 * @return The adapter class name string
	 */
	public abstract String getAdapterClassName();

	/**
	 * Applies the GDPR privacy settings to the specific network via reflection calls
	 *
	 * @param hasGdprConsent Whether user has given GDPR consent
	 * @param context The Android Context required for SDK calls
	 */
	protected abstract void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception;

	/**
	 * Applies the age restricted user privacy settings to the specific via reflection calls
	 *
	 * @param isAgeRestrictedUser Whether user is age-restricted
	 * @param context The Android Context required for SDK calls
	 */
	protected abstract void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception;

	/**
	 * Applies the CCPA privacy settings to the specific network via reflection calls
	 *
	 * @param hasCcpaConsent Whether user has given CCPA consent
	 * @param context The Android Context required for SDK calls
	 */
	protected abstract void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception;

	/**
	 * Applies the global privacy settings to the specific network SDK
	 *
	 * @param settings The consolidated privacy settings (GDPR, CCPA, etc.)
	 * @param context The Android Context required for SDK calls
	 */
	public void applyPrivacySettings(PrivacySettings settings, Context context) {
		if (settings.containsGdprConsentData()) {
			Log.d(LOG_TAG, "Applying GDPR settings for " + tag);
			try {
				applyGDPRSettings(settings.hasGdprConsent(), context);
				Log.d(LOG_TAG, "GDPR consent set successfully for " + tag);
			} catch (UnsupportedOperationException uoe) {
				Log.d(LOG_TAG, "GDPR settings not needed by " + tag);
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set GDPR settings for " + tag);
			}
		}

		if (settings.containsAgeRestrictedUserData()) {
			Log.d(LOG_TAG, "Applying age-restricted user settings for " + tag);
			try {
				applyAgeRestrictedUserSettings(settings.isAgeRestrictedUser(), context);
				Log.d(LOG_TAG, "Age-restricted user settings set successfully for " + tag);
			} catch (UnsupportedOperationException uoe) {
				Log.d(LOG_TAG, "Age-restricted user settings not needed by " + tag);
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set age-restricted user settings for " + tag);
			}
		}

		if (settings.containsCcpaSaleConsentData()) {
			Log.d(LOG_TAG, "Applying CCPA settings for " + tag);
			try {
				applyCCPASettings(settings.hasCcpaSaleConsent(), context);
				Log.d(LOG_TAG, "CCPA sale consent set successfully for " + tag);
			} catch (UnsupportedOperationException uoe) {
				Log.d(LOG_TAG, "CCPA settings not needed by " + tag);
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set CCPA settings for " + tag);
			}
		}
	}
}
