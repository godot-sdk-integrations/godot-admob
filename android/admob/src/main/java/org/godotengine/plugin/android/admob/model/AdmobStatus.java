//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.model;

import android.util.Log;

import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.initialization.AdapterStatus.State;
import com.google.android.gms.ads.initialization.InitializationStatus;

import java.util.Map;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.android.admob.AdmobPlugin;
import org.godotengine.plugin.android.admob.mediation.network.MediationNetworkFactory;


public class AdmobStatus {
	private static final String CLASS_NAME = AdmobStatus.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private static String ADAPTER_CLASS_PROPERTY = "adapter_class";
	private static String LATENCY_PROPERTY = "latency";
	private static String INITIALIZATION_STATE_PROPERTY = "initialization_state";
	private static String DESCRIPTION_PROPERTY = "description";

	private InitializationStatus status;

	public AdmobStatus(InitializationStatus status) {
		this.status = status;
	}

	public Dictionary buildRawData() {
		Dictionary dict = new Dictionary();

		Map<String, AdapterStatus> adapterMap = status.getAdapterStatusMap();
		for (String adapterClass : adapterMap.keySet()) {
			AdapterStatus adapterStatus = adapterMap.get(adapterClass);

			Dictionary statusDict = new Dictionary();
			statusDict.put(ADAPTER_CLASS_PROPERTY, adapterClass);
			statusDict.put(LATENCY_PROPERTY, adapterStatus.getLatency());
			String adapterStatusStr = adapterStatusToString(adapterStatus.getInitializationState());
			statusDict.put(INITIALIZATION_STATE_PROPERTY, adapterStatusStr);
			statusDict.put(DESCRIPTION_PROPERTY, adapterStatus.getDescription());

			String networkTag = MediationNetworkFactory.getTagForAdapterClass(adapterClass);
			if (networkTag != null) {
				dict.put(networkTag, statusDict);
				Log.d(LOG_TAG, "Initialization status " + adapterStatusStr + " for network tag '" + networkTag + "'.");
			} else {
				dict.put(adapterClass, statusDict);
				Log.w(LOG_TAG, "Initialization status " + adapterStatusStr + " for an invalid or unsupported adapter class '" + adapterClass + "'.");
			}
		}

		return dict;
	}

	private static String adapterStatusToString(AdapterStatus.State adapterInitializationState) {
		return switch (adapterInitializationState) {
					case NOT_READY -> "NOT_READY";
					case READY -> "READY";
					default -> "INVALID";
				};
	}
}
