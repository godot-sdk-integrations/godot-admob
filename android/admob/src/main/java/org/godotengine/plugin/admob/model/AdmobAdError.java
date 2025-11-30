//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import com.google.android.gms.ads.AdError;

import org.godotengine.godot.Dictionary;


public class AdmobAdError {

	private static String CODE_PROPERTY = "code";
	private static String DOMAIN_PROPERTY = "domain";
	private static String MESSAGE_PROPERTY = "message";
	private static String CAUSE_PROPERTY = "cause";

	private AdError error;

	public AdmobAdError(AdError error) {
		this.error = error;
	}

	public Dictionary buildRawData() {
		Dictionary dict = new Dictionary();

		dict.put(CODE_PROPERTY, error.getCode());
		dict.put(DOMAIN_PROPERTY, error.getDomain());
		dict.put(MESSAGE_PROPERTY, error.getMessage());

		AdError cause = error.getCause();
		dict.put(CAUSE_PROPERTY, cause == null ? new Dictionary() : new AdmobAdError(cause).buildRawData());

		return dict;
	}
}
