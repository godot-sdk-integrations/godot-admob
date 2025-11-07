//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;

import org.godotengine.plugin.android.admob.AdmobPlugin;
import org.godotengine.plugin.android.admob.mediation.PrivacySettings;
import org.godotengine.plugin.android.admob.mediation.network.ApplovinMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.ChartboostMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.DtexchangeMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.ImobileMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.InmobiMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.IronsourceMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.LiftoffMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.LineMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MaioMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MetaMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MintegralMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MolocoMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.MytargetMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.PangleMediationNetwork;
import org.godotengine.plugin.android.admob.mediation.network.UnityMediationNetwork;


public class MediationNetworkFactory {
	private static final String CLASS_NAME = MediationNetworkFactory.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	// A map that links the string tag to a Supplier that instantiates the correct concrete network class
	private static final Map<String, Supplier<MediationNetwork>> NETWORK_FACTORY_MAP = new HashMap<>();

	static {
		// Centralized registry of all MediationNetworks
		NETWORK_FACTORY_MAP.put(ApplovinMediationNetwork.TAG, ApplovinMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(ChartboostMediationNetwork.TAG, ChartboostMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(DtexchangeMediationNetwork.TAG, DtexchangeMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(ImobileMediationNetwork.TAG, ImobileMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(InmobiMediationNetwork.TAG, InmobiMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(IronsourceMediationNetwork.TAG, IronsourceMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(LiftoffMediationNetwork.TAG, LiftoffMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(LineMediationNetwork.TAG, LineMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(MaioMediationNetwork.TAG, MaioMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(MetaMediationNetwork.TAG, MetaMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(MintegralMediationNetwork.TAG, MintegralMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(MolocoMediationNetwork.TAG, MolocoMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(MytargetMediationNetwork.TAG, MytargetMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(PangleMediationNetwork.TAG, PangleMediationNetwork::new);
		NETWORK_FACTORY_MAP.put(UnityMediationNetwork.TAG, UnityMediationNetwork::new);
	}

	/**
	 * Creates a MediationNetwork instance based on the input tag
	 *
	 * @param networkTag The string identifier for the network (e.g., "applovin")
	 * @return A configured MediationNetwork instance, or null if the tag is unknown
	 */
	public static MediationNetwork createNetwork(String networkTag) {
		String tag = (networkTag != null) ? networkTag.trim().toLowerCase() : "";

		Supplier<MediationNetwork> supplier = NETWORK_FACTORY_MAP.get(tag);

		if (supplier == null) {
			Log.e(LOG_TAG, "Invalid or unsupported network tag '" + networkTag + "'. Unable to create network object.");
			return null;
		}

		// The supplier function instantiates the correct concrete class (e.g., new ApplovinMediationNetwork())
		return supplier.get();
	}
}
