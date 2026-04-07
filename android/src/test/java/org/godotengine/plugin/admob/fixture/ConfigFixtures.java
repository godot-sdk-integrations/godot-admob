//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.fixture;

import org.godotengine.godot.Dictionary;

/**
 * Central factory for {@link org.godotengine.plugin.admob.model.AdmobConfiguration} test Dictionaries.
 */
public final class ConfigFixtures {

	private ConfigFixtures() {
	}

	/** Full test/debug configuration. */
	public static Dictionary testConfig() {
		Dictionary d = new Dictionary();
		d.put("is_real", false);
		d.put("max_ad_content_rating", "G");
		d.put("tag_for_child_directed_treatment", 0L);
		d.put("tag_for_under_age_of_consent", 0L);
		d.put("first_party_id_enabled", false);
		d.put("personalization_state", 0L);          // 0 = DEFAULT
		d.put("test_device_ids", new String[]{});
		return d;
	}

	/** Full production configuration with all optional fields. */
	public static Dictionary prodConfig() {
		Dictionary d = new Dictionary();
		d.put("is_real", true);
		d.put("max_ad_content_rating", "MA");
		d.put("tag_for_child_directed_treatment", 1L);
		d.put("tag_for_under_age_of_consent", 1L);
		d.put("first_party_id_enabled", true);
		d.put("personalization_state", 1L);          // 1 = ENABLED
		d.put("test_device_ids", new String[]{"TEST_DEVICE_1"});
		return d;
	}

	/** Only the mandatory {@code is_real} flag. */
	public static Dictionary minimalConfig(boolean isReal) {
		Dictionary d = new Dictionary();
		d.put("is_real", isReal);
		return d;
	}

	/** Config with personalization disabled. */
	public static Dictionary configWithPersonalizationDisabled() {
		Dictionary d = minimalConfig(true);
		d.put("personalization_state", 2L);          // 2 = DISABLED
		return d;
	}

	/** Config with content rating set. */
	public static Dictionary configWithRating(String rating) {
		Dictionary d = minimalConfig(false);
		d.put("max_ad_content_rating", rating);
		return d;
	}
}
