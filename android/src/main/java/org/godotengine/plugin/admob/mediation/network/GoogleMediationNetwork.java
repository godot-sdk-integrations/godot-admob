//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation.network;

import android.content.Context;

import org.godotengine.plugin.admob.mediation.network.MediationNetwork;


public class GoogleMediationNetwork extends MediationNetwork {

	public static final String TAG = "google";
	static final String INIT_CLASS = "com.google.android.gms.ads.MobileAds";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.admob.AdMobAdapter";

	public GoogleMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}
}
