//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.model;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.android.admob.AdmobPlugin;

public class PrivacySettings {
	private static final String CLASS_NAME = PrivacySettings.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	public interface PrivacySetter {
		void apply(PrivacySettings instance, Activity activity);
	}

	private static Map<String, PrivacySetter> PrivacySetters;

	static {
		PrivacySetters = new HashMap<>();
		PrivacySetters.put("applovin", (instance, activity) -> instance.applyApplovinSettings(activity));
		PrivacySetters.put("chartboost", (instance, activity) -> instance.applyChartboostSettings(activity));
		PrivacySetters.put("dtexchange", (instance, activity) -> instance.applyDtexchangeSettings(activity));
		PrivacySetters.put("imobile", (instance, activity) -> instance.applyImobileSettings(activity));
		PrivacySetters.put("inmobi", (instance, activity) -> instance.applyInmobiSettings(activity));
		PrivacySetters.put("ironsource", (instance, activity) -> instance.applyIronsourceSettings(activity));
		PrivacySetters.put("liftoff", (instance, activity) -> instance.applyLiftoffSettings(activity));
		PrivacySetters.put("line", (instance, activity) -> instance.applyLineSettings(activity));
		PrivacySetters.put("maio", (instance, activity) -> instance.applyMaioSettings(activity));
		PrivacySetters.put("meta", (instance, activity) -> instance.applyMetaSettings(activity));
		PrivacySetters.put("mintegral", (instance, activity) -> instance.applyMintegralSettings(activity));
		PrivacySetters.put("moloco", (instance, activity) -> instance.applyMolocoSettings(activity));
		PrivacySetters.put("mytarget", (instance, activity) -> instance.applyMytargetSettings(activity));
		PrivacySetters.put("pangle", (instance, activity) -> instance.applyPangleSettings(activity));
		PrivacySetters.put("unity", (instance, activity) -> instance.applyUnitySettings(activity));
	}

	public static final String HAS_GDPR_CONSENT_PROPERTY = "has_gdpr_consent";
	public static final String IS_AGE_RESTRICTED_USER_PROPERTY = "is_age_restricted_user";
	public static final String HAS_CCPA_SALE_CONSENT_PROPERTY = "has_ccpa_sale_consent";
	public static final String ENABLED_NETWORKS_PROPERTY = "enabled_networks";

	private Dictionary rawData;

	public PrivacySettings(Dictionary rawData) {
		this.rawData = rawData;
	}

	public void applyPrivacySettings(Activity activity) {
		Log.d(LOG_TAG, "applyPrivacySettings()");
		Object[] enabledNetworksArray = getEnabledNetworks();
		Log.d(LOG_TAG, "Found " + enabledNetworksArray.length + " enabled networks to process");

		for (Object network : enabledNetworksArray) {
			PrivacySetter setter = PrivacySetters.get((String) network);
			if (setter != null) {
				setter.apply(this, activity);
			} else {
				Log.i(LOG_TAG, "Privacy setter not found for network '" + network + "'");
			}
		}
	}

	// Network-Specific Setters

	private void applyApplovinSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for AppLovin");
		try {
			// Get the required privacy settings class
			Class<?> privacyClass = Class.forName("com.applovin.sdk.AppLovinPrivacySettings");

			if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
				/*
				 * AppLovinPrivacySettings.setHasUserConsent(true or false);
				 */
				Method setConsentMethod = privacyClass.getMethod("setHasUserConsent", boolean.class, Context.class);
				setConsentMethod.invoke(null, hasGdprConsent(), activity.getApplicationContext()); // static call
				Log.d(LOG_TAG, "AppLovinPrivacySettings.setHasUserConsent() called successfully.");
			}

