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

+ (NSDictionary*) toNsDictionary:(Dictionary) godotDictionary {
	NSMutableDictionary *nsDictionary = [NSMutableDictionary dictionary];

	Array keys = godotDictionary.keys();
	int size = keys.size();
	for (int i = 0; i < size; ++i) {
		String key = keys[i];
		String value = godotDictionary[key];
		NSString *nsKey = [GAPConverter toNsString:key];
		NSString *nsValue = [GAPConverter toNsString:value];

		[nsDictionary setValue:nsValue forKey:nsKey];
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

+ (UMPDebugSettings*) godotDictionaryToUMPDebugSettings:(Dictionary) godotDictionary {
	UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
	
	int debugGeographyValue = godotDictionary["debug_geography"];
	debugSettings.geography = (UMPDebugGeography) debugGeographyValue;

	Dictionary testDeviceHashedIds = godotDictionary["test_device_hashed_ids"];
	Array testDeviceIds = testDeviceHashedIds.values();

	NSMutableArray<NSString *> *convertedArray = [NSMutableArray array];
	for (int i = 0; i < testDeviceIds.size(); i++) {
		String item = testDeviceIds[i];
		[convertedArray addObject:[NSString stringWithUTF8String:item.utf8().get_data()]];
	}

	[convertedArray addObject:[GAPConverter getAdmobDeviceID]];
	
	debugSettings.testDeviceIdentifiers = convertedArray;

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

+ (Dictionary) adapterStatusToGodotDictionary:(GADAdapterStatus*) adapterStatus {
	Dictionary dictionary;

	dictionary["latency"] = adapterStatus.latency;
	dictionary["initialization_state"] = (int)adapterStatus.state;
	dictionary["description"] = [adapterStatus.description UTF8String];

	return dictionary;
}

+ (Dictionary) initializationStatusToGodotDictionary:(GADInitializationStatus*) status {
	Dictionary dictionary;
	NSDictionary<NSString *, GADAdapterStatus *> *statusMap = status.adapterStatusesByClassName;
	for (NSString *adapterClass in statusMap) {
		Dictionary adapterStatusDictionary = [GAPConverter adapterStatusToGodotDictionary:status.adapterStatusesByClassName[adapterClass]];
		dictionary[[adapterClass UTF8String]] = adapterStatusDictionary;
	}

	return dictionary;
}

+ (Dictionary) adSizeToGodotDictionary:(GADAdSize) adSize {
	Dictionary dictionary;
	
	dictionary["width"] = adSize.size.width;
	dictionary["height"] = adSize.size.height;
	 
	return dictionary;
}

+ (Dictionary) responseInfoToGodotDictionary:(GADResponseInfo*) responseInfo {
	Dictionary dictionary;

	dictionary["response_identifier"] = responseInfo.responseIdentifier ? [responseInfo.responseIdentifier UTF8String] : "";
	dictionary["extras_dictionary"] = [GAPConverter nsDictionaryToGodotDictionary:responseInfo.extrasDictionary];
	dictionary["loaded_ad_network_response_info"] = [GAPConverter adNetworkResponseInfoToGodotDictionary:responseInfo.loadedAdNetworkResponseInfo];
	dictionary["ad_network_info_array"] = [GAPConverter adNetworkInfoArrayToGodotDictionary:responseInfo.adNetworkInfoArray];
	dictionary["dictionary_representation"] = [GAPConverter nsDictionaryToGodotDictionary:responseInfo.dictionaryRepresentation];
	
	return dictionary;
}

+ (Dictionary) adNetworkResponseInfoToGodotDictionary:(GADAdNetworkResponseInfo*) adNetworkResponseInfo {
	Dictionary dictionary;
	
	dictionary["ad_network_class_name"] = adNetworkResponseInfo.adNetworkClassName.UTF8String;
	dictionary["ad_unit_mapping"] = [GAPConverter nsDictionaryToGodotDictionary:adNetworkResponseInfo.adUnitMapping];
	dictionary["ad_source_name"] = adNetworkResponseInfo.adSourceName.UTF8String;
	dictionary["ad_source_id"] = adNetworkResponseInfo.adSourceID.UTF8String;
	dictionary["ad_source_instance_name"] = adNetworkResponseInfo.adSourceInstanceName.UTF8String;
	dictionary["ad_source_instance_id"] = adNetworkResponseInfo.adSourceInstanceID.UTF8String;
	dictionary["error"] = adNetworkResponseInfo.error ? [GAPConverter nsAdErrorToGodotDictionary:adNetworkResponseInfo.error] : Dictionary();
	dictionary["latency"] = adNetworkResponseInfo.latency;
	dictionary["dictionary_representation"] = [GAPConverter nsDictionaryToGodotDictionary:adNetworkResponseInfo.dictionaryRepresentation];
	
	return dictionary;
}

+ (Dictionary) adNetworkInfoArrayToGodotDictionary:(NSArray<GADAdNetworkResponseInfo*>*) adNetworkInfoArray {
	Dictionary dictionary;

	for (int i = 0; i < adNetworkInfoArray.count; i++) {
		GADAdNetworkResponseInfo *responseInfo = [adNetworkInfoArray objectAtIndex:i];
		dictionary[i] = [GAPConverter adNetworkResponseInfoToGodotDictionary:responseInfo];
	}
	
	return dictionary;
}

+ (Dictionary) adRewardToGodotDictionary:(GADAdReward*) adReward {
	Dictionary dictionary;

	dictionary["type"] = adReward.type.UTF8String;
	dictionary["amount"] = [adReward.amount intValue];

	return dictionary;
}

+ (Dictionary) nsAdErrorToGodotDictionary:(NSError*) nsError {
	Dictionary dictionary;
	
	dictionary["code"] = (int) nsError.code;
	dictionary["domain"] = [nsError.domain UTF8String];
	dictionary["message"] = [nsError.localizedDescription UTF8String];
	dictionary["cause"] = (nsError.userInfo[NSUnderlyingErrorKey]) ? [GAPConverter nsAdErrorToGodotDictionary:nsError.userInfo[NSUnderlyingErrorKey]] : Dictionary();
	
	return dictionary;
}

+ (Dictionary) nsLoadErrorToGodotDictionary:(NSError*) nsError {
	Dictionary dictionary;
	
	dictionary = [GAPConverter nsAdErrorToGodotDictionary:nsError];
	GADResponseInfo* responseInfo = nsError.userInfo[GADErrorUserInfoKeyResponseInfo];
	dictionary["response_info"] = (responseInfo) ? [GAPConverter responseInfoToGodotDictionary:responseInfo] : Dictionary();

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
	unsigned char digest[16];
	CC_MD5(cStr, strlen(cStr), digest);

	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];

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
