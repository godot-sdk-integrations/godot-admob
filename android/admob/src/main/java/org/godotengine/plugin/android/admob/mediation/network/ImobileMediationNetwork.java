//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class ImobileMediationNetwork extends MediationNetwork {

	public static final String TAG = "imobile";
	private static final String ADAPTER_CLASS = "com.google.ads.mediation.imobile.IMobileMediationAdapter";

	public ImobileMediationNetwork() {
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
