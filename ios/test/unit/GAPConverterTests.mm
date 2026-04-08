//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>

#import "gap_converter.h"
#import "AdmobTestFixtures.h"

// ============================================================================
// GAPConverterTests
// ============================================================================

@interface GAPConverterTests : XCTestCase
@end

@implementation GAPConverterTests

// ---------------------------------------------------------------------------
// toNsString:
// ---------------------------------------------------------------------------

- (void)testToNsString_emptyString {
	String godot = "";
	NSString *result = [GAPConverter toNsString:godot];
	XCTAssertNotNil(result);
	XCTAssertEqualObjects(result, @"");
}

- (void)testToNsString_asciiString {
	String godot = "hello world";
	NSString *result = [GAPConverter toNsString:godot];
	XCTAssertEqualObjects(result, @"hello world");
}

- (void)testToNsString_unicodeString {
	// Use String::utf8() so Godot correctly interprets the literal as UTF-8
	String godot = String::utf8("こんにちは");
	NSString *result = [GAPConverter toNsString:godot];
	XCTAssertEqualObjects(result, @"こんにちは");
}

- (void)testToNsString_specialCharacters {
	String godot = "ad/unit#1?param=value&other=true";
	NSString *result = [GAPConverter toNsString:godot];
	XCTAssertEqualObjects(result, @"ad/unit#1?param=value&other=true");
}

// ---------------------------------------------------------------------------
// toAdId:withSequence:
// ---------------------------------------------------------------------------

- (void)testToAdId_zeroSequence {
	NSString *result = [GAPConverter toAdId:@"ca-app-pub-123/456" withSequence:0];
	XCTAssertEqualObjects(result, @"ca-app-pub-123/456-0");
}

- (void)testToAdId_positiveSequence {
	NSString *result = [GAPConverter toAdId:@"unit-id" withSequence:42];
	XCTAssertEqualObjects(result, @"unit-id-42");
}

- (void)testToAdId_largeSequence {
	NSString *result = [GAPConverter toAdId:@"unit" withSequence:INT_MAX];
	NSString *expected = [NSString stringWithFormat:@"unit-%d", INT_MAX];
	XCTAssertEqualObjects(result, expected);
}

// ---------------------------------------------------------------------------
// toNsObject: - variant type coverage
// ---------------------------------------------------------------------------

- (void)testToNsObject_nil {
	Variant v; // NIL variant
	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSNull class]]);
}

- (void)testToNsObject_boolTrue {
	Variant v = true;
	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
	XCTAssertEqual([(NSNumber *)result boolValue], YES);
}

- (void)testToNsObject_boolFalse {
	Variant v = false;
	id result = [GAPConverter toNsObject:v];
	XCTAssertEqual([(NSNumber *)result boolValue], NO);
}

- (void)testToNsObject_int {
	Variant v = (int64_t)99;
	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
	XCTAssertEqual([(NSNumber *)result longLongValue], 99LL);
}

- (void)testToNsObject_float {
	Variant v = 3.14;
	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
	XCTAssertEqualWithAccuracy([(NSNumber *)result doubleValue], 3.14, 1e-6);
}

- (void)testToNsObject_string {
	Variant v = String("test-string");
	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSString class]]);
	XCTAssertEqualObjects(result, @"test-string");
}

- (void)testToNsObject_array {
	Array godotArray;
	godotArray.push_back(Variant(String("a")));
	godotArray.push_back(Variant((int64_t)2));
	Variant v = godotArray;

	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	NSArray *arr = (NSArray *)result;
	XCTAssertEqual(arr.count, 2UL);
	XCTAssertEqualObjects(arr[0], @"a");
	XCTAssertEqual([arr[1] longLongValue], 2LL);
}

- (void)testToNsObject_arrayWithNilElement {
	Array godotArray;
	godotArray.push_back(Variant()); // NIL element
	Variant v = godotArray;

	id result = [GAPConverter toNsObject:v];
	NSArray *arr = (NSArray *)result;
	XCTAssertEqual(arr.count, 1UL);
	XCTAssertTrue([arr[0] isKindOfClass:[NSNull class]]);
}

