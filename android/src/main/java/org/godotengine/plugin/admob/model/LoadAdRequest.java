//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;

import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.mediation.Adapter;
import com.google.android.gms.ads.nativead.NativeAdOptions;
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.AdmobPlugin;
import org.godotengine.plugin.admob.mediation.network.MediationNetwork;
import org.godotengine.plugin.admob.mediation.network.MediationNetworkFactory;


public class LoadAdRequest {
	private static final String CLASS_NAME = LoadAdRequest.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	// -------------------------------------------------------------------------
	// General AdRequest keys
	// -------------------------------------------------------------------------

	private static final String AD_UNIT_ID_PROPERTY = "ad_unit_id";
	private static final String REQUEST_AGENT_PROPERTY = "request_agent";
	private static final String AD_SIZE_PROPERTY = "ad_size";
	private static final String ADAPTIVE_WIDTH_PROPERTY = "adaptive_width";
	private static final String ADAPTIVE_MAX_HEIGHT_PROPERTY = "adaptive_max_height";
	private static final String AD_POSITION_PROPERTY = "ad_position";
	private static final String COLLAPSIBLE_POSITION_PROPERTY = "collapsible_position";
	private static final String ANCHOR_TO_SAFE_AREA_PROPERTY = "anchor_to_safe_area";
	private static final String KEYWORDS_PROPERTY = "keywords";
	private static final String USER_ID_PROPERTY = "user_id";
	private static final String CUSTOM_DATA_PROPERTY = "custom_data";
	private static final String NETWORK_EXTRAS_PROPERTY = "network_extras";
	private static final String NETWORK_TAG_SUBPROPERTY = "network_tag";
	private static final String EXTRAS_SUBPROPERTY = "extras";

	private static final String COLLAPSIBLE_NETWORK_EXTRAS_KEY = "collapsible";
	private static final String AD_ID_FORMAT = "%s-%d";

	// -------------------------------------------------------------------------
	// Native ad option keys  (mirror DATA_KEY_NATIVE_* in LoadAdRequest.gd)
	// -------------------------------------------------------------------------

	private static final String NATIVE_MEDIA_ASPECT_RATIO_PROPERTY = "native_media_aspect_ratio";
	private static final String NATIVE_RETURN_URLS_FOR_IMAGE_ASSETS_PROPERTY = "native_return_urls_for_image_assets";
	private static final String NATIVE_REQUEST_MULTIPLE_IMAGES_PROPERTY = "native_request_multiple_images";
	private static final String NATIVE_AD_CHOICES_PLACEMENT_PROPERTY = "native_ad_choices_placement";
	private static final String NATIVE_IMAGE_SCALE_TYPE_PROPERTY = "native_image_scale_type";
	private static final String NATIVE_DISABLE_VALIDATOR_PROPERTY = "native_disable_validator";

	private Dictionary data;

	public LoadAdRequest(Dictionary data) {
		this.data = data;
	}


	public boolean isValid() {
		return data.containsKey(AD_UNIT_ID_PROPERTY);
	}


	public String getAdUnitId() {
		return (String) data.get(AD_UNIT_ID_PROPERTY);
	}


	public boolean hasAdSize() {
		return data.containsKey(AD_SIZE_PROPERTY);
	}


	public String getAdSize() {
		return (String) data.get(AD_SIZE_PROPERTY);
	}


	public int getAdaptiveWidth() {
		return data.containsKey(ADAPTIVE_WIDTH_PROPERTY) ? toInt(data.get(ADAPTIVE_WIDTH_PROPERTY)) : -1;
	}


	public int getAdaptiveMaxHeight() {
		return data.containsKey(ADAPTIVE_MAX_HEIGHT_PROPERTY) ? toInt(data.get(ADAPTIVE_MAX_HEIGHT_PROPERTY)) : -1;
	}


	public boolean hasAdPosition() {
		return data.containsKey(AD_POSITION_PROPERTY);
	}


	public String getAdPosition() {
		return (String) data.get(AD_POSITION_PROPERTY);
	}


	public boolean hasCollapsiblePosition() {
		return data.containsKey(COLLAPSIBLE_POSITION_PROPERTY);
	}


