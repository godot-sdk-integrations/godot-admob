//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.godotengine.plugin.admob.fixture.PrivacyFixtures;
import org.junit.jupiter.api.Test;

/**
 * Unit tests for {@link PrivacySettings} – pure Dictionary-parsing logic only.
 *
 * <p>{@link PrivacySettings#applyPrivacySettings} makes reflection calls into third-party SDKs
 * and is excluded from the local JVM suite; it belongs in instrumented tests.
 */
public class PrivacySettingsTest {

	// -- containsGdprConsentData -----------------------------------------------

	@Test
	public void containsGdprConsentData_whenPresent_returnsTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.gdprOnly(true));
		assertTrue(settings.containsGdprConsentData());
	}

	@Test
	public void containsGdprConsentData_whenAbsent_returnsFalse() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.empty());
		assertFalse(settings.containsGdprConsentData());
	}

	// -- hasGdprConsent --------------------------------------------------------

	@Test
	public void hasGdprConsent_trueValue_returnsTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.gdprOnly(true));
		assertTrue(settings.hasGdprConsent());
	}

	@Test
	public void hasGdprConsent_falseValue_returnsFalse() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.gdprOnly(false));
		assertFalse(settings.hasGdprConsent());
	}

	// -- containsAgeRestrictedUserData -----------------------------------------

	@Test
	public void containsAgeRestrictedUserData_whenPresent_returnsTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.ageRestrictedOnly(true));
		assertTrue(settings.containsAgeRestrictedUserData());
	}

	@Test
	public void containsAgeRestrictedUserData_whenAbsent_returnsFalse() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.empty());
		assertFalse(settings.containsAgeRestrictedUserData());
	}

	// -- isAgeRestrictedUser ---------------------------------------------------

	@Test
	public void isAgeRestrictedUser_trueValue_returnsTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.ageRestrictedOnly(true));
		assertTrue(settings.isAgeRestrictedUser());
	}

	@Test
	public void isAgeRestrictedUser_falseValue_returnsFalse() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.ageRestrictedOnly(false));
		assertFalse(settings.isAgeRestrictedUser());
	}

	// -- containsCcpaSaleConsentData -------------------------------------------

	@Test
	public void containsCcpaSaleConsentData_whenPresent_returnsTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.ccpaOnly(true));
		assertTrue(settings.containsCcpaSaleConsentData());
	}

	@Test
	public void containsCcpaSaleConsentData_whenAbsent_returnsFalse() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.empty());
		assertFalse(settings.containsCcpaSaleConsentData());
	}

	// -- hasCcpaSaleConsent ----------------------------------------------------

	@Test
	public void hasCcpaSaleConsent_trueValue_returnsTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.ccpaOnly(true));
		assertTrue(settings.hasCcpaSaleConsent());
	}

	@Test
	public void hasCcpaSaleConsent_falseValue_returnsFalse() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.ccpaOnly(false));
		assertFalse(settings.hasCcpaSaleConsent());
	}

	// -- getEnabledNetworks ----------------------------------------------------

	@Test
	public void getEnabledNetworks_whenAbsent_returnsEmptyArray() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.empty());
		Object[] networks = settings.getEnabledNetworks();
		assertNotNull(networks);
		assertEquals(0, networks.length);
	}

	@Test
	public void getEnabledNetworks_whenEmpty_returnsEmptyArray() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.withEnabledNetworks());
		Object[] networks = settings.getEnabledNetworks();
		assertNotNull(networks);
		assertEquals(0, networks.length);
	}

	@Test
	public void getEnabledNetworks_singleNetwork_returnsOneEntry() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.withEnabledNetworks("applovin"));
		Object[] networks = settings.getEnabledNetworks();
		assertEquals(1, networks.length);
		assertEquals("applovin", networks[0]);
	}

	@Test
	public void getEnabledNetworks_multipleNetworks_returnsAllEntries() {
		PrivacySettings settings = new PrivacySettings(
				PrivacyFixtures.withEnabledNetworks("applovin", "chartboost", "meta"));
		Object[] networks = settings.getEnabledNetworks();
		assertEquals(3, networks.length);
	}

	// -- full settings object --------------------------------------------------

	@Test
	public void fullPrivacySettings_allPredicatesReturnTrue() {
		PrivacySettings settings = new PrivacySettings(
				PrivacyFixtures.fullPrivacySettings(true, false, true, "applovin"));
		assertTrue(settings.containsGdprConsentData());
		assertTrue(settings.containsCcpaSaleConsentData());
		assertTrue(settings.containsAgeRestrictedUserData());
	}

	@Test
	public void fullPrivacySettings_valuesAreReadCorrectly() {
		PrivacySettings settings = new PrivacySettings(
				PrivacyFixtures.fullPrivacySettings(true, false, true, "applovin", "unity"));
		assertTrue(settings.hasGdprConsent());
		assertFalse(settings.hasCcpaSaleConsent());
		assertTrue(settings.isAgeRestrictedUser());
		assertEquals(2, settings.getEnabledNetworks().length);
	}

	// -- empty dictionary – no predicates trigger ------------------------------

	@Test
	public void emptyDictionary_noPredicatesReturnTrue() {
		PrivacySettings settings = new PrivacySettings(PrivacyFixtures.empty());
		assertFalse(settings.containsGdprConsentData());
		assertFalse(settings.containsAgeRestrictedUserData());
		assertFalse(settings.containsCcpaSaleConsentData());
		assertEquals(0, settings.getEnabledNetworks().length);
	}
}