- (void)testToNsObject_dictionary {
	Dictionary d;
	d[String("key")] = String("value");
	Variant v = d;

	id result = [GAPConverter toNsObject:v];
	XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
	XCTAssertEqualObjects([(NSDictionary *)result objectForKey:@"key"], @"value");
}

// ---------------------------------------------------------------------------
// toNsDictionary:
// ---------------------------------------------------------------------------

- (void)testToNsDictionary_emptyDictionary {
	Dictionary d;
	NSDictionary *result = [GAPConverter toNsDictionary:d];
	XCTAssertNotNil(result);
	XCTAssertEqual(result.count, 0UL);
}

- (void)testToNsDictionary_stringValues {
	Dictionary d;
	d[String("name")] = String("Alice");
	d[String("role")] = String("admin");

	NSDictionary *result = [GAPConverter toNsDictionary:d];
	XCTAssertEqual(result.count, 2UL);
	XCTAssertEqualObjects(result[@"name"], @"Alice");
	XCTAssertEqualObjects(result[@"role"], @"admin");
}

- (void)testToNsDictionary_mixedTypes {
	Dictionary d;
	d[String("flag")] = true;
	d[String("count")] = (int64_t)7;
	d[String("label")] = String("demo");

	NSDictionary *result = [GAPConverter toNsDictionary:d];
	XCTAssertEqual(result.count, 3UL);
	XCTAssertEqualObjects(result[@"label"], @"demo");
}

- (void)testToNsDictionary_nestedDictionary {
	Dictionary inner;
	inner[String("x")] = (int64_t)1;
	Dictionary outer;
	outer[String("inner")] = inner;

	NSDictionary *result = [GAPConverter toNsDictionary:outer];
	XCTAssertTrue([result[@"inner"] isKindOfClass:[NSDictionary class]]);
	XCTAssertEqual([result[@"inner"][@"x"] longLongValue], 1LL);
}

// ---------------------------------------------------------------------------
// toNsStringArray:
// ---------------------------------------------------------------------------

- (void)testToNsStringArray_empty {
	Array arr;
	NSArray *result = [GAPConverter toNsStringArray:arr];
	XCTAssertNotNil(result);
	XCTAssertEqual(result.count, 0UL);
}

- (void)testToNsStringArray_singleElement {
	Array arr;
	arr.push_back(Variant(String("keyword1")));
	NSArray *result = [GAPConverter toNsStringArray:arr];
	XCTAssertEqual(result.count, 1UL);
	XCTAssertEqualObjects(result[0], @"keyword1");
}

- (void)testToNsStringArray_multipleElements {
	Array arr;
	arr.push_back(Variant(String("a")));
	arr.push_back(Variant(String("b")));
	arr.push_back(Variant(String("c")));
	NSArray *result = [GAPConverter toNsStringArray:arr];
	XCTAssertEqual(result.count, 3UL);
	XCTAssertEqualObjects(result[2], @"c");
}

// ---------------------------------------------------------------------------
// intToPublisherPrivacyPersonalizationState:
// ---------------------------------------------------------------------------

- (void)testPersonalizationState_default {
	GADPublisherPrivacyPersonalizationState state =
			[GAPConverter intToPublisherPrivacyPersonalizationState:Variant((int64_t)0)];
	XCTAssertEqual(state, GADPublisherPrivacyPersonalizationStateDefault);
}

- (void)testPersonalizationState_enabled {
	GADPublisherPrivacyPersonalizationState state =
			[GAPConverter intToPublisherPrivacyPersonalizationState:Variant((int64_t)1)];
	XCTAssertEqual(state, GADPublisherPrivacyPersonalizationStateEnabled);
}

