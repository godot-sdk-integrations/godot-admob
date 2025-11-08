//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.model;

import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.mediation.Adapter;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.android.admob.AdmobPlugin;
import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MediationNetworkFactory;


public class LoadAdRequest {
	private static final String CLASS_NAME = LoadAdRequest.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private static String AD_UNIT_ID_PROPERTY = "ad_unit_id";
	private static String REQUEST_AGENT_PROPERTY = "request_agent";
	private static String AD_SIZE_PROPERTY = "ad_size";
	private static String AD_POSITION_PROPERTY = "ad_position";
	private static String KEYWORDS_PROPERTY = "keywords";
	private static String USER_ID_PROPERTY = "user_id";
	private static String CUSTOM_DATA_PROPERTY = "custom_data";
	private static String NETWORK_EXTRAS_PROPERTY = "network_extras";
	private static String NETWORK_TAG_SUBPROPERTY = "network_tag";
	private static String EXTRAS_SUBPROPERTY = "extras";

	private static final String AD_ID_FORMAT = "%s-%d";

	private Dictionary _data;

	public LoadAdRequest(Dictionary data) {
		this._data = data;
	}


	public boolean isValid() {
		return _data.containsKey(AD_UNIT_ID_PROPERTY);
	}


	public String getAdUnitId() {
		return (String) _data.get(AD_UNIT_ID_PROPERTY);
	}


	public boolean hasAdSize() {
		return _data.containsKey(AD_SIZE_PROPERTY);
	}


	public String getAdSize() {
		return (String) _data.get(AD_SIZE_PROPERTY);
	}


	public boolean hasAdPosition() {
		return _data.containsKey(AD_POSITION_PROPERTY);
	}


	public String getAdPosition() {
		return (String) _data.get(AD_POSITION_PROPERTY);
	}


	public String generateAdId(int sequence) {
		return String.format(AD_ID_FORMAT, this.getAdUnitId(), sequence);
	}


	public AdRequest createAdRequest() {
		AdRequest.Builder builder = new AdRequest.Builder();

		if (_data.containsKey(REQUEST_AGENT_PROPERTY)) {
			String requestAgent = (String) _data.get(REQUEST_AGENT_PROPERTY);
			if (requestAgent != null && !requestAgent.isEmpty()) {
				builder.setRequestAgent(requestAgent);
			}
		}

		// Mediation support: AdRequest extras for specific networks (e.g., waterfall parameters).
		// Expects data to contain "network_extras" as an Array of Dictionaries, where each entry is:
		// {"network_tag": "tagfornetwork", "extras": {"param_key": "value"}}
		// Supports only String as param_key and String, Number (int/double/long), Boolean as value.
		// Basic bidding/waterfall handled by AdMob SDK; extras only for custom network params.
		if (_data.containsKey(NETWORK_EXTRAS_PROPERTY)) {
			Object extrasObj = _data.get(NETWORK_EXTRAS_PROPERTY);
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
									Log.d(LOG_TAG, String.format("Processing %d extra parameters for %s", params.size(), networkTag));
									Bundle bundle = new Bundle();
									for (String key : params.keySet()) {
										Object val = params.get(key);
										if (val instanceof String) {
											bundle.putString(key, (String) val);
											Log.d(LOG_TAG, String.format("Added ['%s',%s] extra for %s", key, val, networkTag));
										} else if (val instanceof Integer || val instanceof Double) {
											bundle.putDouble(key, ((Number) val).doubleValue());
											Log.d(LOG_TAG, String.format("Added ['%s',%.2f] extra for %s", key, val, networkTag));
										} else if (val instanceof Boolean) {
											bundle.putBoolean(key, (Boolean) val);
											Log.d(LOG_TAG, String.format("Added ['%s',%b] extra for %s", key, val, networkTag));
										} else if (val instanceof Long) {
											bundle.putLong(key, (Long) val);
											Log.d(LOG_TAG, String.format("Added ['%s',%d] extra for %s", key, val, networkTag));
										}
									}
									if (bundle.size() > 0) {
										Log.d(LOG_TAG, String.format("%d extras were added to bundle", bundle.size()));
										@SuppressWarnings("unchecked")
										Class<? extends Adapter> adapterClass = (Class<? extends Adapter>) Class.forName(network.getAdapterClassName());
										if (adapterClass != null) {
											builder.addNetworkExtrasBundle(adapterClass, bundle);
											Log.d(LOG_TAG, "Added extras for " + networkTag);
										}
									}
								} catch (ClassNotFoundException e) {
									Log.w(LOG_TAG, "Class not found for adapter: " + network.getAdapterClassName() + ". Skipping. Ensure the mediation dependency is included.");
								} catch (ClassCastException e) {
									Log.w(LOG_TAG, "Adapter class " + network.getAdapterClassName() + " does not extend Adapter. Skipping.");
								} catch (Exception e) {
									Log.e(LOG_TAG, "Error adding extras for " + network.getAdapterClassName() + ": " + e.getMessage());
								}
							} else {
								Log.w(LOG_TAG, String.format("Invalid %s entry: Missing '%s' or '%s'. Skipping.", NETWORK_EXTRAS_PROPERTY,
										NETWORK_TAG_SUBPROPERTY, EXTRAS_SUBPROPERTY));
							}
						} else {
							Log.e(LOG_TAG, "Cannot set extras for network '" + networkTag + "': Network not supported.");
						}
					}
				}
			} else {
				Log.w(LOG_TAG, "network_extras must be an Array of Dictionaries. Skipping.");
			}
		}

		if (_data.containsKey(KEYWORDS_PROPERTY)) {
			for (Object keyword : (Object[]) _data.get(KEYWORDS_PROPERTY)) {
				builder.addKeyword((String) keyword);
			}
		}

		return builder.build();
	}
}
