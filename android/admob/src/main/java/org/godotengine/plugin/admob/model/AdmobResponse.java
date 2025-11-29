//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import com.google.android.gms.ads.AdapterResponseInfo;
import com.google.android.gms.ads.ResponseInfo;

import java.util.List;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.mediation.network.MediationNetworkFactory;


public class AdmobResponse {

	private static String ADAPTER_RESPONSES_PROPERTY = "adapter_responses";
	private static String LOADED_ADAPTER_RESPONSE_PROPERTY = "loaded_adapter_response";
	private static String ADAPTER_CLASS_NAME_PROPERTY = "adapter_class_name";
	private static String RESPONSE_ID_PROPERTY = "response_id";
	private static String NETWORK_TAG_PROPERTY = "network_tag";

	private ResponseInfo info;

	public AdmobResponse(ResponseInfo info) {
		this.info = info;
	}

	public Dictionary buildRawData() {
		Dictionary dict = new Dictionary();

		List<AdapterResponseInfo> adapterResponses = info.getAdapterResponses();
		Dictionary[] responseDicts = new Dictionary[adapterResponses.size()];
		for (int i = 0; i < adapterResponses.size(); i++) {
			responseDicts[i] = new AdmobAdapterResponse(adapterResponses.get(i)).buildRawData();
		}
		dict.put(ADAPTER_RESPONSES_PROPERTY, responseDicts);

		AdapterResponseInfo adapterResponseInfo = info.getLoadedAdapterResponseInfo();
		if (adapterResponseInfo != null)
			dict.put(LOADED_ADAPTER_RESPONSE_PROPERTY, new AdmobAdapterResponse(adapterResponseInfo).buildRawData());

		String className = info.getMediationAdapterClassName();
		if (className != null) {
			dict.put(ADAPTER_CLASS_NAME_PROPERTY, className);

			String networkTag = MediationNetworkFactory.getTagForAdapterClass(className);
			dict.put(NETWORK_TAG_PROPERTY, (networkTag != null) ? networkTag : "");
		}

		String responseId = info.getResponseId();
		if (responseId != null) dict.put(RESPONSE_ID_PROPERTY, responseId);

		return dict;
	}
}
