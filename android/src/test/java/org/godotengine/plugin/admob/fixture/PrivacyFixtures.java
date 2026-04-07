//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.fixture;

import org.godotengine.godot.Dictionary;

/**
 * Central factory for privacy-related test Dictionaries used by
 * {@link org.godotengine.plugin.admob.mediation.PrivacySettingsTest} and
 * {@link org.godotengine.plugin.admob.model.ConsentConfigurationTest}.
 */
public final class PrivacyFixtures {

	private PrivacyFixtures() {
	}

	// -- PrivacySettings dictionaries ------------------------------------------

	public static Dictionary gdprOnly(boolean hasConsent) {
		Dictionary d = new Dictionary();
		d.put("has_gdpr_consent", hasConsent);
		return d;
	}

	public static Dictionary ccpaOnly(boolean hasSaleConsent) {
		Dictionary d = new Dictionary();
		d.put("has_ccpa_sale_consent", hasSaleConsent);
		return d;
	}

	public static Dictionary ageRestrictedOnly(boolean isRestricted) {
		Dictionary d = new Dictionary();
		d.put("is_age_restricted_user", isRestricted);
		return d;
	}

	public static Dictionary withEnabledNetworks(String... networks) {
		Dictionary d = new Dictionary();
		d.put("enabled_networks", (Object[]) networks);
		return d;
	}

	public static Dictionary fullPrivacySettings(
			boolean gdpr, boolean ccpa, boolean ageRestricted, String... networks) {
		Dictionary d = new Dictionary();
		d.put("has_gdpr_consent", gdpr);
		d.put("has_ccpa_sale_consent", ccpa);
		d.put("is_age_restricted_user", ageRestricted);
		d.put("enabled_networks", (Object[]) networks);
		return d;
	}

	public static Dictionary empty() {
		return new Dictionary();
	}

	// -- ConsentConfiguration dictionaries ------------------------------------

	public static Dictionary realConsentConfig() {
		Dictionary d = new Dictionary();
		d.put("is_real", true);
		return d;
	}

	public static Dictionary debugConsentConfig(int debugGeography, String... deviceIds) {
		Dictionary d = new Dictionary();
		d.put("is_real", false);
		d.put("debug_geography", (long) debugGeography);
		d.put("test_device_hashed_ids", (Object[]) deviceIds);
		return d;
	}

	public static Dictionary consentConfigWithUnderAge(boolean underAge) {
		Dictionary d = new Dictionary();
		d.put("is_real", true);
		d.put("tag_for_under_age_of_consent", underAge);
		return d;
	}
}