	public String getCollapsiblePosition() {
		return (String) data.get(COLLAPSIBLE_POSITION_PROPERTY);
	}


	public boolean doAnchorToSafeArea() {
		return data.containsKey(ANCHOR_TO_SAFE_AREA_PROPERTY) ? (boolean) data.get(ANCHOR_TO_SAFE_AREA_PROPERTY)
				: false;
	}


	public String generateAdId(int sequence) {
		return String.format(AD_ID_FORMAT, this.getAdUnitId(), sequence);
	}


	// -------------------------------------------------------------------------
	// Native Ad Options
	// -------------------------------------------------------------------------

	/**
	 * Builds a {@link NativeAdOptions} instance from the request dictionary,
	 * applying only the keys that were actually set by the caller.
	 */
	public NativeAdOptions createNativeAdOptions() {
		NativeAdOptions.Builder builder = new NativeAdOptions.Builder();

		if (data.containsKey(NATIVE_MEDIA_ASPECT_RATIO_PROPERTY)) {
			String ratio = (String) data.get(NATIVE_MEDIA_ASPECT_RATIO_PROPERTY);
			builder.setMediaAspectRatio(parseMediaAspectRatio(ratio));
		}

		if (data.containsKey(NATIVE_RETURN_URLS_FOR_IMAGE_ASSETS_PROPERTY)) {
			builder.setReturnUrlsForImageAssets((boolean) data.get(NATIVE_RETURN_URLS_FOR_IMAGE_ASSETS_PROPERTY));
		}

		if (data.containsKey(NATIVE_REQUEST_MULTIPLE_IMAGES_PROPERTY)) {
			builder.setRequestMultipleImages((boolean) data.get(NATIVE_REQUEST_MULTIPLE_IMAGES_PROPERTY));
		}

		if (data.containsKey(NATIVE_AD_CHOICES_PLACEMENT_PROPERTY)) {
			String placement = (String) data.get(NATIVE_AD_CHOICES_PLACEMENT_PROPERTY);
			builder.setAdChoicesPlacement(parseAdChoicesPlacement(placement));
		}

		return builder.build();
	}

	/**
	 * Returns true when the caller set a preferred image scale type for native ad assets.
	 */
	public boolean hasNativeImageScaleType() {
		return data.containsKey(NATIVE_IMAGE_SCALE_TYPE_PROPERTY);
	}

	/**
	 * Translates the GDScript enum string to the matching Android {@link ImageView.ScaleType}.
	 * Falls back to {@link ImageView.ScaleType#FIT_CENTER} (the Android view default) when the
	 * value is absent or unrecognised.
	 */
	public ImageView.ScaleType getNativeImageScaleType() {
		if (!data.containsKey(NATIVE_IMAGE_SCALE_TYPE_PROPERTY)) {
			return ImageView.ScaleType.FIT_CENTER;
		}
		String value = (String) data.get(NATIVE_IMAGE_SCALE_TYPE_PROPERTY);
		switch (value) {
			case "MATRIX":        return ImageView.ScaleType.MATRIX;
			case "FIT_XY":        return ImageView.ScaleType.FIT_XY;
			case "FIT_START":     return ImageView.ScaleType.FIT_START;
			case "FIT_END":       return ImageView.ScaleType.FIT_END;
			case "CENTER":        return ImageView.ScaleType.CENTER;
			case "CENTER_CROP":   return ImageView.ScaleType.CENTER_CROP;
			case "CENTER_INSIDE": return ImageView.ScaleType.CENTER_INSIDE;
			case "FIT_CENTER":    // fall-through to default
			default:
				if (!value.equals("FIT_CENTER")) {
					Log.w(LOG_TAG, "getNativeImageScaleType(): unknown value '" + value
							+ "', falling back to FIT_CENTER");
				}
				return ImageView.ScaleType.FIT_CENTER;
		}
	}

