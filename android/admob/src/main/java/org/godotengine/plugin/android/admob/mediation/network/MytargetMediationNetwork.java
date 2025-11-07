//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class MytargetMediationNetwork extends MediationNetwork {

	public static final String TAG = "mytarget";
	private static final String ADAPTER_CLASS = "com.google.ads.mediation.mytarget.MyTargetMediationAdapter";

	public MytargetMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		// Get the Class object for MyTargetPrivacy
		Class<?> privacyClass = Class.forName("com.my.target.common.MyTargetPrivacy");

		/*
		 * MyTargetPrivacy.setUserConsent(true or false);
		 */

		// Get the Method object for setUserConsent(boolean)
		Method setUserConsentMethod = privacyClass.getMethod("setUserConsent", boolean.class);

		// Invoke the static method with 'null', because the method is static, and the boolean value.
		setUserConsentMethod.invoke(null, hasGdprConsent);
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		// Get the Class object for MyTargetPrivacy
		Class<?> privacyClass = Class.forName("com.my.target.common.MyTargetPrivacy");

		/*
		 * MyTargetPrivacy.setUserAgeRestricted(true or false);
		 */

		// Get the Method object for setUserAgeRestricted(boolean)
		Method setUserAgeRestrictedMethod = privacyClass.getMethod("setUserAgeRestricted", boolean.class);

		// Invoke the static method with 'null', because the method is static, and the boolean value.
		setUserAgeRestrictedMethod.invoke(null, isAgeRestrictedUser);
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		// Get the Class object for MyTargetPrivacy
		Class<?> privacyClass = Class.forName("com.my.target.common.MyTargetPrivacy");

		/*
		 * MyTargetPrivacy.setCcpaUserConsent(true or false);
		 */

		// Get the Method object for setCcpaUserConsent(boolean)
		Method setCcpaUserConsentMethod = privacyClass.getMethod("setCcpaUserConsent", boolean.class);

		// Invoke the static method with 'null', because the method is static, and the boolean value.
		setCcpaUserConsentMethod.invoke(null, hasCcpaConsent);
	}
}
