//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation;

import android.content.Context;
import android.util.Log;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.AdmobPlugin;
import org.godotengine.plugin.admob.mediation.network.MediationNetwork;
import org.godotengine.plugin.admob.mediation.network.MediationNetworkFactory;


public class PrivacySettings {
	private static final String CLASS_NAME = PrivacySettings.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	public interface PrivacySetter {
		void apply(PrivacySettings settings, Context context);
	}

	public static final String HAS_GDPR_CONSENT_PROPERTY = "has_gdpr_consent";
	public static final String IS_AGE_RESTRICTED_USER_PROPERTY = "is_age_restricted_user";
	public static final String HAS_CCPA_SALE_CONSENT_PROPERTY = "has_ccpa_sale_consent";
	public static final String ENABLED_NETWORKS_PROPERTY = "enabled_networks";

	private Dictionary rawData;

	public PrivacySettings(Dictionary rawData) {
		this.rawData = rawData;
	}

	public void applyPrivacySettings(Context context) {
		Log.d(LOG_TAG, "applyPrivacySettings()");
		Object[] enabledNetworksArray = getEnabledNetworks();
		Log.d(LOG_TAG, "Found " + enabledNetworksArray.length + " enabled networks to process");

		for (Object networkTag : enabledNetworksArray) {
			MediationNetwork network = MediationNetworkFactory.createNetwork((String) networkTag);
			if (network == null) {
				Log.w(LOG_TAG, "Mediation network not found for network tag '" + network + "'");
			} else {
				network.applyPrivacySettings(this, context);
			}
		}
	}

	// Predicates

	public boolean containsGdprConsentData() {
		return rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY);
	}

	public boolean containsAgeRestrictedUserData() {
		return rawData.containsKey(IS_AGE_RESTRICTED_USER_PROPERTY);
	}

	public boolean containsCcpaSaleConsentData() {
		return rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY);
	}

	// Getters

	public boolean hasGdprConsent() {
		return (boolean) rawData.get(HAS_GDPR_CONSENT_PROPERTY);
	}

	public boolean isAgeRestrictedUser() {
		return (boolean) rawData.get(IS_AGE_RESTRICTED_USER_PROPERTY);
	}

	public boolean hasCcpaSaleConsent() {
		return (boolean) rawData.get(HAS_CCPA_SALE_CONSENT_PROPERTY);
	}

	Object[] getEnabledNetworks() {
		return rawData.containsKey(ENABLED_NETWORKS_PROPERTY) ? (Object[]) rawData.get(ENABLED_NETWORKS_PROPERTY) : new String[0];
	}
}