	/**
	 * Returns true when the caller requested that the SDK's native ad validator be disabled.
	 *
	 * <p>The native ad validator is an internal SDK component that logs warnings when required
	 * view bindings are missing from a {@link com.google.android.gms.ads.nativead.NativeAdView}.
	 * Disabling it can be useful during development when using custom or partial layouts.
	 *
	 * <p><b>Implementation note:</b> there is no first-class public API for this in the GMS Ads
	 * SDK.  The flag is surfaced here so it can be acted on in the future if Google exposes such
	 * an API, or via any undocumented mechanism the caller wishes to layer on top.
	 */
	public boolean isNativeValidatorDisabled() {
		return data.containsKey(NATIVE_DISABLE_VALIDATOR_PROPERTY)
				&& (boolean) data.get(NATIVE_DISABLE_VALIDATOR_PROPERTY);
	}

	// -------------------------------------------------------------------------
	// AdRequest
	// -------------------------------------------------------------------------

	public AdRequest createAdRequest() {
		AdRequest.Builder builder = new AdRequest.Builder();

		if (data.containsKey(REQUEST_AGENT_PROPERTY)) {
			String requestAgent = (String) data.get(REQUEST_AGENT_PROPERTY);
			if (requestAgent != null && !requestAgent.isEmpty()) {
				builder.setRequestAgent(requestAgent);
			}
		}

		if (data.containsKey(KEYWORDS_PROPERTY)) {
			for (Object keyword : (Object[]) data.get(KEYWORDS_PROPERTY)) {
				builder.addKeyword((String) keyword);
			}
		}

		if (hasCollapsiblePosition()) {
			String collapsiblePosition = getCollapsiblePosition();
			Log.d(LOG_TAG, "Loading collapsible banner (" + collapsiblePosition + ")");

			Bundle extras = new Bundle();
			extras.putString(COLLAPSIBLE_NETWORK_EXTRAS_KEY, collapsiblePosition);
			builder.addNetworkExtrasBundle(AdMobAdapter.class, extras);
		}

		// Mediation support: AdRequest extras for specific networks (e.g., waterfall parameters).
		// Expects data to contain "network_extras" as an Array of Dictionaries, where each entry is:
		// {"network_tag": "tagfornetwork", "extras": {"param_key": "value"}}
		// Supports only String as param_key and String, Number (int/double/long), Boolean as value.
		// Basic bidding/waterfall handled by AdMob SDK; extras only for custom network params.
		if (data.containsKey(NETWORK_EXTRAS_PROPERTY)) {
			Object extrasObj = data.get(NETWORK_EXTRAS_PROPERTY);
			if (extrasObj instanceof Object[]) {
				Object[] extrasArray = (Object[]) extrasObj;
				for (Object entryObj : extrasArray) {
					if (entryObj instanceof Dictionary) {
						@SuppressWarnings("unchecked")
						Dictionary entry = (Dictionary) entryObj;
						String networkTag = (String) entry.get(NETWORK_TAG_SUBPROPERTY);
						MediationNetwork network = MediationNetworkFactory.createNetwork(networkTag);
						if (network != null) {
							Object extrasParamsObj = entry.get(EXTRAS_SUBPROPERTY);
							if (extrasParamsObj instanceof Dictionary) {
								try {
									@SuppressWarnings("unchecked")
									Dictionary params = (Dictionary) extrasParamsObj;
									Log.d(LOG_TAG, String.format("Processing %d extra parameters for %s",
											params.size(), networkTag));
									Bundle bundle = new Bundle();
									for (String key : params.keySet()) {
										Object val = params.get(key);
										if (val instanceof String) {
											bundle.putString(key, (String) val);
											Log.d(LOG_TAG, String.format("Added ['%s',%s] extra for %s",
													key, val, networkTag));
										} else if (val instanceof Integer || val instanceof Double) {
											bundle.putDouble(key, ((Number) val).doubleValue());
											Log.d(LOG_TAG, String.format("Added ['%s',%.2f] extra for %s",
													key, val, networkTag));
										} else if (val instanceof Boolean) {
											bundle.putBoolean(key, (Boolean) val);
											Log.d(LOG_TAG, String.format("Added ['%s',%b] extra for %s",
													key, val, networkTag));
										} else if (val instanceof Long) {
											bundle.putLong(key, (Long) val);
											Log.d(LOG_TAG, String.format("Added ['%s',%d] extra for %s",
													key, val, networkTag));
										}
									}
									if (bundle.size() > 0) {
										Log.d(LOG_TAG, String.format("%d extras were added to bundle",
												bundle.size()));
										@SuppressWarnings("unchecked")
										Class<? extends Adapter> adapterClass =
												(Class<? extends Adapter>) Class.forName(
														network.getAdapterClassName());
										if (adapterClass != null) {
											builder.addNetworkExtrasBundle(adapterClass, bundle);
											Log.d(LOG_TAG, "Added extras for " + networkTag);
										}
									}
								} catch (ClassNotFoundException e) {
									Log.w(LOG_TAG, "Class not found for adapter: "
											+ network.getAdapterClassName()
											+ ". Skipping. Ensure the mediation dependency is included.");
								} catch (ClassCastException e) {
									Log.w(LOG_TAG, "Adapter class " + network.getAdapterClassName()
											+ " does not extend Adapter. Skipping.");
								} catch (Exception e) {
									Log.e(LOG_TAG, "Error adding extras for "
											+ network.getAdapterClassName() + ": " + e.getMessage());
								}
							} else {
								Log.w(LOG_TAG, String.format(
										"Invalid %s entry: Missing '%s' or '%s'. Skipping.",
										NETWORK_EXTRAS_PROPERTY, NETWORK_TAG_SUBPROPERTY,
										EXTRAS_SUBPROPERTY));
							}
						} else {
							Log.e(LOG_TAG, "Cannot set extras for network '" + networkTag
									+ "': Network not supported.");
						}
					}
				}
			} else {
				Log.w(LOG_TAG, "network_extras must be an Array of Dictionaries. Skipping.");
			}
		}

		return builder.build();
	}


