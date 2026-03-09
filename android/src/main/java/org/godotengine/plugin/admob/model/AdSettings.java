//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import org.godotengine.godot.Dictionary;

import org.godotengine.plugin.admob.AdmobPlugin;


public class AdSettings {
	private static final String CLASS_NAME = AdSettings.class.getSimpleName();
	private static final String LOG_TAG = "godot::" + AdmobPlugin.CLASS_NAME + "::" + CLASS_NAME;

	private static final String DATA_KEY_AD_VOLUME = "ad_volume";
	private static final String DATA_KEY_ADS_MUTED = "ads_muted";
	private static final String DATA_KEY_APPLY_AT_STARTUP = "apply_at_startup";

	public static final float DEFAULT_AD_VOLUME = 1.0f;
	public static final boolean DEFAULT_ADS_MUTED = false;
	public static final boolean DEFAULT_APPLY_AT_STARTUP = false;

	private Dictionary data;

	public AdSettings() {
		this.data = new Dictionary();
	}

	public AdSettings(Dictionary data) {
		this.data = data;
	}


	public boolean hasAdVolume() {
		return data.containsKey(DATA_KEY_AD_VOLUME);
	}


	public float getAdVolume() {
		float volume = DEFAULT_AD_VOLUME;
		if (hasAdVolume()) {
			Object val = data.get(DATA_KEY_AD_VOLUME);
			if (val instanceof Number) {
				volume = ((Number) val).floatValue();
			}
		}
		return volume;
	}


	public AdSettings setAdVolume(float value) {
		data.put(DATA_KEY_AD_VOLUME, value);
		return this;
	}


	public boolean hasAdsMuted() {
		return data.containsKey(DATA_KEY_ADS_MUTED);
	}


	public boolean areAdsMuted() {
		return hasAdsMuted() ? (boolean) data.get(DATA_KEY_ADS_MUTED) : DEFAULT_ADS_MUTED;
	}


	public AdSettings setAdsMuted(boolean value) {
		data.put(DATA_KEY_ADS_MUTED, value);
		return this;
	}


	public boolean hasApplyAtStartup() {
		return data.containsKey(DATA_KEY_APPLY_AT_STARTUP);
	}


	public boolean getApplyAtStartup() {
		return hasApplyAtStartup() ? (boolean) data.get(DATA_KEY_APPLY_AT_STARTUP) : DEFAULT_APPLY_AT_STARTUP;
	}


	public AdSettings setApplyAtStartup(boolean value) {
		data.put(DATA_KEY_APPLY_AT_STARTUP, value);
		return this;
	}


	public Dictionary getRawData() {
		return data;
	}
}
