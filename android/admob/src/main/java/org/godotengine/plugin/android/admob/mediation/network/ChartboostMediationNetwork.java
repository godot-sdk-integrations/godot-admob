//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class ChartboostMediationNetwork extends MediationNetwork {

	public static final String TAG = "chartboost";
	static final String ADAPTER_CLASS = "com.google.ads.mediation.chartboost.ChartboostMediationAdapter";


	public ChartboostMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		/*
		 * DataUseConsent dataUseConsent = new GDPR(GDPR.GDPR_CONSENT.BEHAVIORAL [or NON_BEHAVIORAL]);
		 * Chartboost.addDataUseConsent(context, dataUseConsent);
		 */
		Class<?> chartboostClass = Class.forName("com.chartboost.sdk.Chartboost");

		// The second parameter for addDataUseConsent()
		Class<?> dataUseConsentInterface = Class.forName("com.chartboost.sdk.privacy.model.DataUseConsent");

		// Get the Method object for addDataUseConsent(Context, DataUseConsent)
		Method addConsentMethod = chartboostClass.getMethod("addDataUseConsent", Context.class, dataUseConsentInterface);

		Class<?> gdprClass = Class.forName("com.chartboost.sdk.privacy.model.GDPR");
		Class<?> gdprConsentClass = Class.forName("com.chartboost.sdk.privacy.model.GDPR$GDPR_CONSENT");

		// Get the public static field 'NON_BEHAVIORAL'
		Field consentConstantField = gdprConsentClass.getField("NON_BEHAVIORAL");
		// Retrieve the actual value of the static field. Pass 'null' because it's a static field.
		Object nonBehavioralConstant = consentConstantField.get(null);

		// Get the public static field 'BEHAVIORAL'
		consentConstantField = gdprConsentClass.getField("BEHAVIORAL");
		// Retrieve the actual value of the static field. Pass 'null' because it's a static field.
		Object behavioralConstant = consentConstantField.get(null);

		// Get the constructor for GDPR that takes a GDPR_CONSENT enum.
		Constructor<?> gdprConstructor = gdprClass.getConstructor(gdprConsentClass);

		// Call the constructor to create the new object.
		Object dataUseConsent = gdprConstructor.newInstance(hasGdprConsent ? behavioralConstant : nonBehavioralConstant);

		// Invoke the static method. The first argument is 'null' because the method is static.
		addConsentMethod.invoke(null, context, dataUseConsent);
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * DataUseConsent dataUseConsent = new CCPA(CCPA.CCPA_CONSENT.OPT_IN_SALE);
		 * Chartboost.addDataUseConsent(context, dataUseConsent);
		 */
		Class<?> chartboostClass = Class.forName("com.chartboost.sdk.Chartboost");

		// The second parameter for addDataUseConsent()
		Class<?> dataUseConsentInterface = Class.forName("com.chartboost.sdk.privacy.model.DataUseConsent");

		// Get the Method object for addDataUseConsent(Context, DataUseConsent)
		Method addConsentMethod = chartboostClass.getMethod("addDataUseConsent", Context.class, dataUseConsentInterface);

		Class<?> ccpaClass = Class.forName("com.chartboost.sdk.privacy.model.CCPA");
		Class<?> ccpaConsentClass = Class.forName("com.chartboost.sdk.privacy.model.CCPA$CCPA_CONSENT");

		// Get the public static field 'NON_BEHAVIORAL'
		Field consentConstantField = ccpaConsentClass.getField("OPT_OUT_SALE");
		// Retrieve the actual value of the static field. Pass 'null' because it's a static field.
		Object optOutConstant = consentConstantField.get(null);

		// Get the public static field 'BEHAVIORAL'
		consentConstantField = ccpaConsentClass.getField("OPT_IN_SALE");
		// Retrieve the actual value of the static field. Pass 'null' because it's a static field.
		Object optInConstant = consentConstantField.get(null);

		// Get the constructor for CCPA that takes a CCPA_CONSENT enum.
		Constructor<?> ccpaConstructor = ccpaClass.getConstructor(ccpaConsentClass);

		// Call the constructor to create the new object.
		Object dataUseConsent = ccpaConstructor.newInstance(hasCcpaConsent ? optInConstant : optOutConstant);

		// Invoke the static method. The first argument is 'null' because the method is static.
		addConsentMethod.invoke(null, context, dataUseConsent);
	}
}
