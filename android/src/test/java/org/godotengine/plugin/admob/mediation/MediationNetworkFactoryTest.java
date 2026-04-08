//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.godotengine.plugin.admob.mediation.network.ApplovinMediationNetwork;
import org.godotengine.plugin.admob.mediation.network.ChartboostMediationNetwork;
import org.godotengine.plugin.admob.mediation.network.MediationNetwork;
import org.godotengine.plugin.admob.mediation.network.MediationNetworkFactory;
import org.junit.jupiter.api.Test;

/**
 * Unit tests for {@link MediationNetworkFactory}.
 *
 * <p>All tests are pure-JVM – no Android framework needed.
 */
public class MediationNetworkFactoryTest {

	// -- createNetwork – null / empty / unknown --------------------------------

	@Test
	public void createNetwork_nullTag_returnsNull() {
		assertNull(MediationNetworkFactory.createNetwork(null));
	}

	@Test
	public void createNetwork_emptyString_returnsNull() {
		assertNull(MediationNetworkFactory.createNetwork(""));
	}

	@Test
	public void createNetwork_whitespaceOnly_returnsNull() {
		assertNull(MediationNetworkFactory.createNetwork("   "));
	}

	@Test
	public void createNetwork_unknownTag_returnsNull() {
		assertNull(MediationNetworkFactory.createNetwork("nonexistent_network"));
	}

	// -- createNetwork – known networks ---------------------------------------

	@Test
	public void createNetwork_applovin_returnsApplovinInstance() {
		MediationNetwork network = MediationNetworkFactory.createNetwork("applovin");
		assertNotNull(network);
		assertTrue(network instanceof ApplovinMediationNetwork);
	}

	@Test
	public void createNetwork_chartboost_returnsChartboostInstance() {
		MediationNetwork network = MediationNetworkFactory.createNetwork("chartboost");
		assertNotNull(network);
		assertTrue(network instanceof ChartboostMediationNetwork);
	}

	@Test
	public void createNetwork_knownTags_allReturnNonNull() {
		String[] knownTags = {
			"google", "applovin", "chartboost", "dtexchange", "imobile",
			"inmobi", "ironsource", "liftoff", "line", "maio",
			"meta", "mintegral", "moloco", "mytarget", "pangle", "unity"
		};
		for (String tag : knownTags) {
			assertNotNull(MediationNetworkFactory.createNetwork(tag),
					"createNetwork(\"" + tag + "\") must not return null");
		}
	}

	// -- case-insensitivity ----------------------------------------------------

	@Test
	public void createNetwork_uppercaseApplovin_returnsApplovinInstance() {
		MediationNetwork network = MediationNetworkFactory.createNetwork("APPLOVIN");
		assertNotNull(network);
		assertTrue(network instanceof ApplovinMediationNetwork);
	}

	@Test
	public void createNetwork_mixedCaseChartboost_returnsChartboostInstance() {
		MediationNetwork network = MediationNetworkFactory.createNetwork("ChartBoost");
		assertNotNull(network);
		assertTrue(network instanceof ChartboostMediationNetwork);
	}

	// -- createNetwork – each call returns a fresh instance -------------------

	@Test
	public void createNetwork_calledTwice_returnsDifferentInstances() {
		MediationNetwork first = MediationNetworkFactory.createNetwork("applovin");
		MediationNetwork second = MediationNetworkFactory.createNetwork("applovin");
		assertNotNull(first);
		assertNotNull(second);
		assertTrue(first != second);
	}

	// -- getTagForAdapterClass -------------------------------------------------

	@Test
	public void getTagForAdapterClass_applovinAdapter_returnsApplovinTag() {
		String tag = MediationNetworkFactory.getTagForAdapterClass(
				ApplovinMediationNetwork.ADAPTER_CLASS);
		assertEquals(ApplovinMediationNetwork.TAG, tag);
	}

	@Test
	public void getTagForAdapterClass_chartboostAdapter_returnsChartboostTag() {
		String tag = MediationNetworkFactory.getTagForAdapterClass(
				ChartboostMediationNetwork.ADAPTER_CLASS);
		assertEquals(ChartboostMediationNetwork.TAG, tag);
	}

	@Test
	public void getTagForAdapterClass_unknownClass_returnsNull() {
		assertNull(MediationNetworkFactory.getTagForAdapterClass(
				"com.example.unknown.Adapter"));
	}

	@Test
	public void getTagForAdapterClass_null_returnsNull() {
		assertNull(MediationNetworkFactory.getTagForAdapterClass(null));
	}

	// -- adapter class names are non-null/non-empty ----------------------------

	@Test
	public void getAdapterClassName_applovin_isNonEmpty() {
		MediationNetwork network = MediationNetworkFactory.createNetwork("applovin");
		assertNotNull(network);
		String className = network.getAdapterClassName();
		assertNotNull(className);
		assertTrue(className.length() > 0);
	}

	@Test
	public void getAdapterClassName_chartboost_isNonEmpty() {
		MediationNetwork network = MediationNetworkFactory.createNetwork("chartboost");
		assertNotNull(network);
		String className = network.getAdapterClassName();
		assertNotNull(className);
		assertTrue(className.length() > 0);
	}

	@Test
	public void allKnownNetworks_adapterClassNameNonEmpty() {
		String[] knownTags = {
			"google", "applovin", "chartboost", "dtexchange", "imobile",
			"inmobi", "ironsource", "liftoff", "line", "maio",
			"meta", "mintegral", "moloco", "mytarget", "pangle", "unity"
		};
		for (String tag : knownTags) {
			MediationNetwork network = MediationNetworkFactory.createNetwork(tag);
			assertNotNull(network);
			String className = network.getAdapterClassName();
			assertNotNull(className, "Adapter class for '" + tag + "' must not be null");
			assertTrue(className.length() > 0, "Adapter class for '" + tag + "' must not be empty");
		}
	}

	// -- round-trip: tag -> adapter class -> tag --------------------------------

	@Test
	public void applovin_tagAdapterRoundTrip() {
		MediationNetwork network = MediationNetworkFactory.createNetwork(ApplovinMediationNetwork.TAG);
		assertNotNull(network);
		String adapterClass = network.getAdapterClassName();
		String recoveredTag = MediationNetworkFactory.getTagForAdapterClass(adapterClass);
		assertEquals(ApplovinMediationNetwork.TAG, recoveredTag);
	}

	@Test
	public void chartboost_tagAdapterRoundTrip() {
		MediationNetwork network = MediationNetworkFactory.createNetwork(ChartboostMediationNetwork.TAG);
		assertNotNull(network);
		String adapterClass = network.getAdapterClassName();
		String recoveredTag = MediationNetworkFactory.getTagForAdapterClass(adapterClass);
		assertEquals(ChartboostMediationNetwork.TAG, recoveredTag);
	}
}
