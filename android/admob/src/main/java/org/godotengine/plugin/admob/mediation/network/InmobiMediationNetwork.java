//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.godotengine.plugin.admob.mediation.network.MediationNetwork;


public class InmobiMediationNetwork extends MediationNetwork {

	public static final String TAG = "inmobi";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.inmobi.InMobiMediationAdapter";

	public InmobiMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		/*
		 * JSONObject consentObject = new JSONObject();
		 * consentObject.put(InMobiSdk.IM_GDPR_CONSENT_AVAILABLE, true);
		 * consentObject.put("gdpr", "1" or "0");
		 * InMobiConsent.updateGDPRConsent(consentObject);
		 */

		// Get the required Classes
		Class<?> jsonObjectClass = Class.forName("org.json.JSONObject");
		Class<?> inMobiSdkClass = Class.forName("com.inmobi.sdk.InMobiSdk");

		// Instantiate JSONObject: new JSONObject() with the default, no-argument constructor
		Constructor<?> jsonConstructor = jsonObjectClass.getConstructor();

		// Create the new object instance
		Object consentObject = jsonConstructor.newInstance();

		// Get the static field InMobiSdk.IM_GDPR_CONSENT_AVAILABLE (the value is needed as the key for the first 'put' call)
		Field gdprAvailableField = inMobiSdkClass.getField("IM_GDPR_CONSENT_AVAILABLE");

		// Retrieve the actual String value of the static field. Pass 'null' because it's static.
		String gdprAvailableKey = (String) gdprAvailableField.get(null);

		// Get the Method object for put(String, Object)
		Method putMethod = jsonObjectClass.getMethod("put", String.class, Object.class);

		// Invoke the 'put' method twice
		// consentObject.put(InMobiSdk.IM_GDPR_CONSENT_AVAILABLE, true);
		putMethod.invoke(consentObject, gdprAvailableKey, true);

		// consentObject.put("gdpr", "1" or "0");
		putMethod.invoke(consentObject, "gdpr", hasGdprConsent ? "1" : "0");

		// Get the Class object for InMobiConsent
		Class<?> consentClass = Class.forName("com.google.ads.mediation.inmobi.InMobiConsent");

		// Get the Method object for updateGDPRConsent(String)
		Method updateConsentMethod = consentClass.getMethod("updateGDPRConsent", jsonObjectClass);

		// Invoke the static method with 'null', because the method is static, and the consentObject.
		updateConsentMethod.invoke(null, consentObject);
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		// InMobi SDK added support to read CCPA from shared preferences in version 10.5.7.1
		throw new UnsupportedOperationException();
	}
}
