//
// © 2026-present https://github.com/cengiz-pz
//

#import "AdmobTestFixtures.h"

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
