//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class IronsourceMediationNetwork extends MediationNetwork {

	public static final String TAG = "ironsource";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.ironsource.IronSourceMediationAdapter";

	public IronsourceMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		// ironSource SDK automatically reads GDPR consent set by UMP SDK since version 7.7.0
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * LevelPlay.setMetaData("do_not_sell", "true" or "false");
		 */

		// Get the Class object for LevelPlay
		Class<?> levelPlayClass = Class.forName("com.unity3d.mediation.LevelPlay");

		// Get the Method object for setMetaData(String, String)
		Method setMetaDataMethod = levelPlayClass.getMethod("setMetaData", String.class, String.class);

		String value = hasCcpaConsent ? "true" : "false";

		// Invoke the static method with 'null', because the method is static, and the key and value Strings.
		setMetaDataMethod.invoke(null, "do_not_sell", value);
	}
}
