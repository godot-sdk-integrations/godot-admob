//
// © 2026-present https://github.com/cengiz-pz
//

#import "AdmobTestFixtures.h"

// Test ad-unit ID used by all native fixtures.
// Google's public test ID for native ads is safe to use without generating
// real traffic.
static NSString *const kNativeTestAdUnitId = @"ca-app-pub-3940256099942544/3986624511";

@implementation AdmobTestFixtures

// -- Load-ad-request helpers -------------------------------------------------

+ (Dictionary)makeLoadAdRequestDictWithUnit:(NSString *)adUnitId {
	Dictionary dict;
	dict["ad_unit_id"] = String([adUnitId UTF8String]);
	return dict;
}

+ (Dictionary)makeLoadAdRequestDictWithUnit:(NSString *)adUnitId
                                     adSize:(NSString *)adSize
                                 adPosition:(NSString *)adPosition {
	Dictionary dict;
	dict["ad_unit_id"] = String([adUnitId UTF8String]);
	dict["ad_size"] = String([adSize UTF8String]);
	dict["ad_position"] = String([adPosition UTF8String]);
	return dict;
}

+ (Dictionary)makeCollapsibleAdRequestDictWithUnit:(NSString *)adUnitId
                                 collapsiblePosition:(NSString *)position {
	Dictionary dict;
	dict["ad_unit_id"] = String([adUnitId UTF8String]);
	dict["collapsible_position"] = String([position UTF8String]);
	return dict;
}

+ (Dictionary)makeRewardedAdRequestDictWithUnit:(NSString *)adUnitId
                                         userId:(NSString *)userId
                                     customData:(NSString *)customData {
	Dictionary dict;
	dict["ad_unit_id"] = String([adUnitId UTF8String]);
	if (userId && userId.length > 0) {
		dict["user_id"] = String([userId UTF8String]);
	}
	if (customData && customData.length > 0) {
		dict["custom_data"] = String([customData UTF8String]);
	}
	return dict;
}

+ (Dictionary)makeAdRequestDictWithUnit:(NSString *)adUnitId
                               keywords:(NSArray<NSString *> *)keywords {
	Dictionary dict;
	dict["ad_unit_id"] = String([adUnitId UTF8String]);
	dict["keywords"] = [AdmobTestFixtures makeGodotStringArray:keywords];
	return dict;
}

+ (Dictionary)makeInlineAdaptiveAdRequestDictWithUnit:(NSString *)adUnitId
                                        adaptiveWidth:(CGFloat)width
                                            maxHeight:(CGFloat)maxHeight {
	Dictionary dict;
	dict["ad_unit_id"] = String([adUnitId UTF8String]);
	dict["ad_size"] = String("INLINE_ADAPTIVE");
	dict["adaptive_width"] = (double)width;
	if (maxHeight > 0) {
		dict["adaptive_max_height"] = (double)maxHeight;
	}
	return dict;
}

// -- Native ad option helpers ------------------------------------------------

+ (Dictionary)makeMinimalNativeRequest {
	Dictionary dict;
	dict["ad_unit_id"] = String([kNativeTestAdUnitId UTF8String]);
	return dict;
}

+ (Dictionary)makeNativeRequestWithMediaAspectRatio:(NSString *)ratio {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_media_aspect_ratio"] = String([ratio UTF8String]);
	return dict;
}

+ (Dictionary)makeNativeRequestWithReturnUrlsForImageAssets:(BOOL)value {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_return_urls_for_image_assets"] = (bool)value;
	return dict;
}

+ (Dictionary)makeNativeRequestWithRequestMultipleImages:(BOOL)value {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_request_multiple_images"] = (bool)value;
	return dict;
}

+ (Dictionary)makeNativeRequestWithAdChoicesPlacement:(NSString *)placement {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_ad_choices_placement"] = String([placement UTF8String]);
	return dict;
}

+ (Dictionary)makeNativeRequestWithImageScaleType:(NSString *)scaleType {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_image_scale_type"] = String([scaleType UTF8String]);
	return dict;
}

+ (Dictionary)makeNativeRequestWithValidatorDisabled:(BOOL)value {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_disable_validator"] = (bool)value;
	return dict;
}

+ (Dictionary)makeFullNativeRequest {
	Dictionary dict = [self makeMinimalNativeRequest];
	dict["native_media_aspect_ratio"] = String("LANDSCAPE");
	dict["native_return_urls_for_image_assets"] = true;
	dict["native_request_multiple_images"] = true;
	dict["native_ad_choices_placement"] = String("BOTTOM_LEFT");
	dict["native_image_scale_type"] = String("CENTER_CROP");
	dict["native_disable_validator"] = true;
	return dict;
}

// -- AdmobConfig helpers -----------------------------------------------------

+ (Dictionary)makeConfigDictIsReal:(BOOL)isReal
                 maxAdContentRating:(NSString *)rating
           childDirectedTreatment:(int)childDirected
              underAgeOfConsent:(int)underAge
              firstPartyIdEnabled:(BOOL)firstParty
             personalizationState:(int)personalization
                    testDeviceIds:(NSArray<NSString *> *)deviceIds {
	Dictionary dict;
	dict["is_real"] = (bool)isReal;
	dict["max_ad_content_rating"] = String([rating UTF8String]);
	dict["tag_for_child_directed_treatment"] = childDirected;
	dict["tag_for_under_age_of_consent"] = underAge;
	dict["first_party_id_enabled"] = (bool)firstParty;
	dict["personalization_state"] = personalization;
	dict["test_device_ids"] = [AdmobTestFixtures makeGodotStringArray:deviceIds];
	return dict;
}

+ (Dictionary)makeMinimalConfigDictIsReal:(BOOL)isReal {
	Dictionary dict;
	dict["is_real"] = (bool)isReal;
	return dict;
}

// -- UMP helpers -------------------------------------------------------------

+ (Dictionary)makeUmpParamsDictIsReal:(BOOL)isReal
              tagForUnderAgeOfConsent:(BOOL)underAge {
	Dictionary dict;
	dict["is_real"] = (bool)isReal;
	dict["tag_for_under_age_of_consent"] = (bool)underAge;
	return dict;
}

+ (Dictionary)makeUmpDebugParamsDictWithGeography:(int)geography
                              testDeviceHashedIds:(NSArray<NSString *> *)deviceIds {
	Dictionary dict;
	dict["is_real"] = false;
	dict["debug_geography"] = geography;
	dict["test_device_hashed_ids"] = [AdmobTestFixtures makeGodotStringArray:deviceIds];
	return dict;
}

// -- AdSettings helpers ------------------------------------------------------

+ (Dictionary)makeAdSettingsDictWithVolume:(float)volume
                                     muted:(BOOL)muted
                            applyAtStartup:(BOOL)apply {
	Dictionary dict;
	dict["ad_volume"] = (float)volume;
	dict["ads_muted"] = (bool)muted;
	dict["apply_at_startup"] = (bool)apply;
	return dict;
}

// -- SSV helpers -------------------------------------------------------------

+ (Dictionary)makeSsvDictWithUserId:(NSString *)userId customData:(NSString *)customData {
	Dictionary dict;
	if (userId) {
		dict["user_id"] = String([userId UTF8String]);
	}
	if (customData) {
		dict["custom_data"] = String([customData UTF8String]);
	}
	return dict;
}

// -- Generic helpers ---------------------------------------------------------

+ (Array)makeGodotStringArray:(NSArray<NSString *> *)strings {
	Array array;
	for (NSString *s in strings) {
		array.push_back(Variant(String([s UTF8String])));
	}
	return array;
}

@end