- (void)testPersonalizationState_disabled {
	GADPublisherPrivacyPersonalizationState state =
			[GAPConverter intToPublisherPrivacyPersonalizationState:Variant((int64_t)2)];
	XCTAssertEqual(state, GADPublisherPrivacyPersonalizationStateDisabled);
}

- (void)testPersonalizationState_unknownValueDefaultsToDefault {
	GADPublisherPrivacyPersonalizationState state =
			[GAPConverter intToPublisherPrivacyPersonalizationState:Variant((int64_t)99)];
	XCTAssertEqual(state, GADPublisherPrivacyPersonalizationStateDefault);
}

// ---------------------------------------------------------------------------
// godotDictionaryToServerSideVerificationOptions:
// ---------------------------------------------------------------------------

- (void)testSsvOptions_bothEmpty {
	Dictionary d = [AdmobTestFixtures makeSsvDictWithUserId:@"" customData:@""];
	GADServerSideVerificationOptions *opts = [GAPConverter godotDictionaryToServerSideVerificationOptions:d];
	XCTAssertNil(opts.userIdentifier);
	XCTAssertNil(opts.customRewardString);
}

- (void)testSsvOptions_userIdSet {
	Dictionary d = [AdmobTestFixtures makeSsvDictWithUserId:@"user-42" customData:@""];
	GADServerSideVerificationOptions *opts = [GAPConverter godotDictionaryToServerSideVerificationOptions:d];
	XCTAssertEqualObjects(opts.userIdentifier, @"user-42");
	XCTAssertNil(opts.customRewardString);
}

- (void)testSsvOptions_customDataSet {
	Dictionary d = [AdmobTestFixtures makeSsvDictWithUserId:@"" customData:@"reward=gold"];
	GADServerSideVerificationOptions *opts = [GAPConverter godotDictionaryToServerSideVerificationOptions:d];
	XCTAssertNil(opts.userIdentifier);
	XCTAssertEqualObjects(opts.customRewardString, @"reward=gold");
}

- (void)testSsvOptions_bothSet {
	Dictionary d = [AdmobTestFixtures makeSsvDictWithUserId:@"u1" customData:@"d1"];
	GADServerSideVerificationOptions *opts = [GAPConverter godotDictionaryToServerSideVerificationOptions:d];
	XCTAssertEqualObjects(opts.userIdentifier, @"u1");
	XCTAssertEqualObjects(opts.customRewardString, @"d1");
}

// ---------------------------------------------------------------------------
// godotDictionaryToUMPRequestParameters:
// ---------------------------------------------------------------------------

- (void)testUmpParams_realNoDebug {
	Dictionary d = [AdmobTestFixtures makeUmpParamsDictIsReal:YES tagForUnderAgeOfConsent:NO];
	UMPRequestParameters *params = [GAPConverter godotDictionaryToUMPRequestParameters:d];
	XCTAssertNotNil(params);
	XCTAssertFalse(params.tagForUnderAgeOfConsent);
	XCTAssertNil(params.debugSettings, @"Real mode should produce no debug settings");
}

- (void)testUmpParams_notRealProducesDebugSettings {
	Dictionary d = [AdmobTestFixtures makeUmpParamsDictIsReal:NO tagForUnderAgeOfConsent:NO];
	UMPRequestParameters *params = [GAPConverter godotDictionaryToUMPRequestParameters:d];
	XCTAssertNotNil(params.debugSettings);
}

- (void)testUmpParams_underAgeOfConsentFlagPassedThrough {
	Dictionary d = [AdmobTestFixtures makeUmpParamsDictIsReal:YES tagForUnderAgeOfConsent:YES];
	UMPRequestParameters *params = [GAPConverter godotDictionaryToUMPRequestParameters:d];
	XCTAssertTrue(params.tagForUnderAgeOfConsent);
}

// ---------------------------------------------------------------------------
// godotDictionaryToUMPDebugSettings: - geography branches
// ---------------------------------------------------------------------------

