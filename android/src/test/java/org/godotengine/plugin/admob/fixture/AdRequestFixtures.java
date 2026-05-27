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

	private AdRequestFixtures() {
	}

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

	// -- Native ad options -----------------------------------------------------

	/**
	 * Minimal native request with no option keys set — all native ad options should
	 * use their SDK defaults.
	 */
	public static Dictionary minimalNativeRequest() {
		Dictionary d = new Dictionary();
		d.put("ad_unit_id", TEST_AD_UNIT_ID);
		return d;
	}

	/**
	 * Native request with a specific {@code native_media_aspect_ratio} value.
	 *
	 * @param ratio one of "UNKNOWN", "ANY", "LANDSCAPE", "PORTRAIT", "SQUARE"
	 */
	public static Dictionary nativeRequestWithMediaAspectRatio(String ratio) {
		Dictionary d = minimalNativeRequest();
		d.put("native_media_aspect_ratio", ratio);
		return d;
	}

	/**
	 * Native request with {@code native_return_urls_for_image_assets} set.
	 *
	 * @param value true → SDK returns URLs; false → SDK returns pre-fetched Drawables (default)
	 */
	public static Dictionary nativeRequestWithReturnUrlsForImageAssets(boolean value) {
		Dictionary d = minimalNativeRequest();
		d.put("native_return_urls_for_image_assets", value);
		return d;
	}

	/**
	 * Native request with {@code native_request_multiple_images} set.
	 *
	 * @param value true → allow multiple images per slot; false → one image per slot (default)
	 */
	public static Dictionary nativeRequestWithRequestMultipleImages(boolean value) {
		Dictionary d = minimalNativeRequest();
		d.put("native_request_multiple_images", value);
		return d;
	}

	/**
	 * Native request with a specific {@code native_ad_choices_placement} value.
	 *
	 * @param placement one of "TOP_LEFT", "TOP_RIGHT", "BOTTOM_RIGHT", "BOTTOM_LEFT"
	 */
	public static Dictionary nativeRequestWithAdChoicesPlacement(String placement) {
		Dictionary d = minimalNativeRequest();
		d.put("native_ad_choices_placement", placement);
		return d;
	}

	/**
	 * Native request with a specific {@code native_image_scale_type} value.
	 *
	 * @param scaleType one of "MATRIX", "FIT_XY", "FIT_START", "FIT_CENTER",
	 *                  "FIT_END", "CENTER", "CENTER_CROP", "CENTER_INSIDE"
	 */
	public static Dictionary nativeRequestWithImageScaleType(String scaleType) {
		Dictionary d = minimalNativeRequest();
		d.put("native_image_scale_type", scaleType);
		return d;
	}

	/**
	 * Native request with {@code native_disable_validator} set.
	 *
	 * @param value true → flag is set; false → flag is explicitly off
	 */
	public static Dictionary nativeRequestWithValidatorDisabled(boolean value) {
		Dictionary d = minimalNativeRequest();
		d.put("native_disable_validator", value);
		return d;
	}

	/**
	 * Native request with every native-ad option key populated — used to verify that
	 * all setters are called together without interfering with each other.
	 */
	public static Dictionary fullNativeRequest() {
		Dictionary d = minimalNativeRequest();
		d.put("native_media_aspect_ratio", "LANDSCAPE");
		d.put("native_return_urls_for_image_assets", true);
		d.put("native_request_multiple_images", true);
		d.put("native_ad_choices_placement", "BOTTOM_LEFT");
		d.put("native_image_scale_type", "CENTER_CROP");
		d.put("native_disable_validator", true);
		return d;
	}

	// -- Edge-cases ------------------------------------------------------------

	/**
	 * A dictionary with no keys – {@link org.godotengine.plugin.admob.model.LoadAdRequest#isValid()} must return false.
	 */
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
