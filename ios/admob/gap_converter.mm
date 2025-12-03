//
// © 2024-present https://github.com/cengiz-pz
//

#import "gap_converter.h"

#import <AdSupport/ASIdentifierManager.h>

#include <CommonCrypto/CommonDigest.h>

#import "admob_logger.h"

@implementation GAPConverter


// FROM GODOT

+ (NSString*) toNsString:(String) godotString {
	return [NSString stringWithUTF8String:godotString.utf8().get_data()];
}

+ (NSString*) toAdId:(NSString*) unitId withSequence:(int) value {
	return [NSString stringWithFormat:@"%s-%d", [unitId UTF8String], value];
}

+ (id) toNsObject:(Variant) godotValue {
	switch (godotValue.get_type()) {
		case Variant::Type::NIL:
			return [NSNull null];

		case Variant::Type::BOOL:
			return [NSNumber numberWithBool:(bool)godotValue];

		case Variant::Type::INT:
			return [NSNumber numberWithLongLong:(int64_t)godotValue];

		case Variant::Type::FLOAT:
			return [NSNumber numberWithDouble:(double)godotValue];

		case Variant::Type::STRING:
			return [GAPConverter toNsString:(String)godotValue];

		case Variant::Type::ARRAY: {
			Array array = godotValue;
			NSMutableArray *nsArray = [NSMutableArray arrayWithCapacity:array.size()];
			for (int i = 0; i < array.size(); ++i) {
				id nsValue = [GAPConverter toNsObject:array[i]];
				[nsArray addObject:nsValue ?: [NSNull null]];
			}
			return nsArray;
		}

		case Variant::Type::DICTIONARY:
			return [GAPConverter toNsDictionary:(Dictionary)godotValue];

		case Variant::Type::VECTOR2:
		case Variant::Type::VECTOR3:
		case Variant::Type::VECTOR4:
		case Variant::Type::COLOR:
		case Variant::Type::RECT2:
		case Variant::Type::RECT2I:
		case Variant::Type::TRANSFORM2D:
		case Variant::Type::TRANSFORM3D:
			// For these, use string serialization (you can customize this)
			return [GAPConverter toNsString:godotValue.operator String()];

		default:
			// Unsupported or complex type — convert to string fallback
			return [GAPConverter toNsString:godotValue.operator String()];
	}
}

+ (NSDictionary*) toNsDictionary:(Dictionary)godotDictionary {
	NSMutableDictionary *nsDictionary = [NSMutableDictionary dictionary];

	Array keys = godotDictionary.keys();
	int size = keys.size();
	for (int i = 0; i < size; ++i) {
		Variant key = keys[i];
		Variant value = godotDictionary[key];

		id nsKey = [GAPConverter toNsObject:key];
		id nsValue = [GAPConverter toNsObject:value];

		if (!nsKey) nsKey = [NSNull null];
		if (!nsValue) nsValue = [NSNull null];

		// Ensure key is NSString (NSDictionary requires NSString keys)
		if (![nsKey isKindOfClass:[NSString class]]) {
			nsKey = [nsKey description];
		}

		[nsDictionary setObject:nsValue forKey:nsKey];
	}

	return nsDictionary;
}


+ (NSArray*) toNsStringArray: (Array) arr {
	NSMutableArray* result = [[NSMutableArray alloc] init];
	for (int i = 0; i < arr.size(); ++i) {
		NSString *value = [GAPConverter toNsString:arr[i]];
		if (value != NULL) {
			[result addObject:value];
		} else {
			WARN_PRINT("Trying to add something unsupported to the array.");
		}
	}
	return result;
}

+ (GADPublisherPrivacyPersonalizationState)intToPublisherPrivacyPersonalizationState:(Variant) intValue {
	GADPublisherPrivacyPersonalizationState state;
	switch((int) intValue) {
		case 1:
			state = GADPublisherPrivacyPersonalizationStateEnabled;
			break;
		case 2:
			state = GADPublisherPrivacyPersonalizationStateDisabled;
			break;
		default:
			state = GADPublisherPrivacyPersonalizationStateDefault;
	}
	return state;
}

