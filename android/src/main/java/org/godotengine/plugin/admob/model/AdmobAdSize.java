//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import com.google.android.gms.ads.AdSize;

import org.godotengine.godot.Dictionary;


public class AdmobAdSize {

	private static String WIDTH_PROPERTY = "width";
	private static String HEIGHT_PROPERTY = "height";

	private AdSize adSize;

	public AdmobAdSize(AdSize adSize) {
		this.adSize = adSize;
	}

	public Dictionary buildRawData() {
		Dictionary dict = new Dictionary();

		dict.put(WIDTH_PROPERTY, adSize.getWidth());
		dict.put(HEIGHT_PROPERTY, adSize.getHeight());

		return dict;
	}
}