			if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
				/*
				 * AppLovinPrivacySettings.setDoNotSell(true or false);
				 */
				Method setDoNotSellMethod = privacyClass.getMethod("setDoNotSell", boolean.class, Context.class);
				setDoNotSellMethod.invoke(null, !hasCcpaSaleConsent(), activity.getApplicationContext()); // static call
				Log.d(LOG_TAG, "AppLovinPrivacySettings.setDoNotSell() called successfully.");
			}
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set AppLovin privacy settings: ");
		}
	}

	private void applyChartboostSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for Chartboost");

		try {
			Class<?> chartboostClass = Class.forName("com.chartboost.sdk.Chartboost");

			// The second parameter for addDataUseConsent()
			Class<?> dataUseConsentInterface = Class.forName("com.chartboost.sdk.privacy.model.DataUseConsent");

			// Get the Method object for addDataUseConsent(Context, DataUseConsent)
			Method addConsentMethod = chartboostClass.getMethod("addDataUseConsent", Context.class, dataUseConsentInterface);

			if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
				/*
				 * DataUseConsent dataUseConsent = new GDPR(GDPR.GDPR_CONSENT.BEHAVIORAL [or NON_BEHAVIORAL]);
				 * Chartboost.addDataUseConsent(context, dataUseConsent);
				 */
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
				Object dataUseConsent = gdprConstructor.newInstance(hasGdprConsent() ? behavioralConstant : nonBehavioralConstant);

				// Invoke the static method. The first argument is 'null' because the method is static.
				addConsentMethod.invoke(null, activity.getApplicationContext(), dataUseConsent);

				Log.d(LOG_TAG, "Chartboost GDPR consent set successfully.");
			}

			if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
				/*
				 * DataUseConsent dataUseConsent = new CCPA(CCPA.CCPA_CONSENT.OPT_IN_SALE);
				 * Chartboost.addDataUseConsent(context, dataUseConsent);
				 */
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
				Object dataUseConsent = ccpaConstructor.newInstance(hasCcpaSaleConsent() ? optInConstant : optOutConstant);

				// Invoke the static method. The first argument is 'null' because the method is static.
				addConsentMethod.invoke(null, activity.getApplicationContext(), dataUseConsent);

				Log.d(LOG_TAG, "Chartboost CCPA sale consent set successfully.");
			}
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set Chartboost privacy settings: ");
		}
	}

	private void applyDtexchangeSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for DT Exchange");

		// DT Exchange SDK automatically retrieves GDPR since version 8.3.0

		if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			/*
			 * InneractiveAdManager.setUSPrivacyString("1YNN" or "1YYN");
			 */
			try {
				// Get the Class object for InneractiveAdManager
				Class<?> managerClass = Class.forName("com.fyber.inneractive.sdk.external.InneractiveAdManager");

				// Get the Method object for setUSPrivacyString(String)
				Method setPrivacyMethod = managerClass.getMethod("setUSPrivacyString", String.class);

				// "1---": CCPA does not apply, for example, the user is not a California resident
				// "1YNN": User does NOT opt out, ad experience continues
				// "1YYN": User opts out of targeted advertising
				String privacyString = "1" + (hasCcpaSaleConsent() ? "N" : "Y") + "NN";

				// Invoke the static method. The first argument is 'null' because the method is static, the second is the array of arguments to pass (the String value).
				setPrivacyMethod.invoke(null, privacyString);

				Log.d(LOG_TAG, "InneractiveAdManager.setUSPrivacyString(\"" + privacyString + "\") called successfully.");
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set DT Exchange privacy settings: ");
			}
		}
	}

	private void applyImobileSettings(Activity activity) {
		Log.i(LOG_TAG, "Privacy settings are not applicable for Imobile");
	}

	private void applyInmobiSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for InMobi");

		if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
			/*
			 * JSONObject consentObject = new JSONObject();
			 * consentObject.put(InMobiSdk.IM_GDPR_CONSENT_AVAILABLE, true);
			 * consentObject.put("gdpr", "1" or "0");
			 * InMobiConsent.updateGDPRConsent(consentObject);
			 */
			try {
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
				putMethod.invoke(consentObject, "gdpr", hasGdprConsent() ? "1" : "0");

				// Get the Class object for InMobiConsent
				Class<?> consentClass = Class.forName("com.google.ads.mediation.inmobi.InMobiConsent");

				// Get the Method object for updateGDPRConsent(String)
				Method updateConsentMethod = consentClass.getMethod("updateGDPRConsent", jsonObjectClass);
				
				// Invoke the static method with 'null', because the method is static, and the consentObject.
				updateConsentMethod.invoke(null, consentObject);

				Log.d(LOG_TAG, "InMobi GDPR consent set successfully.");
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set InMobi privacy settings: ");
			}
		}

		// InMobi SDK added support to read CCPA from shared preferences in version 10.5.7.1
	}

	private void applyIronsourceSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for ironSource");

		// ironSource SDK automatically reads GDPR consent set by UMP SDK since version 7.7.0

		if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			/*
			 * LevelPlay.setMetaData("do_not_sell", "true" or "false");
			 */
			try {
				// Get the Class object for LevelPlay
				Class<?> levelPlayClass = Class.forName("com.unity3d.mediation.LevelPlay");

				// Get the Method object for setMetaData(String, String)
				Method setMetaDataMethod = levelPlayClass.getMethod("setMetaData", String.class, String.class);

				String value = hasCcpaSaleConsent() ? "true" : "false";

				// Invoke the static method with 'null', because the method is static, and the key and value Strings.
				setMetaDataMethod.invoke(null, "do_not_sell", value);

				Log.d(LOG_TAG, "LevelPlay.setMetaData(\"do_not_sell\", \"" + value + "\") called successfully.");
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set ironSource privacy settings: ");
			}
		}
	}

	private void applyLiftoffSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for Liftoff Monetize");

		// Liftoff Monetize automatically reads GDPR consent set by UMP SDK since Vungle SDK version 7.7.0

		if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			/*
			 * VunglePrivacySettings.setCCPAStatus(true or false);
			 */
			try {
				// Get the Class object for VunglePrivacySettings
				Class<?> privacyClass = Class.forName("com.vungle.ads.VunglePrivacySettings");

				// Get the Method object for setCCPAStatus(boolean)
				Method setStatusMethod = privacyClass.getMethod("setCCPAStatus", boolean.class);

				// Invoke the static method with 'null', because the method is static, and the boolean value.
				setStatusMethod.invoke(null, hasCcpaSaleConsent());

				Log.d(LOG_TAG, "VunglePrivacySettings.setCCPAStatus(" + Boolean.toString(hasCcpaSaleConsent()) + ") called successfully.");
			} catch (Exception e) {
				Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set ironSource privacy settings: ");
			}
		}
	}

	private void applyLineSettings(Activity activity) {
		Log.i(LOG_TAG, "Privacy settings are not applicable for Line");
	}

	private void applyMaioSettings(Activity activity) {
		Log.i(LOG_TAG, "Privacy settings are not applicable for Maio");
	}

	private void applyMetaSettings(Activity activity) {
		Log.i(LOG_TAG, "Privacy settings are not applicable for Meta");
	}

	private void applyMintegralSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for Mintegral");

		try {
			/*
			 * MBridgeSDK sdk = MBridgeSDKFactory.getMBridgeSDK();
			 */

			// Get the required Classes
			Class<?> sdkFactoryClass = Class.forName("com.mbridge.msdk.out.MBridgeSDKFactory");
			Class<?> sdkClass = Class.forName("com.mbridge.msdk.MBridgeSDK");

			// Instantiate MBridgeSDK: MBridgeSDKFactory.getMBridgeSDK()
			Method getSdkMethod = sdkFactoryClass.getMethod("getMBridgeSDK");
			Object mBridgeSdkInstance = getSdkMethod.invoke(null);

			if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
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
				setConsentMethod.invoke(mBridgeSdkInstance, activity.getApplicationContext(), hasGdprConsent() ? switchOnConstant : switchOffConstant);

				Log.d(LOG_TAG, "MBridgeSDK GDPR consent status set successfully.");
			}

			if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
				/*
				 * sdk.setDoNotTrackStatus(true or false);
				 */

				// Get sdk.setDoNotTrackStatus(value)
				Method setDoNotTrackStatusMethod = sdkClass.getMethod("setDoNotTrackStatus", int.class);

				// Invoke the instance method with the 'mBridgeSdkInstance' object and the subsequent boolean argument value.
				setDoNotTrackStatusMethod.invoke(mBridgeSdkInstance, !hasCcpaSaleConsent());

				Log.d(LOG_TAG, "MBridgeSDK CCPA sale consent status set successfully.");
			}
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set Mintegral privacy settings: ");
		}
	}

	private void applyMolocoSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for Moloco");

		try {
			/*
			 * PrivacySettings privacySettings = new PrivacySettings(
			 *           / isUserConsent /         false,
			 *           / isAgeRestrictedUser /   false,
			 *           / isDoNotSell /           true);
			 * MolocoPrivacy.setPrivacy(privacySettings);
			 */

			//  Get the required Classes using the fully qualified names
			Class<?> privacySettingsClass = Class.forName("com.moloco.sdk.publisher.privacy.MolocoPrivacy$PrivacySettings");
			Class<?> molocoPrivacyClass = Class.forName("com.moloco.sdk.publisher.privacy.MolocoPrivacy");

			// Instantiate PrivacySettings: new PrivacySettings(false, false, true) constructor
			Constructor<?> settingsConstructor = privacySettingsClass.getConstructor(
				Boolean.class, // isUserConsent
				Boolean.class, // isAgeRestrictedUser
				Boolean.class  // isDoNotSell
			);

			// Create the new object instance, passing the argument values
			Object privacySettingsInstance = settingsConstructor.newInstance(
				rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY) ? hasGdprConsent() : false,
				rawData.containsKey(IS_AGE_RESTRICTED_USER_PROPERTY) ? isAgeRestrictedUser() : false,
				rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY) ? !hasCcpaSaleConsent() : true
			);

			// Invoke MolocoPrivacy.setPrivacy(privacySettings)
			Method setPrivacyMethod = molocoPrivacyClass.getMethod("setPrivacy", privacySettingsClass);
			setPrivacyMethod.invoke(null, privacySettingsInstance);

			Log.d(LOG_TAG, "MolocoPrivacy.setPrivacy(new PrivacySettings(isUserConsent, isAgeRestrictedUser, isDoNotSell)) called successfully.");
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set Moloco privacy settings: ");
		}
	}

	private void applyMytargetSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for myTarget");

		try {
			// Get the Class object for MyTargetPrivacy
			Class<?> privacyClass = Class.forName("com.my.target.common.MyTargetPrivacy");

			if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
				/*
				* MyTargetPrivacy.setUserConsent(true or false);
				*/

				// Get the Method object for setUserConsent(boolean)
				Method setUserConsentMethod = privacyClass.getMethod("setUserConsent", boolean.class);

				// Invoke the static method with 'null', because the method is static, and the boolean value.
				setUserConsentMethod.invoke(null, hasGdprConsent());

				Log.d(LOG_TAG, "MyTargetPrivacy.setUserConsentMethod(" + Boolean.toString(hasGdprConsent()) + ") called successfully.");
			}

			if (rawData.containsKey(IS_AGE_RESTRICTED_USER_PROPERTY)) {
				/*
				* MyTargetPrivacy.setUserAgeRestricted(true or false);
				*/

				// Get the Method object for setUserAgeRestricted(boolean)
				Method setUserAgeRestrictedMethod = privacyClass.getMethod("setUserAgeRestricted", boolean.class);

				// Invoke the static method with 'null', because the method is static, and the boolean value.
				setUserAgeRestrictedMethod.invoke(null, isAgeRestrictedUser());

				Log.d(LOG_TAG, "MyTargetPrivacy.setUserAgeRestricted(" + Boolean.toString(isAgeRestrictedUser()) + ") called successfully.");
			}

			if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
				/*
				* MyTargetPrivacy.setCcpaUserConsent(true or false);
				*/

				// Get the Method object for setCcpaUserConsent(boolean)
				Method setCcpaUserConsentMethod = privacyClass.getMethod("setCcpaUserConsent", boolean.class);

				// Invoke the static method with 'null', because the method is static, and the boolean value.
				setCcpaUserConsentMethod.invoke(null, hasCcpaSaleConsent());

				Log.d(LOG_TAG, "MyTargetPrivacy.setCcpaUserConsent(" + Boolean.toString(hasCcpaSaleConsent()) + ") called successfully.");
			}
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set myTarget privacy settings: ");
		}
	}

	private void applyPangleSettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for Pangle");

		try {
			// Get the required Classes
			Class<?> adapterClass = Class.forName("com.google.ads.mediation.pangle.PangleMediationAdapter");
			Class<?> constantClass = Class.forName("com.bytedance.sdk.openadsdk.api.PAGConstant"); 

			if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
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
				setConsentMethod.invoke(null, hasGdprConsent() ? consentConstant : noConsentConstant); // The first argument is 'null' because the method is static.

				Log.d(LOG_TAG, "PangleMediationAdapter.setGDPRConsent(...) called successfully.");
			}

			if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
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
				setConsentMethod.invoke(null, hasCcpaSaleConsent() ? consentConstant : noConsentConstant); // The first argument is 'null' because the method is static.

				Log.d(LOG_TAG, "PangleMediationAdapter.setPAConsent(...) called successfully.");
			}
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set Pangle privacy settings: ");
		}
	}

	private void applyUnitySettings(Activity activity) {
		Log.d(LOG_TAG, "Applying privacy settings for Unity");

		try {
			/*
			 * MetaData metaData = MetaData(activity);
			 * metaData.set("gdpr.consent", true or false);
			 * metaData.set("privacy.consent", true or false);
			 * metaData.commit();
			 */

			// Get the required Class
			Class<?> metaDataClass = Class.forName("com.unity3d.ads.metadata.MetaData");

			// Instantiate MetaData: new MetaData(activity); get the constructor that takes an Activity object.
			Constructor<?> metaDataConstructor = metaDataClass.getConstructor(Activity.class);

			// Create the new object instance, passing the 'activity' instance.
			Object metaDataInstance = metaDataConstructor.newInstance(activity);

			// Get the Method object for set(String, Object), which is used twice for the 'gdpr.consent' and 'privacy.consent' keys.
			Method setMethod = metaDataClass.getMethod("set", String.class, Object.class);

			boolean needCommit = false;

			if (rawData.containsKey(HAS_GDPR_CONSENT_PROPERTY)) {
				// metaData.set("gdpr.consent", true);
				setMethod.invoke(metaDataInstance, "gdpr.consent", hasGdprConsent() ? true : false);
				needCommit = true;
			}

			if (rawData.containsKey(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
				// metaData.set("privacy.consent", true);
				setMethod.invoke(metaDataInstance, "privacy.consent", hasCcpaSaleConsent() ? true : false);
				needCommit = true;
			}

			if (needCommit) {
				// Get the Method object for commit()
				Method commitMethod = metaDataClass.getMethod("commit");

				// metaData.commit();
				commitMethod.invoke(metaDataInstance);

				Log.e(LOG_TAG, "UnityAds MetaData set and committed successfully.");
			}
		} catch (Exception e) {
			Log.e(LOG_TAG, e.getClass().getSimpleName() + ":: " + e.getMessage() + ":: Failed to set Unity privacy settings: ");
		}
	}

	// Getters

	private boolean hasGdprConsent() {
		return (boolean) rawData.get(HAS_GDPR_CONSENT_PROPERTY);
	}

	private boolean isAgeRestrictedUser() {
		return (boolean) rawData.get(IS_AGE_RESTRICTED_USER_PROPERTY);
	}

	private boolean hasCcpaSaleConsent() {
		return (boolean) rawData.get(HAS_CCPA_SALE_CONSENT_PROPERTY);
	}

	private Object[] getEnabledNetworks() {
		return rawData.containsKey(ENABLED_NETWORKS_PROPERTY) ? (Object[]) rawData.get(ENABLED_NETWORKS_PROPERTY) : new String[0];
	}
}