- (void)testUmpDebug_geographyDisabled {
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:0 testDeviceHashedIds:@[]];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	XCTAssertEqual(s.geography, UMPDebugGeographyDisabled);
}

- (void)testUmpDebug_geographyEEA {
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:1 testDeviceHashedIds:@[]];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	XCTAssertEqual(s.geography, UMPDebugGeographyEEA);
}

- (void)testUmpDebug_geographyRegulatedUSState {
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:3 testDeviceHashedIds:@[]];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	XCTAssertEqual(s.geography, UMPDebugGeographyRegulatedUSState);
}

- (void)testUmpDebug_geographyOther_value4 {
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:4 testDeviceHashedIds:@[]];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	XCTAssertEqual(s.geography, UMPDebugGeographyOther);
}

- (void)testUmpDebug_geographyDeprecatedNotEEA_value2 {
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:2 testDeviceHashedIds:@[]];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	XCTAssertEqual(s.geography, UMPDebugGeographyOther);
}

- (void)testUmpDebug_testDeviceIdsAppendedToList {
	NSArray<NSString *> *ids = @[@"FAKE_DEVICE_ID_1", @"FAKE_DEVICE_ID_2"];
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:0 testDeviceHashedIds:ids];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	// Fixture IDs plus the auto-generated device hash should all be present
	XCTAssertGreaterThanOrEqual(s.testDeviceIdentifiers.count, 2UL);
	XCTAssertTrue([s.testDeviceIdentifiers containsObject:@"FAKE_DEVICE_ID_1"]);
	XCTAssertTrue([s.testDeviceIdentifiers containsObject:@"FAKE_DEVICE_ID_2"]);
}

- (void)testUmpDebug_alwaysAddsAutoDeviceId {
	Dictionary d = [AdmobTestFixtures makeUmpDebugParamsDictWithGeography:0 testDeviceHashedIds:@[]];
	UMPDebugSettings *s = [GAPConverter godotDictionaryToUMPDebugSettings:d];
	// Even with no explicit IDs, the auto-generated hash must be added
	XCTAssertGreaterThanOrEqual(s.testDeviceIdentifiers.count, 1UL);
}

// ---------------------------------------------------------------------------
// nsStringToGodotString: - round-trip
// ---------------------------------------------------------------------------

- (void)testNsStringToGodotString_roundTrip {
	NSString *original = @"round-trip-test";
	String godot = [GAPConverter nsStringToGodotString:original];
	NSString *back = [GAPConverter toNsString:godot];
	XCTAssertEqualObjects(back, original);
}

// ---------------------------------------------------------------------------
// nsDictionaryToGodotDictionary:
// ---------------------------------------------------------------------------

- (void)testNsDictionaryToGodotDictionary_stringValue {
	NSDictionary *ns = @{ @"key" : @"value" };
	Dictionary result = [GAPConverter nsDictionaryToGodotDictionary:ns];
	String v = result[String("key")];
	XCTAssertTrue(strcmp(v.utf8().get_data(), "value") == 0);
}

- (void)testNsDictionaryToGodotDictionary_intValue {
	NSDictionary *ns = @{ @"n" : @(42) };
	Dictionary result = [GAPConverter nsDictionaryToGodotDictionary:ns];
	int v = result[String("n")];
	XCTAssertEqual(v, 42);
}

- (void)testNsDictionaryToGodotDictionary_floatValue {
	NSDictionary *ns = @{ @"f" : @(1.5f) };
	Dictionary result = [GAPConverter nsDictionaryToGodotDictionary:ns];
	float v = result[String("f")];
	XCTAssertEqualWithAccuracy(v, 1.5f, 1e-4f);
}

- (void)testNsDictionaryToGodotDictionary_boolValue {
	NSDictionary *ns = @{ @"flag" : @YES };
	Dictionary result = [GAPConverter nsDictionaryToGodotDictionary:ns];
	int v = result[String("flag")];
	XCTAssertEqual(v, 1);
}

