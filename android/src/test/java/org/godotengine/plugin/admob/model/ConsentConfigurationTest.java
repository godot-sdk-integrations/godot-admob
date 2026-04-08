//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.godotengine.godot.Dictionary;
import org.godotengine.plugin.admob.fixture.PrivacyFixtures;
import org.junit.jupiter.api.Test;

/**
 * Unit tests for the Dictionary-parsing layer of {@link ConsentConfiguration}.
 *
 * <p>{@link ConsentConfiguration#createConsentRequestParameters} requires an
 * {@link android.app.Activity} and is excluded – that logic lives in instrumented tests.
 */
public class ConsentConfigurationTest {

	// -- isReal ----------------------------------------------------------------

	@Test
	public void isReal_whenAbsent_returnsFalse() {
		ConsentConfiguration config = new ConsentConfiguration(new Dictionary());
		assertFalse(config.isReal());
	}

	@Test
	public void isReal_whenFalse_returnsFalse() {
		ConsentConfiguration config = new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(1));
		assertFalse(config.isReal());
	}

	@Test
	public void isReal_whenTrue_returnsTrue() {
		ConsentConfiguration config = new ConsentConfiguration(PrivacyFixtures.realConsentConfig());
		assertTrue(config.isReal());
	}

	// -- getTagForUnderAgeOfConsent --------------------------------------------

	@Test
	public void getTagForUnderAgeOfConsent_whenAbsent_returnsFalse() {
		ConsentConfiguration config = new ConsentConfiguration(new Dictionary());
		assertFalse(config.getTagForUnderAgeOfConsent());
	}

	@Test
	public void getTagForUnderAgeOfConsent_whenTrue_returnsTrue() {
		ConsentConfiguration config =
				new ConsentConfiguration(PrivacyFixtures.consentConfigWithUnderAge(true));
		assertTrue(config.getTagForUnderAgeOfConsent());
	}

	@Test
	public void getTagForUnderAgeOfConsent_whenFalse_returnsFalse() {
		ConsentConfiguration config =
				new ConsentConfiguration(PrivacyFixtures.consentConfigWithUnderAge(false));
		assertFalse(config.getTagForUnderAgeOfConsent());
	}

	// -- toString --------------------------------------------------------------

	@Test
	public void toString_doesNotThrow() {
		ConsentConfiguration config = new ConsentConfiguration(
				PrivacyFixtures.debugConsentConfig(1, "HASHED_DEVICE_1"));
		// Verify toString doesn't throw; we only check it returns something non-null.
		String result = config.toString();
		assertTrue(result != null && !result.isEmpty());
	}

	@Test
	public void toString_withNoTestDeviceIds_doesNotThrow() {
		ConsentConfiguration config = new ConsentConfiguration(PrivacyFixtures.realConsentConfig());
		String result = config.toString();
		assertTrue(result != null && !result.isEmpty());
	}

	// -- combined scenarios ----------------------------------------------------

	@Test
	public void debugConfig_withMultipleDeviceIds_doesNotThrowOnToString() {
		ConsentConfiguration config = new ConsentConfiguration(
				PrivacyFixtures.debugConsentConfig(2, "DEV1", "DEV2", "DEV3"));
		config.toString(); // must not throw
	}

	@Test
	public void emptyDictionary_allGettersReturnSafeDefaults() {
		ConsentConfiguration config = new ConsentConfiguration(new Dictionary());
		assertFalse(config.isReal());
		assertFalse(config.getTagForUnderAgeOfConsent());
	}
}
