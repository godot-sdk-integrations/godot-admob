//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob.mediation.network;

import android.content.Context;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

import org.godotengine.plugin.android.admob.mediation.network.MediationNetwork;


public class UnityMediationNetwork extends MediationNetwork {

	public static final String TAG = "unity";
	private static final String ADAPTER_CLASS = "com.google.ads.mediation.unity.UnityMediationAdapter";

	public UnityMediationNetwork() {
		super(TAG);
	}

	@Override
	public String getAdapterClassName() {
		return ADAPTER_CLASS;
	}

	@Override
	protected void applyGDPRSettings(boolean hasGdprConsent, Context context) throws Exception {
		/*
		 * MetaData metaData = MetaData(context);
		 * metaData.set("gdpr.consent", true or false);
		 * metaData.set("privacy.consent", true or false);
		 * metaData.commit();
		 */

		// Get the required Class
		Class<?> metaDataClass = Class.forName("com.unity3d.ads.metadata.MetaData");

		// Instantiate MetaData: new MetaData(context); get the constructor that takes a Context object.
		Constructor<?> metaDataConstructor = metaDataClass.getConstructor(Context.class);

		// Create the new object instance, passing the 'context' instance.
		Object metaDataInstance = metaDataConstructor.newInstance(context);

		// Get the Method object for set(String, Object), which is used twice for the 'gdpr.consent' and 'privacy.consent' keys.
		Method setMethod = metaDataClass.getMethod("set", String.class, Object.class);

		// metaData.set("gdpr.consent", true);
		setMethod.invoke(metaDataInstance, "gdpr.consent", hasGdprConsent ? true : false);

		// Get the Method object for commit()
		Method commitMethod = metaDataClass.getMethod("commit");

		// metaData.commit();
		commitMethod.invoke(metaDataInstance);
	}

	@Override
	protected void applyAgeRestrictedUserSettings(boolean isAgeRestrictedUser, Context context) throws Exception {
		throw new UnsupportedOperationException();
	}

	@Override
	protected void applyCCPASettings(boolean hasCcpaConsent, Context context) throws Exception {
		/*
		 * MetaData metaData = MetaData(context);
		 * metaData.set("gdpr.consent", true or false);
		 * metaData.set("privacy.consent", true or false);
		 * metaData.commit();
		 */

		// Get the required Class
		Class<?> metaDataClass = Class.forName("com.unity3d.ads.metadata.MetaData");

		// Instantiate MetaData: new MetaData(context); get the constructor that takes a Context object.
		Constructor<?> metaDataConstructor = metaDataClass.getConstructor(Context.class);

		// Create the new object instance, passing the 'context' instance.
		Object metaDataInstance = metaDataConstructor.newInstance(context);

		// Get the Method object for set(String, Object), which is used twice for the 'gdpr.consent' and 'privacy.consent' keys.
		Method setMethod = metaDataClass.getMethod("set", String.class, Object.class);

		// metaData.set("privacy.consent", true);
		setMethod.invoke(metaDataInstance, "privacy.consent", hasCcpaConsent ? true : false);

		// Get the Method object for commit()
		Method commitMethod = metaDataClass.getMethod("commit");

		// metaData.commit();
		commitMethod.invoke(metaDataInstance);
	}
}
