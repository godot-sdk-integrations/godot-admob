//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import com.google.android.gms.ads.AdapterResponseInfo;
import com.google.android.gms.ads.AdError;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.GodotConverter;
import org.godotengine.plugin.admob.mediation.network.MediationNetworkFactory;


public class AdmobAdapterResponse {

	private static String AD_ERROR_PROPERTY = "ad_error";
	private static String AD_SOURCE_ID_PROPERTY = "ad_source_id";
	private static String AD_SOURCE_INSTANCE_ID_PROPERTY = "ad_source_instance_id";
	private static String AD_SOURCE_INSTANCE_NAME_PROPERTY = "ad_source_instance_name";
	private static String AD_SOURCE_NAME_PROPERTY = "ad_source_name";
	private static String ADAPTER_CLASS_NAME_PROPERTY = "adapter_class_name";
	private static String LATENCY_PROPERTY = "latency";
	private static String NETWORK_TAG_PROPERTY = "network_tag";

	private AdapterResponseInfo info;

	public AdmobAdapterResponse(AdapterResponseInfo info) {
		this.info = info;
	}

	public Dictionary buildRawData() {
		Dictionary dict = new Dictionary();

		AdError adError = info.getAdError();
		if (adError != null) dict.put(AD_ERROR_PROPERTY, new AdmobAdError(adError).buildRawData());

		dict.put(AD_SOURCE_ID_PROPERTY, info.getAdSourceId());
		dict.put(AD_SOURCE_INSTANCE_ID_PROPERTY, info.getAdSourceInstanceId());
		dict.put(AD_SOURCE_INSTANCE_NAME_PROPERTY, info.getAdSourceInstanceName());
		dict.put(AD_SOURCE_NAME_PROPERTY, info.getAdSourceName());

		String adapterClassName = info.getAdapterClassName();
		dict.put(ADAPTER_CLASS_NAME_PROPERTY, adapterClassName);

		dict.put(LATENCY_PROPERTY, info.getLatencyMillis());

		String networkTag = MediationNetworkFactory.getTagForAdapterClass(adapterClassName);
		dict.put(NETWORK_TAG_PROPERTY, (networkTag != null) ? networkTag : "");

		return dict;
	}
}
