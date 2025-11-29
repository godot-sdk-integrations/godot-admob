//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Method;

import org.godotengine.plugin.admob.mediation.network.MediationNetwork;


public class ApplovinMediationNetwork extends MediationNetwork {

	public static final String TAG = "applovin";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.applovin.AppLovinMediationAdapter";

	public ApplovinMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		/*
		 * AppLovinPrivacySettings.setHasUserConsent(true or false);
		 */

		// Get the required privacy settings class
		Class<?> privacyClass = Class.forName("com.applovin.sdk.AppLovinPrivacySettings");

		Method setConsentMethod = privacyClass.getMethod("setHasUserConsent", boolean.class, Context.class);
		setConsentMethod.invoke(null, hasGdprConsent, context); // static call
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * AppLovinPrivacySettings.setDoNotSell(true or false);
		 */

		// Get the required privacy settings class
		Class<?> privacyClass = Class.forName("com.applovin.sdk.AppLovinPrivacySettings");

		Method setDoNotSellMethod = privacyClass.getMethod("setDoNotSell", boolean.class, Context.class);
		setDoNotSellMethod.invoke(null, !hasCcpaConsent, context); // static call
	}
}
