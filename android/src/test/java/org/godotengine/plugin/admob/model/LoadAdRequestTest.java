//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.godotengine.godot.Dictionary;
import org.godotengine.plugin.admob.fixture.AdRequestFixtures;
import org.junit.jupiter.api.Test;

/**
 * Unit tests for {@link LoadAdRequest}.
 *
 * <p>All tests are pure-JVM: no Android framework or GMS SDK involved. The
 * {@link com.google.android.gms.ads.AdRequest} builder is exercised elsewhere via
 * integration tests; here we verify the Dictionary-parsing contract.
 */
public class LoadAdRequestTest {

	// -- isValid ---------------------------------------------------------------

	@Test
	public void isValid_withAdUnitId_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertTrue(request.isValid());
	}

	@Test
	public void isValid_withoutAdUnitId_returnsFalse() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.emptyRequest());
		assertFalse(request.isValid());
	}

	@Test
	public void isValid_onlyOtherKeys_returnsFalse() {
		Dictionary d = new Dictionary();
		d.put("ad_size", "BANNER");
		d.put("ad_position", "TOP");
		LoadAdRequest request = new LoadAdRequest(d);
		assertFalse(request.isValid());
	}

	// -- getAdUnitId -----------------------------------------------------------

	@Test
	public void getAdUnitId_returnsStoredValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(AdRequestFixtures.TEST_AD_UNIT_ID, request.getAdUnitId());
	}

	// -- ad size ---------------------------------------------------------------

	@Test
	public void hasAdSize_whenPresent_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertTrue(request.hasAdSize());
	}

	@Test
	public void hasAdSize_whenAbsent_returnsFalse() {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", AdRequestFixtures.TEST_AD_UNIT_ID);
		LoadAdRequest request = new LoadAdRequest(d);
		assertFalse(request.hasAdSize());
	}

	@Test
	public void getAdSize_returnsStoredValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals("BANNER", request.getAdSize());
	}

	@Test
	public void getAdSize_inlineAdaptive_returnsStoredValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.inlineAdaptiveRequest(320, 90));
		assertEquals("INLINE_ADAPTIVE", request.getAdSize());
	}

	// -- adaptive width / max height -------------------------------------------

	@Test
	public void getAdaptiveWidth_whenAbsent_returnsMinusOne() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(-1, request.getAdaptiveWidth());
	}

	@Test
	public void getAdaptiveWidth_whenPresent_returnsValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.adaptiveBannerRequest(320));
		assertEquals(320, request.getAdaptiveWidth());
	}

	@Test
	public void getAdaptiveMaxHeight_whenAbsent_returnsMinusOne() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(-1, request.getAdaptiveMaxHeight());
	}

	@Test
	public void getAdaptiveMaxHeight_whenPresent_returnsValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.inlineAdaptiveRequest(320, 90));
		assertEquals(90, request.getAdaptiveMaxHeight());
	}

	// -- ad position -----------------------------------------------------------

	@Test
	public void hasAdPosition_whenPresent_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.bannerRequestWithPosition("BOTTOM"));
		assertTrue(request.hasAdPosition());
	}

	@Test
	public void hasAdPosition_whenAbsent_returnsFalse() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertFalse(request.hasAdPosition());
	}

	@Test
	public void getAdPosition_returnsStoredValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.bannerRequestWithPosition("BOTTOM"));
		assertEquals("BOTTOM", request.getAdPosition());
	}

	@Test
	public void getAdPosition_allPositionValues_roundTrip() {
		String[] positions = {"TOP", "BOTTOM", "LEFT", "RIGHT",
				"TOP_LEFT", "TOP_RIGHT", "BOTTOM_LEFT", "BOTTOM_RIGHT", "CENTER", "CUSTOM"};
		for (String pos : positions) {
			LoadAdRequest r = new LoadAdRequest(AdRequestFixtures.bannerRequestWithPosition(pos));
			assertEquals(pos, r.getAdPosition(), "Round-trip failed for " + pos);
		}
	}

	// -- collapsible position --------------------------------------------------

	@Test
	public void hasCollapsiblePosition_whenPresent_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.collapsibleBannerRequest("BOTTOM"));
		assertTrue(request.hasCollapsiblePosition());
	}

	@Test
	public void hasCollapsiblePosition_whenAbsent_returnsFalse() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertFalse(request.hasCollapsiblePosition());
	}

	@Test
	public void getCollapsiblePosition_returnsStoredValue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.collapsibleBannerRequest("TOP"));
		assertEquals("TOP", request.getCollapsiblePosition());
	}

	// -- anchor to safe area ---------------------------------------------------

	@Test
	public void doAnchorToSafeArea_whenAbsent_returnsFalse() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertFalse(request.doAnchorToSafeArea());
	}

	@Test
	public void doAnchorToSafeArea_whenTrue_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.anchoredBannerRequest());
		assertTrue(request.doAnchorToSafeArea());
	}

	@Test
	public void doAnchorToSafeArea_whenExplicitlyFalse_returnsFalse() {
		Dictionary d = AdRequestFixtures.minimalBannerRequest();
		d.put("anchor_to_safe_area", false);
		LoadAdRequest request = new LoadAdRequest(d);
		assertFalse(request.doAnchorToSafeArea());
	}

	// -- generateAdId ----------------------------------------------------------

	@Test
	public void generateAdId_sequence1_formatsAdUnitIdDashOne() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(AdRequestFixtures.TEST_AD_UNIT_ID + "-1", request.generateAdId(1));
	}

	@Test
	public void generateAdId_sequence42_formatsAdUnitIdDash42() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(AdRequestFixtures.TEST_AD_UNIT_ID + "-42", request.generateAdId(42));
	}

	@Test
	public void generateAdId_sequenceZero_formatsAdUnitIdDashZero() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(AdRequestFixtures.TEST_AD_UNIT_ID + "-0", request.generateAdId(0));
	}

	@Test
	public void generateAdId_calledTwice_sameSequence_returnsSameId() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertEquals(request.generateAdId(7), request.generateAdId(7));
	}

	// -- server-side verification options -------------------------------------

	@Test
	public void hasServerSideVerificationOptions_neitherKey_returnsFalse() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
		assertFalse(request.hasServerSideVerificationOptions());
	}

	@Test
	public void hasServerSideVerificationOptions_userIdOnly_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(
				AdRequestFixtures.rewardedRequestWithUserId("user-123"));
		assertTrue(request.hasServerSideVerificationOptions());
	}

	@Test
	public void hasServerSideVerificationOptions_bothKeys_returnsTrue() {
		LoadAdRequest request = new LoadAdRequest(
				AdRequestFixtures.rewardedRequestWithSsv("user-42", "level=5"));
		assertTrue(request.hasServerSideVerificationOptions());
	}

	@Test
	public void hasServerSideVerificationOptions_customDataOnly_returnsTrue() {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", AdRequestFixtures.TEST_AD_UNIT_ID);
		d.put("custom_data", "some-custom-data");
		LoadAdRequest request = new LoadAdRequest(d);
		assertTrue(request.hasServerSideVerificationOptions());
	}

	// -- getRawData ------------------------------------------------------------

	@Test
	public void getRawData_returnsExactSameDictionaryInstance() {
		Dictionary original = AdRequestFixtures.minimalBannerRequest();
		LoadAdRequest request = new LoadAdRequest(original);
		assertSame(original, request.getRawData());
	}

	// -- combined / multi-field scenarios -------------------------------------

	@Test
	public void fullBannerRequest_allGettersReturnCorrectValues() {
		LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.fullBannerRequest());
		assertTrue(request.isValid());
		assertEquals(AdRequestFixtures.TEST_AD_UNIT_ID, request.getAdUnitId());
		assertEquals("BANNER", request.getAdSize());
		assertEquals("BOTTOM", request.getAdPosition());
		assertTrue(request.doAnchorToSafeArea());
	}
}
