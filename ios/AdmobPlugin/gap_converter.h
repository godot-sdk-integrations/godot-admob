//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef gap_converter_h
#define gap_converter_h

#import <Foundation/Foundation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

#include "core/object/class_db.h"
#include <UserMessagingPlatform/UMPRequestParameters.h>

#import "ad_position.h"


@import GoogleMobileAds;

@class GADInitializationStatus;

@interface GAPConverter : NSObject

// From Godot
+ (NSString*) toNsString:(String) godotString;
+ (NSString*) toAdId:(NSString*)unitId withSequence:(int) value;
+ (id) toNsObject:(Variant) godotValue;
+ (NSDictionary*) toNsDictionary:(Dictionary) godotDictionary;
+ (NSArray*) toNsStringArray:(Array) arr;
+ (GADPublisherPrivacyPersonalizationState) intToPublisherPrivacyPersonalizationState:(Variant) intValue;
+ (AdPosition) nsStringToAdPosition:(NSString*) nsString;
+ (GADAdSize) nsStringToAdSize:(NSString*) nsString;
+ (GADServerSideVerificationOptions*) godotDictionaryToServerSideVerificationOptions:(Dictionary) godotDictionary;
+ (UMPRequestParameters*) godotDictionaryToUMPRequestParameters:(Dictionary) godotDictionary;
+ (UMPDebugSettings*) godotDictionaryToUMPDebugSettings:(Dictionary) godotDictionary;


// To Godot
+ (String) nsStringToGodotString:(NSString*) nsString;
+ (Dictionary) nsDictionaryToGodotDictionary:(NSDictionary*) nsDictionary;
+ (Dictionary) initializationStatusToGodotDictionary:(GADInitializationStatus*) status;
+ (Dictionary) adapterStatusToGodotDictionary:(GADAdapterStatus*) adapterStatus;
+ (Dictionary) adSizeToGodotDictionary:(GADAdSize) adSize;
+ (Dictionary) responseInfoToGodotDictionary:(GADResponseInfo*) responseInfo;
+ (Dictionary) adNetworkResponseInfoToGodotDictionary:(GADAdNetworkResponseInfo*) adNetworkResponseInfo;
+ (Dictionary) adNetworkInfoArrayToGodotDictionary:(NSArray<GADAdNetworkResponseInfo*>*) adNetworkInfoArray;
+ (Dictionary) adRewardToGodotDictionary:(GADAdReward*) adReward;
+ (Dictionary) nsAdErrorToGodotDictionary:(NSError*) nsError;
+ (Dictionary) nsLoadErrorToGodotDictionary:(NSError*) nsError;
+ (Dictionary) nsFormErrorToGodotDictionary:(NSError*) nsError;


// Util
+ (NSString *) getAdmobDeviceID;
+ (NSString *) convertTrackingStatusToString:(ATTrackingManagerAuthorizationStatus) status API_AVAILABLE(ios(14));

@end

#endif /* gap_converter_h */
