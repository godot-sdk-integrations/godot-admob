//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.fixture;

import org.godotengine.godot.Dictionary;

/**
 * Central factory for {@link org.godotengine.plugin.admob.model.LoadAdRequest} test data.
 *
 * <p>Every method returns a freshly-created Dictionary so tests are independent of each other.
 */
public final class AdRequestFixtures {

	/** Google test ad-unit ID (safe to use in tests – never generates real traffic). */
	public static final String TEST_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111";

	private AdRequestFixtures() {}

	// -- Banner ----------------------------------------------------------------

	public static Dictionary minimalBannerRequest() {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("ad_size", "BANNER");
		return d;
	}

	public static Dictionary bannerRequestWithPosition(String position) {
		Dictionary d = minimalBannerRequest();
		d.put("ad_position", position);
		return d;
	}

	public static Dictionary anchoredBannerRequest() {
		Dictionary d = minimalBannerRequest();
		d.put("anchor_to_safe_area", true);
		return d;
	}

	public static Dictionary collapsibleBannerRequest(String collapsiblePosition) {
		Dictionary d = minimalBannerRequest();
		d.put("collapsible_position", collapsiblePosition);
		return d;
	}

	// -- Adaptive banner -------------------------------------------------------

	public static Dictionary adaptiveBannerRequest(int widthDp) {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("ad_size", "ADAPTIVE");
		d.put("adaptive_width", (long) widthDp);
		return d;
	}

	public static Dictionary inlineAdaptiveRequest(int widthDp, int maxHeightDp) {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("ad_size", "INLINE_ADAPTIVE");
		d.put("adaptive_width", (long) widthDp);
		d.put("adaptive_max_height", (long) maxHeightDp);
		return d;
	}

	// -- Rewarded / SSV --------------------------------------------------------

	public static Dictionary rewardedRequestWithUserId(String userId) {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("user_id", userId);
		return d;
	}

	public static Dictionary rewardedRequestWithSsv(String userId, String customData) {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("user_id", userId);
		d.put("custom_data", customData);
		return d;
	}

	// -- Keywords --------------------------------------------------------------

	public static Dictionary requestWithKeywords(String... keywords) {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("keywords", keywords);
		return d;
	}

	// -- Network extras --------------------------------------------------------

	/**
	 * Builds a request that contains a single network_extras entry.
	 *
	 * @param networkTag  e.g. "applovin"
	 * @param extraKey    param key inside the extras bundle
	 * @param extraValue  param value (String)
	 */
	public static Dictionary requestWithNetworkExtras(String networkTag, String extraKey, String extraValue) {
		Dictionary extras = new Dictionary();
		extras.put("network_tag", networkTag);
		Dictionary params = new Dictionary();
		params.put(extraKey, extraValue);
		extras.put("extras", params);

		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		d.put("network_extras", new Object[]{extras});
		return d;
	}

	// -- Edge-cases ------------------------------------------------------------

	/** A dictionary with no keys – {@link org.godotengine.plugin.admob.model.LoadAdRequest#isValid()} must return false. */
	public static Dictionary emptyRequest() {
		return new Dictionary();
	}

	/** Request with every optional field filled in. */
	public static Dictionary fullBannerRequest() {
		Dictionary d = minimalBannerRequest();
		d.put("ad_position", "BOTTOM");
		d.put("anchor_to_safe_area", true);
		d.put("request_agent", "godot-admob-plugin");
		d.put("keywords", new String[]{"game", "puzzle"});
		return d;
	}
}
