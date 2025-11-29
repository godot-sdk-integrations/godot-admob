//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Method;

import org.godotengine.plugin.admob.mediation.network.MediationNetwork;


public class LiftoffMediationNetwork extends MediationNetwork {

	public static final String TAG = "liftoff";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.vungle.VungleMediationAdapter";

	public LiftoffMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		// Liftoff Monetize automatically reads GDPR consent set by UMP SDK since Vungle SDK version 7.7.0
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * VunglePrivacySettings.setCCPAStatus(true or false);
		 */

		// Get the Class object for VunglePrivacySettings
		Class<?> privacyClass = Class.forName("com.vungle.ads.VunglePrivacySettings");

		// Get the Method object for setCCPAStatus(boolean)
		Method setStatusMethod = privacyClass.getMethod("setCCPAStatus", boolean.class);

		// Invoke the static method with 'null', because the method is static, and the boolean value.
		setStatusMethod.invoke(null, hasCcpaConsent);
	}
}