+ (AdPosition) nsStringToAdPosition:(NSString*) nsString {
	AdPosition adPosition;

	if ([nsString isEqualToString:@"TOP"]) {
		adPosition = AdPositionTop;
	} else if ([nsString isEqualToString:@"BOTTOM"]) {
		adPosition = AdPositionBottom;
	} else if ([nsString isEqualToString:@"LEFT"]) {
		adPosition = AdPositionLeft;
	} else if ([nsString isEqualToString:@"RIGHT"]) {
		adPosition = AdPositionLeft;
	} else if ([nsString isEqualToString:@"TOP_LEFT"]) {
		adPosition = AdPositionTopLeft;
	} else if ([nsString isEqualToString:@"TOP_RIGHT"]) {
		adPosition = AdPositionTopRight;
	} else if ([nsString isEqualToString:@"BOTTOM_LEFT"]) {
		adPosition = AdPositionBottomLeft;
	} else if ([nsString isEqualToString:@"BOTTOM_RIGHT"]) {
		adPosition = AdPositionBottomRight;
	} else if ([nsString isEqualToString:@"CENTER"]) {
		adPosition = AdPositionCenter;
	} else if ([nsString isEqualToString:@"CUSTOM"]) {
		adPosition = AdPositionCustom;
	} else {
		os_log_error(admob_log, "AdmobPlugin banner load: ERROR: invalid ad position '%@'", nsString);
		adPosition = AdPositionTop;
	}

	return adPosition;
}

+ (GADAdSize) nsStringToAdSize:(NSString*) nsString {
	GADAdSize adSize;

	if ([nsString isEqualToString:@"BANNER"]) {
		adSize = GADAdSizeBanner;
	} else if ([nsString isEqualToString:@"LARGE_BANNER"]) {
		adSize = GADAdSizeLargeBanner;
	} else if ([nsString isEqualToString:@"MEDIUM_RECTANGLE"]) {
		adSize = GADAdSizeMediumRectangle;
	} else if ([nsString isEqualToString:@"FULL_BANNER"]) {
		adSize = GADAdSizeFullBanner;
	} else if ([nsString isEqualToString:@"LEADERBOARD"]) {
		adSize = GADAdSizeLeaderboard;
	} else if ([nsString isEqualToString:@"SKYSCRAPER"]) {
		adSize = GADAdSizeSkyscraper;
	} else if ([nsString isEqualToString:@"FLUID"]) {
		adSize = GADAdSizeFluid;
	} else {
		adSize = GADAdSizeInvalid;
		os_log_error(admob_log, "AdmobPlugin nsStringToAdSize: ERROR: invalid ad size '%@'", nsString);
	}

	return adSize;
}

+ (GADServerSideVerificationOptions*) godotDictionaryToServerSideVerificationOptions:(Dictionary) godotDictionary {
	GADServerSideVerificationOptions *options = [[GADServerSideVerificationOptions alloc] init];

	String custom_data = godotDictionary["custom_data"];
	String user_id = godotDictionary["user_id"];

	NSString *customData = [GAPConverter toNsString:custom_data];
	NSString *userId = [GAPConverter toNsString:user_id];

	if (customData && ![customData isEqualToString:@""]) {
		options.customRewardString = customData;
	}

	if (userId && ![userId isEqualToString:@""]) {
		options.userIdentifier = userId;
	}

	return options;
}

+ (UMPRequestParameters *) godotDictionaryToUMPRequestParameters:(Dictionary) godotDictionary {
	UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

	if (godotDictionary.has("tag_for_under_age_of_consent")) {
		bool tagForUnderAgeOfConsent = (bool) godotDictionary["tag_for_under_age_of_consent"];
		parameters.tagForUnderAgeOfConsent = tagForUnderAgeOfConsent;
	}

	bool debugMode = false;
	if (godotDictionary.has("is_real")) {
		debugMode = !(bool) godotDictionary["is_real"];
	}

	if (debugMode) {
		parameters.debugSettings = [GAPConverter godotDictionaryToUMPDebugSettings:godotDictionary];
	}

	return parameters;
}

+ (UMPDebugSettings *)godotDictionaryToUMPDebugSettings:(Dictionary)godotDictionary {
	UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];

	// Handle debug geography
	if (godotDictionary.has("debug_geography")) {
		int debugGeographyValue = (int)godotDictionary["debug_geography"];
		os_log_debug(admob_log, "Debug geography value from dictionary: %d", debugGeographyValue);
		switch (debugGeographyValue) {
			case 0: // DEBUG_GEOGRAPHY_DISABLED
				debugSettings.geography = UMPDebugGeographyDisabled;
				break;
			case 1: // DEBUG_GEOGRAPHY_EEA
				debugSettings.geography = UMPDebugGeographyEEA;
				break;
			case 3: // DEBUG_GEOGRAPHY_REGULATED_US_STATE
				debugSettings.geography = UMPDebugGeographyRegulatedUSState;
				break;
			default:
				os_log_error(admob_log, "Unsupported debug geography value: %d, defaulting to UMPDebugGeographyOther", debugGeographyValue);
			case 2: // DEBUG_GEOGRAPHY_NOT_EEA deprecated
			case 4: // DEBUG_GEOGRAPHY_OTHER
				debugSettings.geography = UMPDebugGeographyOther;
				break;
		}
	} else {
		os_log_debug(admob_log, "No debug_geography key found in dictionary, defaulting to Disabled");
		debugSettings.geography = UMPDebugGeographyDisabled;
	}

	// Handle test device hashed IDs
	if (godotDictionary.has("test_device_hashed_ids")) {
		Array testDeviceIds = godotDictionary["test_device_hashed_ids"];
		NSMutableArray<NSString *> *convertedArray = [NSMutableArray array];
		for (int i = 0; i < testDeviceIds.size(); i++) {
			String item = testDeviceIds[i];
			NSString *deviceId = [NSString stringWithUTF8String:item.utf8().get_data()];
			[convertedArray addObject:deviceId];
			os_log_debug(admob_log, "Added test device ID: %@", deviceId);
		}
		[convertedArray addObject:[GAPConverter getAdmobDeviceID]];
		debugSettings.testDeviceIdentifiers = convertedArray;
	} else {
		os_log_debug(admob_log, "No test_device_hashed_ids key found in dictionary");
		NSMutableArray<NSString *> *convertedArray = [NSMutableArray array];
		[convertedArray addObject:[GAPConverter getAdmobDeviceID]];
		debugSettings.testDeviceIdentifiers = convertedArray;
	}

	return debugSettings;
}


