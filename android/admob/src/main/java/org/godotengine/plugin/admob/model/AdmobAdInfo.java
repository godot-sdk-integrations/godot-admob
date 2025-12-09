//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import org.godotengine.godot.Dictionary;


public class AdmobAdInfo {

	private static String AD_ID_PROPERTY = "ad_id";
	private static String MEASURED_WIDTH_PROPERTY = "measured_width";
	private static String MEASURED_HEIGHT_PROPERTY = "measured_height";
	private static String IS_COLLAPSIBLE_PROPERTY = "is_collapsible";
	private static String LOAD_AD_REQUEST_PROPERTY = "load_ad_request";

	private String adId;
	private int measuredWidth;
	private int measuredHeight;
	private boolean isCollapsible;
	private LoadAdRequest loadAdRequest;

	public AdmobAdInfo(String adId, LoadAdRequest loadAdRequest) {
		this.adId = adId;
		this.isCollapsible = false;
		this.loadAdRequest = loadAdRequest;
	}

	public String getAdId() {
		return this.adId;
	}

	public int getMeasuredWidth() {
		return this.measuredWidth;
	}

	public void setMeasuredWidth(int width) {
		this.measuredWidth = width;
	}

	public int getMeasuredHeight() {
		return this.measuredHeight;
	}

	public void setMeasuredHeight(int height) {
		this.measuredHeight = height;
	}

	public void setIsCollapsible(boolean isCollapsible) {
		this.isCollapsible = isCollapsible;
	}

	public LoadAdRequest getLoadAdRequest() {
		return this.loadAdRequest;
	}

	public Dictionary buildRawData() {
		Dictionary dict = new Dictionary();

		dict.put(AD_ID_PROPERTY, this.adId);
		dict.put(MEASURED_WIDTH_PROPERTY, this.measuredWidth);
		dict.put(MEASURED_HEIGHT_PROPERTY, this.measuredHeight);
		dict.put(IS_COLLAPSIBLE_PROPERTY, this.isCollapsible);
		dict.put(LOAD_AD_REQUEST_PROPERTY, this.loadAdRequest == null ? new Dictionary() : this.loadAdRequest.getRawData());

		return dict;
	}
}
