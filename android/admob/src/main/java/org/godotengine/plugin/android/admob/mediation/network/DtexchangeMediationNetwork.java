//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class DtexchangeMediationNetwork extends MediationNetwork {

	public static final String TAG = "dtexchange";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.fyber.FyberMediationAdapter";

	public DtexchangeMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		// DT Exchange SDK automatically retrieves GDPR since version 8.3.0
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * InneractiveAdManager.setUSPrivacyString("1YNN" or "1YYN");
		 */

		// Get the Class object for InneractiveAdManager
		Class<?> managerClass = Class.forName("com.fyber.inneractive.sdk.external.InneractiveAdManager");

		// Get the Method object for setUSPrivacyString(String)
		Method setPrivacyMethod = managerClass.getMethod("setUSPrivacyString", String.class);

		// "1---": CCPA does not apply, for example, the user is not a California resident
		// "1YNN": User does NOT opt out, ad experience continues
		// "1YYN": User opts out of targeted advertising
		String privacyString = "1Y" + (hasCcpaConsent ? "N" : "Y") + "N";

		// Invoke the static method. The first argument is 'null' because the method is static, the second is the array of arguments to pass (the String value).
		setPrivacyMethod.invoke(null, privacyString);
	}
}
