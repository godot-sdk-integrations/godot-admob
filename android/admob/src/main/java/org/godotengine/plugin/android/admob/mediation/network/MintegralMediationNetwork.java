//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class MintegralMediationNetwork extends MediationNetwork {

	public static final String TAG = "mintegral";
	private static final String ADAPTER_CLASS = "com.google.ads.mediation.mintegral.MintegralMediationAdapter";

	public MintegralMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		/*
		 * MBridgeSDK sdk = MBridgeSDKFactory.getMBridgeSDK();
		 */

		// Get the required Classes
		Class<?> sdkFactoryClass = Class.forName("com.mbridge.msdk.out.MBridgeSDKFactory");
		Class<?> sdkClass = Class.forName("com.mbridge.msdk.MBridgeSDK");

		// Instantiate MBridgeSDK: MBridgeSDKFactory.getMBridgeSDK()
		Method getSdkMethod = sdkFactoryClass.getMethod("getMBridgeSDK");
		Object mBridgeSdkInstance = getSdkMethod.invoke(null);

		/*
		 * sdk.setConsentStatus(context, MBridgeConstans.IS_SWITCH_ON);
		 */

		// Get the static constant values for MBridgeConstans.IS_SWITCH_ON and IS_SWITCH_OFF
		Class<?> constantsClass = Class.forName("com.mbridge.msdk.MBridgeConstans");
		Field constantsClassField = constantsClass.getField("IS_SWITCH_ON");
		Object switchOnConstant = constantsClassField.get(null); // Retrieve the actual value of the static field. Pass 'null' because it's static.
		constantsClassField = constantsClass.getField("IS_SWITCH_OFF");
		Object switchOffConstant = constantsClassField.get(null); // Retrieve the actual value of the static field. Pass 'null' because it's static.

		// Get sdk.setConsentStatus(context, MBridgeConstans.IS_SWITCH_ON or IS_SWITCH_OFF)
		Method setConsentMethod = sdkClass.getMethod("setConsentStatus", Context.class, int.class);

		// Invoke the instance method with the 'mBridgeSdkInstance' object and the subsequent arguments: 'context' and the constant value.
		setConsentMethod.invoke(mBridgeSdkInstance, context, hasGdprConsent ? switchOnConstant : switchOffConstant);
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * MBridgeSDK sdk = MBridgeSDKFactory.getMBridgeSDK();
		 */

		// Get the required Classes
		Class<?> sdkFactoryClass = Class.forName("com.mbridge.msdk.out.MBridgeSDKFactory");
		Class<?> sdkClass = Class.forName("com.mbridge.msdk.MBridgeSDK");

		// Instantiate MBridgeSDK: MBridgeSDKFactory.getMBridgeSDK()
		Method getSdkMethod = sdkFactoryClass.getMethod("getMBridgeSDK");
		Object mBridgeSdkInstance = getSdkMethod.invoke(null);

		/*
		 * sdk.setDoNotTrackStatus(true or false);
		 */

		// Get sdk.setDoNotTrackStatus(value)
		Method setDoNotTrackStatusMethod = sdkClass.getMethod("setDoNotTrackStatus", int.class);

		// Invoke the instance method with the 'mBridgeSdkInstance' object and the subsequent boolean argument value.
		setDoNotTrackStatusMethod.invoke(mBridgeSdkInstance, !hasCcpaConsent);
	}
}