- (void)testNsDictionaryToGodotDictionary_nonStringKeyIgnored {
	// NSDictionary keys must be NSString for conversion; numeric keys are skipped.
	NSDictionary *ns = @{ @(99) : @"value" };
	Dictionary result = [GAPConverter nsDictionaryToGodotDictionary:ns];
	XCTAssertEqual(result.size(), 0);
}

// ---------------------------------------------------------------------------
// adRewardToGodotDictionary:
// ---------------------------------------------------------------------------

- (void)testAdRewardToGodotDictionary {
	GADAdReward *reward = [[GADAdReward alloc] initWithRewardType:@"coins" rewardAmount:@(50)];
	Dictionary result = [GAPConverter adRewardToGodotDictionary:reward];

	NSString *type = [GAPConverter toNsString:(String)result[String("type")]];
	int amount = result[String("amount")];

	XCTAssertEqualObjects(type, @"coins");
	XCTAssertEqual(amount, 50);
}

// ---------------------------------------------------------------------------
// nsFormErrorToGodotDictionary:
// ---------------------------------------------------------------------------

- (void)testNsFormErrorToGodotDictionary {
	NSError *err = [NSError errorWithDomain:@"test"
									   code:404
								   userInfo:@{NSLocalizedDescriptionKey : @"not found"}];
	Dictionary result = [GAPConverter nsFormErrorToGodotDictionary:err];

	int code = result[String("error_code")];
	NSString *msg = [GAPConverter toNsString:(String)result[String("message")]];

	XCTAssertEqual(code, 404);
	XCTAssertEqualObjects(msg, @"not found");
}

// ---------------------------------------------------------------------------
// getAdmobDeviceID
// ---------------------------------------------------------------------------

- (void)testGetAdmobDeviceID_returnsNonNil {
	NSString *deviceId = [GAPConverter getAdmobDeviceID];
	XCTAssertNotNil(deviceId);
}

- (void)testGetAdmobDeviceID_isSHA256HexLength {
	NSString *deviceId = [GAPConverter getAdmobDeviceID];
	// SHA-256 hex = 64 characters
	XCTAssertEqual(deviceId.length, 64UL);
}

- (void)testGetAdmobDeviceID_isLowercase {
	NSString *deviceId = [GAPConverter getAdmobDeviceID];
	XCTAssertEqualObjects(deviceId, deviceId.lowercaseString);
}

- (void)testGetAdmobDeviceID_isDeterministic {
	NSString *id1 = [GAPConverter getAdmobDeviceID];
	NSString *id2 = [GAPConverter getAdmobDeviceID];
	XCTAssertEqualObjects(id1, id2);
}

// ---------------------------------------------------------------------------
// convertTrackingStatusToString: - all branches
// ---------------------------------------------------------------------------

- (void)testTrackingStatus_denied API_AVAILABLE(ios(14)) {
	NSString *s = [GAPConverter convertTrackingStatusToString:ATTrackingManagerAuthorizationStatusDenied];
	XCTAssertEqualObjects(s, @"denied");
}

- (void)testTrackingStatus_authorized API_AVAILABLE(ios(14)) {
	NSString *s = [GAPConverter convertTrackingStatusToString:ATTrackingManagerAuthorizationStatusAuthorized];
	XCTAssertEqualObjects(s, @"authorized");
}

- (void)testTrackingStatus_restricted API_AVAILABLE(ios(14)) {
	NSString *s = [GAPConverter convertTrackingStatusToString:ATTrackingManagerAuthorizationStatusRestricted];
	XCTAssertEqualObjects(s, @"restricted");
}

- (void)testTrackingStatus_notDetermined API_AVAILABLE(ios(14)) {
	NSString *s = [GAPConverter convertTrackingStatusToString:ATTrackingManagerAuthorizationStatusNotDetermined];
	XCTAssertEqualObjects(s, @"not-determined");
}

@end