// TO GODOT

+ (String) nsStringToGodotString:(NSString*) nsString {
	return [nsString UTF8String];
}

+ (Dictionary) nsDictionaryToGodotDictionary:(NSDictionary*) nsDictionary {
	Dictionary dictionary = Dictionary();

	for (NSObject* keyObject in [nsDictionary allKeys]) {
		if (keyObject && [keyObject isKindOfClass:[NSString class]]) {
			NSString* key = (NSString*) keyObject;

			NSObject* valueObject = [nsDictionary objectForKey:key];
			if (valueObject) {
				if ([valueObject isKindOfClass:[NSString class]]) {
					NSString* value = (NSString*) valueObject;
					dictionary[[key UTF8String]] = (value) ? [value UTF8String] : "";
				}
				else if ([valueObject isKindOfClass:[NSNumber class]]) {
					NSNumber* value = (NSNumber*) valueObject;
					if (strcmp([value objCType], @encode(BOOL)) == 0) {
						dictionary[[key UTF8String]] = (int) [value boolValue];
					} else if (strcmp([value objCType], @encode(char)) == 0) {
						dictionary[[key UTF8String]] = (int) [value charValue];
					} else if (strcmp([value objCType], @encode(int)) == 0) {
						dictionary[[key UTF8String]] = [value intValue];
					} else if (strcmp([value objCType], @encode(unsigned int)) == 0) {
						dictionary[[key UTF8String]] = (int) [value unsignedIntValue];
					} else if (strcmp([value objCType], @encode(long long)) == 0) {
						dictionary[[key UTF8String]] = (int) [value longValue];
					} else if (strcmp([value objCType], @encode(float)) == 0) {
						dictionary[[key UTF8String]] = [value floatValue];
					} else if (strcmp([value objCType], @encode(double)) == 0) {
						dictionary[[key UTF8String]] = (float) [value doubleValue];
					}
				}
				else if ([valueObject isKindOfClass:[NSDictionary class]]) {
					NSDictionary* value = (NSDictionary*) valueObject;
					dictionary[[key UTF8String]] = [GAPConverter nsDictionaryToGodotDictionary:value];
				}
			}
		}
	}

	return dictionary;
}

+ (Dictionary) adRewardToGodotDictionary:(GADAdReward*) adReward {
	Dictionary dictionary;

	dictionary["type"] = adReward.type.UTF8String;
	dictionary["amount"] = [adReward.amount intValue];

	return dictionary;
}

+ (Dictionary) nsFormErrorToGodotDictionary:(NSError*) nsError {
	Dictionary dictionary;

	dictionary["error_code"] = (int) nsError.code;
	dictionary["message"] = [nsError.localizedDescription UTF8String];

	return dictionary;
}


// UTIL

+ (NSString*) getAdmobDeviceID {
	NSUUID* adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
	const char *cStr = [adid.UUIDString UTF8String];

	unsigned char digest[CC_SHA256_DIGEST_LENGTH];

	CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);

	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}

	return output;
}

+ (NSString *) convertTrackingStatusToString:(ATTrackingManagerAuthorizationStatus) status API_AVAILABLE(ios(14)) {
	switch (status) {
		case ATTrackingManagerAuthorizationStatusDenied:
			return @"denied";
		case ATTrackingManagerAuthorizationStatusAuthorized:
			return @"authorized";
		case ATTrackingManagerAuthorizationStatusRestricted:
			return @"restricted";
		case ATTrackingManagerAuthorizationStatusNotDetermined:
			return @"not-determined";
	}
}

@end