	public boolean hasServerSideVerificationOptions() {
		return data.containsKey(CUSTOM_DATA_PROPERTY) || data.containsKey(USER_ID_PROPERTY);
	}


	public ServerSideVerificationOptions createServerSideVerificationOptions() {
		ServerSideVerificationOptions.Builder builder = new ServerSideVerificationOptions.Builder();

		if (data.containsKey(CUSTOM_DATA_PROPERTY)) {
			builder.setCustomData((String) data.get(CUSTOM_DATA_PROPERTY));
		}

		if (data.containsKey(USER_ID_PROPERTY)) {
			builder.setUserId((String) data.get(USER_ID_PROPERTY));
		}

		return builder.build();
	}

	public Dictionary getRawData() {
		return data;
	}

	// -------------------------------------------------------------------------
	// Private helpers
	// -------------------------------------------------------------------------

	private int toInt(Object godotInt) {
		return ((Long) godotInt).intValue();
	}

	/**
	 * Maps a GDScript {@code NativeMediaAspectRatio} enum key to the matching
	 * {@link NativeAdOptions} constant.
	 */
	private int parseMediaAspectRatio(String value) {
		switch (value) {
			case "ANY":       return NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_ANY;
			case "LANDSCAPE": return NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_LANDSCAPE;
			case "PORTRAIT":  return NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_PORTRAIT;
			case "SQUARE":    return NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_SQUARE;
			case "UNKNOWN":   // fall-through to default
			default:
				if (!value.equals("UNKNOWN")) {
					Log.w(LOG_TAG, "parseMediaAspectRatio(): unknown value '" + value
							+ "', using NATIVE_MEDIA_ASPECT_RATIO_UNKNOWN");
				}
				return NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_UNKNOWN;
		}
	}

	/**
	 * Maps a GDScript {@code NativeAdChoicesPlacement} enum key to the matching
	 * {@link NativeAdOptions} constant.
	 */
	private int parseAdChoicesPlacement(String value) {
		switch (value) {
			case "TOP_LEFT":     return NativeAdOptions.ADCHOICES_TOP_LEFT;
			case "BOTTOM_RIGHT": return NativeAdOptions.ADCHOICES_BOTTOM_RIGHT;
			case "BOTTOM_LEFT":  return NativeAdOptions.ADCHOICES_BOTTOM_LEFT;
			case "TOP_RIGHT":    // fall-through to default
			default:
				if (!value.equals("TOP_RIGHT")) {
					Log.w(LOG_TAG, "parseAdChoicesPlacement(): unknown value '" + value
							+ "', using ADCHOICES_TOP_RIGHT");
				}
				return NativeAdOptions.ADCHOICES_TOP_RIGHT;
		}
	}
}
