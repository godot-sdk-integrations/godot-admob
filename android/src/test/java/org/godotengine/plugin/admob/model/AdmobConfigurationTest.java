//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.godotengine.godot.Dictionary;
import org.godotengine.plugin.admob.fixture.ConfigFixtures;
import org.junit.jupiter.api.Test;

/**
 * Unit tests for the Dictionary-parsing layer of {@link AdmobConfiguration}.
 *
 * <p>Tests that call {@link AdmobConfiguration#createRequestConfiguration} require an
 * {@link android.app.Activity} and are therefore intentionally excluded here; those belong
 * in the Robolectric or instrumented suite.
 */
public class AdmobConfigurationTest {

	// -- isReal ----------------------------------------------------------------

	@Test
	public void isReal_whenFalse_returnsFalse() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.minimalConfig(false));
		assertFalse(config.isReal());
	}

	@Test
	public void isReal_whenTrue_returnsTrue() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.minimalConfig(true));
		assertTrue(config.isReal());
	}

	// -- max content rating ----------------------------------------------------

	@Test
	public void getMaxContentRating_returnsValueFromDictionary() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		assertEquals("G", config.getMaxContentRating());
	}

	@Test
	public void getMaxContentRating_multipleRatings_roundTrip() {
		for (String rating : new String[]{"G", "PG", "T", "MA"}) {
			AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.configWithRating(rating));
			assertEquals(rating, config.getMaxContentRating());
		}
	}

	// -- child directed treatment ----------------------------------------------

	@Test
	public void getChildDirectedTreatment_zeroValue_returnsZero() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		assertEquals(0, config.getChildDirectedTreatment());
	}

	@Test
	public void getChildDirectedTreatment_oneValue_returnsOne() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
		assertEquals(1, config.getChildDirectedTreatment());
	}

	// -- under age of consent --------------------------------------------------

	@Test
	public void getUnderAgeOfConsent_zeroValue_returnsZero() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		assertEquals(0, config.getUnderAgeOfConsent());
	}

	@Test
	public void getUnderAgeOfConsent_oneValue_returnsOne() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
		assertEquals(1, config.getUnderAgeOfConsent());
	}

	// -- first party ID --------------------------------------------------------

	@Test
	public void getFirstPartyIdEnabled_false_returnsFalse() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		assertFalse(config.getFirstPartyIdEnabled());
	}

	@Test
	public void getFirstPartyIdEnabled_true_returnsTrue() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
		assertTrue(config.getFirstPartyIdEnabled());
	}

	// -- publisher privacy personalization state -------------------------------

	@Test
	public void getPublisherPrivacyPersonalizationState_zero_returnsZero() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		assertEquals(0, config.getPublisherPrivacyPersonalizationState());
	}

	@Test
	public void getPublisherPrivacyPersonalizationState_enabled_returnsOne() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
		assertEquals(1, config.getPublisherPrivacyPersonalizationState());
	}

	@Test
	public void getPublisherPrivacyPersonalizationState_disabled_returnsTwo() {
		AdmobConfiguration config =
				new AdmobConfiguration(ConfigFixtures.configWithPersonalizationDisabled());
		assertEquals(2, config.getPublisherPrivacyPersonalizationState());
	}

	// -- test device IDs -------------------------------------------------------

	@Test
	public void getTestDeviceIds_emptyArray_returnsEmptyArray() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		String[] ids = config.getTestDeviceIds();
		assertNotNull(ids);
		assertEquals(0, ids.length);
	}

	@Test
	public void getTestDeviceIds_withOneId_returnsThatId() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
		String[] ids = config.getTestDeviceIds();
		assertNotNull(ids);
		assertEquals(1, ids.length);
		assertEquals("TEST_DEVICE_1", ids[0]);
	}

	// -- test/production config completeness -----------------------------------

	@Test
	public void testConfig_allGettersDoNotThrow() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.testConfig());
		// If any getter throws (e.g. wrong cast), the test fails.
		assertFalse(config.isReal());
		assertNotNull(config.getMaxContentRating());
		config.getChildDirectedTreatment();
		config.getUnderAgeOfConsent();
		assertFalse(config.getFirstPartyIdEnabled());
		config.getPublisherPrivacyPersonalizationState();
		assertNotNull(config.getTestDeviceIds());
	}

	@Test
	public void prodConfig_allGettersDoNotThrow() {
		AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
		assertTrue(config.isReal());
		assertNotNull(config.getMaxContentRating());
		config.getChildDirectedTreatment();
		config.getUnderAgeOfConsent();
		assertTrue(config.getFirstPartyIdEnabled());
		config.getPublisherPrivacyPersonalizationState();
	}

	// -- long-to-int coercion --------------------------------------------------

	@Test
	public void integerFields_storedAsLong_convertedCorrectly() {
		// Godot passes integer values as Long on the Java side; verify the toInt() helper works.
		Dictionary d = new Dictionary();
		d.put("is_real", false);
		d.put("tag_for_child_directed_treatment", Long.MAX_VALUE); // edge value
		// We can't call getChildDirectedTreatment() for MAX_VALUE meaningfully,
		// but we verify it doesn't throw.
		AdmobConfiguration config = new AdmobConfiguration(d);
		config.getChildDirectedTreatment(); // must not throw ClassCastException
	}
}
