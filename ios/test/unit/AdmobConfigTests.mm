//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "admob_config.h"
#import "AdmobTestFixtures.h"

// ============================================================================
// AdmobConfigTests
// ============================================================================

@interface AdmobConfigTests : XCTestCase
@end

@implementation AdmobConfigTests

// ---------------------------------------------------------------------------
// isReal
// ---------------------------------------------------------------------------

- (void)testIsReal_true {
	Dictionary d = [AdmobTestFixtures makeMinimalConfigDictIsReal:YES];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertTrue([config isReal]);
}

- (void)testIsReal_false {
	Dictionary d = [AdmobTestFixtures makeMinimalConfigDictIsReal:NO];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertFalse([config isReal]);
}

// ---------------------------------------------------------------------------
// maxContentRating
// ---------------------------------------------------------------------------

- (void)testMaxContentRating_G {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertEqualObjects([config maxContentRating], @"G");
}

- (void)testMaxContentRating_MA {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"MA"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertEqualObjects([config maxContentRating], @"MA");
}

// ---------------------------------------------------------------------------
// childDirectedTreatment - unspecified (-1), false (0), true (1)
// ---------------------------------------------------------------------------

- (void)testChildDirectedTreatment_unspecified {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertNil([config childDirectedTreatment]);
}

- (void)testChildDirectedTreatment_true {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertNotNil([config childDirectedTreatment]);
	XCTAssertTrue([[config childDirectedTreatment] boolValue]);
}

- (void)testChildDirectedTreatment_false {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:0
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertNotNil([config childDirectedTreatment]);
	XCTAssertFalse([[config childDirectedTreatment] boolValue]);
}

// ---------------------------------------------------------------------------
// underAgeOfConsent
// ---------------------------------------------------------------------------

- (void)testUnderAgeOfConsent_unspecified {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertNil([config underAgeOfConsent]);
}

- (void)testUnderAgeOfConsent_true {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertTrue([[config underAgeOfConsent] boolValue]);
}

- (void)testUnderAgeOfConsent_false {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:0
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertFalse([[config underAgeOfConsent] boolValue]);
}

// ---------------------------------------------------------------------------
// firstPartyIdEnabled
// ---------------------------------------------------------------------------

- (void)testFirstPartyIdEnabled_true {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:YES
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertTrue([config firstPartyIdEnabled]);
}

- (void)testFirstPartyIdEnabled_false {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertFalse([config firstPartyIdEnabled]);
}

// ---------------------------------------------------------------------------
// personalizationState
// ---------------------------------------------------------------------------

- (void)testPersonalizationState_value1 {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:1
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertEqual([[config personalizationState] intValue], 1);
}

// ---------------------------------------------------------------------------
// testDeviceIds
// ---------------------------------------------------------------------------

- (void)testTestDeviceIds_empty {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertEqual([config testDeviceIds].count, 0UL);
}

- (void)testTestDeviceIds_twoIds {
	NSArray<NSString *> *ids = @[@"id1", @"id2"];
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:ids];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	NSArray *result = [config testDeviceIds];
	XCTAssertEqual(result.count, 2UL);
	XCTAssertTrue([result containsObject:@"id1"]);
	XCTAssertTrue([result containsObject:@"id2"]);
}

- (void)testTestDeviceIds_missingKeyReturnsEmpty {
	// Minimal dict has no test_device_ids key
	Dictionary d = [AdmobTestFixtures makeMinimalConfigDictIsReal:YES];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	XCTAssertEqual([config testDeviceIds].count, 0UL);
}

// ---------------------------------------------------------------------------
// applyToGADRequestConfiguration
// ---------------------------------------------------------------------------

- (void)testApplyToRequestConfig_setsMaxAdContentRating {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"PG"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	GADRequestConfiguration *reqConfig = [GADMobileAds sharedInstance].requestConfiguration;
	[config applyToGADRequestConfiguration:reqConfig];
	XCTAssertEqualObjects(reqConfig.maxAdContentRating, @"PG");
}

- (void)testApplyToRequestConfig_childDirectedTreatmentTrue {
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:YES
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	GADRequestConfiguration *reqConfig = [GADMobileAds sharedInstance].requestConfiguration;
	[config applyToGADRequestConfiguration:reqConfig];
	// If set to YES, must be @YES - just verify it doesn't raise
	XCTAssertNotNil(reqConfig.tagForChildDirectedTreatment);
}

- (void)testApplyToRequestConfig_testDeviceIdsAppended_nonReal {
	// In non-real mode device ids are added automatically
	Dictionary d = [AdmobTestFixtures makeConfigDictIsReal:NO
	                                     maxAdContentRating:@"G"
	                               childDirectedTreatment:-1
	                                  underAgeOfConsent:-1
	                                  firstPartyIdEnabled:NO
	                                 personalizationState:0
	                                        testDeviceIds:@[@"EXPLICIT_ID"]];
	AdmobConfig *config = [[AdmobConfig alloc] initWithDictionary:d];
	GADRequestConfiguration *reqConfig = [[GADRequestConfiguration alloc] init];
	[config applyToGADRequestConfiguration:reqConfig];
	// Explicit id must be present; auto-generated hash also added
	XCTAssertTrue([reqConfig.testDeviceIdentifiers containsObject:@"EXPLICIT_ID"]);
}

@end
