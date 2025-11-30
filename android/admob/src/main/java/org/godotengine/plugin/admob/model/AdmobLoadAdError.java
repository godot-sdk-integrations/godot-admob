//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.ResponseInfo;

import org.godotengine.godot.Dictionary;


public class AdmobLoadAdError extends AdmobAdError {

	private static String RESPONSE_INFO_PROPERTY = "response_info";

	private LoadAdError loadAdError;

	public AdmobLoadAdError(LoadAdError loadAdError) {
		super(loadAdError);
		this.loadAdError = loadAdError;
	}

	public Dictionary buildRawData() {
		Dictionary dict = super.buildRawData();

		ResponseInfo responseInfo = loadAdError.getResponseInfo();
		dict.put(RESPONSE_INFO_PROPERTY, responseInfo == null ? new Dictionary() : new AdmobResponse(responseInfo).buildRawData());

		return dict;
	}
}
