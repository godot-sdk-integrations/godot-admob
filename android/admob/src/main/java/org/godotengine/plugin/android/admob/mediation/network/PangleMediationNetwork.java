//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class PangleMediationNetwork extends MediationNetwork {

	public static final String TAG = "pangle";
	private static final String ADAPTER_CLASS = "com.google.ads.mediation.pangle.PangleMediationAdapter";

	public PangleMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		// Get the required Classes
		Class<?> adapterClass = Class.forName("com.google.ads.mediation.pangle.PangleMediationAdapter");
		Class<?> constantClass = Class.forName("com.bytedance.sdk.openadsdk.api.PAGConstant");

		/*
		 * PangleMediationAdapter.setGDPRConsent(PAGConstant.PAGGDPRConsentType.PAG_GDPR_CONSENT_TYPE_CONSENT);
		 */

		// Get the inner enum class: PAGConstant.PAGGDPRConsentType
		Class<?> consentTypeClass = Class.forName("com.bytedance.sdk.openadsdk.api.PAGConstant$PAGGDPRConsentType");

		// Get the static constant value: PAG_GDPR_CONSENT_TYPE_CONSENT
		Field consentField = consentTypeClass.getField("PAG_GDPR_CONSENT_TYPE_CONSENT");
		Object consentConstant = consentField.get(null); // Pass 'null' because it's a static field.

		// Get the static constant value: PAG_GDPR_CONSENT_TYPE_CONSENT
		consentField = consentTypeClass.getField("PAG_GDPR_CONSENT_TYPE_NO_CONSENT");
		Object noConsentConstant = consentField.get(null); // Pass 'null' because it's a static field.

		// Invoke PangleMediationAdapter.setGDPRConsent(consentConstant)
		Method setConsentMethod = adapterClass.getMethod("setGDPRConsent", int.class);
		setConsentMethod.invoke(null, hasGdprConsent ? consentConstant : noConsentConstant); // The first argument is 'null' because the method is static.
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		// Get the required Classes
		Class<?> adapterClass = Class.forName("com.google.ads.mediation.pangle.PangleMediationAdapter");
		Class<?> constantClass = Class.forName("com.bytedance.sdk.openadsdk.api.PAGConstant");

		/*
		 * PangleMediationAdapter.setPAConsent(PAGConstant.PAGPAConsentType.PAG_PA_CONSENT_TYPE_CONSENT);
		 */

		// Get the inner enum class: PAGConstant.PAGPAConsentType
		Class<?> consentTypeClass = Class.forName("com.bytedance.sdk.openadsdk.api.PAGConstant$PAGPAConsentType");

		// Get the static constant value: PAG_GDPR_CONSENT_TYPE_CONSENT
		Field consentField = consentTypeClass.getField("PAG_PA_CONSENT_TYPE_CONSENT");
		Object consentConstant = consentField.get(null); // Pass 'null' because it's a static field.

		// Get the static constant value: PAG_PA_CONSENT_TYPE_NO_CONSENT
		consentField = consentTypeClass.getField("PAG_PA_CONSENT_TYPE_NO_CONSENT");
		Object noConsentConstant = consentField.get(null); // Pass 'null' because it's a static field.

		// Invoke PangleMediationAdapter.setPAConsent(consentConstant)
		Method setConsentMethod = adapterClass.getMethod("setPAConsent", int.class);
		setConsentMethod.invoke(null, hasCcpaConsent ? consentConstant : noConsentConstant); // The first argument is 'null' because the method is static.
	}
}
