//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "load_ad_request.h"
#import "AdmobTestFixtures.h"

// ============================================================================
// File-scope helpers
// ============================================================================

typedef struct {
	const char *name;
	AdPosition expected;
} AdPositionCase;

// ============================================================================
// LoadAdRequestTests
// ============================================================================

@interface LoadAdRequestTests : XCTestCase
@end

@implementation LoadAdRequestTests

// ---------------------------------------------------------------------------
// adUnitId
// ---------------------------------------------------------------------------

- (void)testAdUnitId_returnsValue {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"ca-app-pub-000/111"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualObjects([req adUnitId], @"ca-app-pub-000/111");
}

- (void)testAdUnitId_missingKeyReturnsEmpty {
	Dictionary d;
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualObjects([req adUnitId], @"");
}

// ---------------------------------------------------------------------------
// requestAgent
// ---------------------------------------------------------------------------

- (void)testRequestAgent_set {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"unit"];
	d["request_agent"] = String("godot-admob-plugin");
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualObjects([req requestAgent], @"godot-admob-plugin");
}

- (void)testRequestAgent_missingKeyReturnsEmpty {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"unit"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualObjects([req requestAgent], @"");
}

// ---------------------------------------------------------------------------
// adSize / hasAdaptiveWidth / adaptiveWidth / hasAdaptiveMaxHeight / adaptiveMaxHeight
// ---------------------------------------------------------------------------

- (void)testAdSize_banner {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"BANNER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualObjects([req adSize], @"BANNER");
}

- (void)testHasAdaptiveWidth_true {
	Dictionary d = [AdmobTestFixtures makeInlineAdaptiveAdRequestDictWithUnit:@"u"
	                                                             adaptiveWidth:320
	                                                                 maxHeight:0];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasAdaptiveWidth]);
}

- (void)testAdaptiveWidth_returnsValue {
	Dictionary d = [AdmobTestFixtures makeInlineAdaptiveAdRequestDictWithUnit:@"u"
	                                                             adaptiveWidth:320
	                                                                 maxHeight:0];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualWithAccuracy([req adaptiveWidth], 320.0, 0.01);
}

- (void)testHasAdaptiveWidth_false {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req hasAdaptiveWidth]);
}

- (void)testHasAdaptiveMaxHeight_true {
	Dictionary d = [AdmobTestFixtures makeInlineAdaptiveAdRequestDictWithUnit:@"u"
	                                                             adaptiveWidth:320
	                                                                 maxHeight:100];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasAdaptiveMaxHeight]);
}

- (void)testAdaptiveMaxHeight_returnsValue {
	Dictionary d = [AdmobTestFixtures makeInlineAdaptiveAdRequestDictWithUnit:@"u"
	                                                             adaptiveWidth:320
	                                                                 maxHeight:100];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualWithAccuracy([req adaptiveMaxHeight], 100.0, 0.01);
}

- (void)testAdaptiveMaxHeight_zeroWhenNegative {
	// Negative adaptive max height should not be stored as a valid value
	Dictionary d;
	d["ad_unit_id"] = String("u");
	d["ad_size"] = String("INLINE_ADAPTIVE");
	d["adaptive_max_height"] = -50.0;
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqualWithAccuracy([req adaptiveMaxHeight], 0.0, 0.01);
}

// ---------------------------------------------------------------------------
// adPosition / getAdPosition
// ---------------------------------------------------------------------------

- (void)testGetAdPosition_allPositions {
	AdPositionCase cases[] = {
		{"TOP", AdPositionTop},
		{"BOTTOM", AdPositionBottom},
		{"LEFT", AdPositionLeft},
		{"TOP_LEFT", AdPositionTopLeft},
		{"TOP_RIGHT", AdPositionTopRight},
		{"BOTTOM_LEFT", AdPositionBottomLeft},
		{"BOTTOM_RIGHT", AdPositionBottomRight},
		{"CENTER", AdPositionCenter},
		{"CUSTOM", AdPositionCustom},
	};

	for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i) {
		Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"
		                                                         adSize:@"BANNER"
		                                                     adPosition:[NSString stringWithUTF8String:cases[i].name]];
		LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
		XCTAssertEqual([req getAdPosition], cases[i].expected,
				@"Position %s should map to %d", cases[i].name, (int)cases[i].expected);
	}
}

- (void)testGetAdPosition_invalidDefaultsToTop {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"
	                                                         adSize:@"BANNER"
	                                                     adPosition:@"INVALID_POSITION"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqual([req getAdPosition], AdPositionTop);
}

// ---------------------------------------------------------------------------
// collapsiblePosition
// ---------------------------------------------------------------------------

- (void)testHasCollapsiblePosition_true {
	Dictionary d = [AdmobTestFixtures makeCollapsibleAdRequestDictWithUnit:@"u" collapsiblePosition:@"BOTTOM"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasCollapsiblePosition]);
	XCTAssertEqualObjects([req collapsiblePosition], @"BOTTOM");
}

- (void)testHasCollapsiblePosition_false {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req hasCollapsiblePosition]);
}

// ---------------------------------------------------------------------------
// anchorToSafeArea
// ---------------------------------------------------------------------------

- (void)testAnchorToSafeArea_true {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	d["anchor_to_safe_area"] = true;
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req anchorToSafeArea]);
}

- (void)testAnchorToSafeArea_defaultFalse {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req anchorToSafeArea]);
}

// ---------------------------------------------------------------------------
// keywords
// ---------------------------------------------------------------------------

- (void)testKeywords_empty {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqual([req keywords].count, 0UL);
}

- (void)testKeywords_multipleElements {
	NSArray *kw = @[@"games", @"rpg", @"mobile"];
	Dictionary d = [AdmobTestFixtures makeAdRequestDictWithUnit:@"u" keywords:kw];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	NSArray *result = [req keywords];
	XCTAssertEqual(result.count, 3UL);
	XCTAssertTrue([result containsObject:@"rpg"]);
}

// ---------------------------------------------------------------------------
// userId / customData
// ---------------------------------------------------------------------------

- (void)testHasUserId_true {
	Dictionary d = [AdmobTestFixtures makeRewardedAdRequestDictWithUnit:@"u" userId:@"u1" customData:@""];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasUserId]);
	XCTAssertEqualObjects([req userId], @"u1");
}

- (void)testHasUserId_false {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req hasUserId]);
}

- (void)testHasCustomData_true {
	Dictionary d = [AdmobTestFixtures makeRewardedAdRequestDictWithUnit:@"u" userId:@"" customData:@"bonus"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasCustomData]);
	XCTAssertEqualObjects([req customData], @"bonus");
}

// ---------------------------------------------------------------------------
// getGADAdSize — standard sizes
// ---------------------------------------------------------------------------

- (void)testGetGADAdSize_banner {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"BANNER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADAdSize result = [req getGADAdSize];
	XCTAssertTrue(GADAdSizeEqualToSize(result, GADAdSizeBanner));
}

- (void)testGetGADAdSize_largeBanner {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"LARGE_BANNER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeLargeBanner));
}

- (void)testGetGADAdSize_mediumRectangle {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"MEDIUM_RECTANGLE" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeMediumRectangle));
}

- (void)testGetGADAdSize_fullBanner {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"FULL_BANNER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeFullBanner));
}

- (void)testGetGADAdSize_leaderboard {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"LEADERBOARD" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeLeaderboard));
}

- (void)testGetGADAdSize_skyscraper {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"SKYSCRAPER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeSkyscraper));
}

- (void)testGetGADAdSize_fluid {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"FLUID" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeFluid));
}

- (void)testGetGADAdSize_adaptiveUsesScreenWidth {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"ADAPTIVE" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADAdSize result = [req getGADAdSize];
	// Must be a valid (non-zero) adaptive size
	XCTAssertGreaterThan(result.size.width, 0.0);
}

- (void)testGetGADAdSize_inlineAdaptive_withMaxHeight {
	Dictionary d = [AdmobTestFixtures makeInlineAdaptiveAdRequestDictWithUnit:@"u"
	                                                             adaptiveWidth:320
	                                                                 maxHeight:90];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADAdSize result = [req getGADAdSize];
	XCTAssertGreaterThan(result.size.width, 0.0);
}

- (void)testGetGADAdSize_inlineAdaptive_withoutMaxHeight {
	Dictionary d = [AdmobTestFixtures makeInlineAdaptiveAdRequestDictWithUnit:@"u"
	                                                             adaptiveWidth:320
	                                                                 maxHeight:0];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADAdSize result = [req getGADAdSize];
	XCTAssertGreaterThan(result.size.width, 0.0);
}

- (void)testGetGADAdSize_unknownDefaultsToBanner {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"UNKNOWN_SIZE" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	// Unknown size maps to default (BANNER)
	XCTAssertTrue(GADAdSizeEqualToSize([req getGADAdSize], GADAdSizeBanner));
}

// ---------------------------------------------------------------------------
// createGADRequest
// ---------------------------------------------------------------------------

- (void)testCreateGADRequest_returnsNonNil {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADRequest *gadReq = [req createGADRequest];
	XCTAssertNotNil(gadReq);
}

- (void)testCreateGADRequest_setsRequestAgent {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	d["request_agent"] = String("test-agent");
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADRequest *gadReq = [req createGADRequest];
	XCTAssertEqualObjects(gadReq.requestAgent, @"test-agent");
}

- (void)testCreateGADRequest_setsKeywords {
	NSArray *kw = @[@"sport", @"action"];
	Dictionary d = [AdmobTestFixtures makeAdRequestDictWithUnit:@"u" keywords:kw];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADRequest *gadReq = [req createGADRequest];
	XCTAssertTrue([gadReq.keywords containsObject:@"sport"]);
}

// ---------------------------------------------------------------------------
// hasServerSideVerificationOptions / createGADServerSideVerificationOptions
// ---------------------------------------------------------------------------

- (void)testHasSSV_trueWhenUserIdPresent {
	Dictionary d = [AdmobTestFixtures makeRewardedAdRequestDictWithUnit:@"u" userId:@"u1" customData:@""];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasServerSideVerificationOptions]);
}

- (void)testHasSSV_trueWhenCustomDataPresent {
	Dictionary d = [AdmobTestFixtures makeRewardedAdRequestDictWithUnit:@"u" userId:@"" customData:@"cd1"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertTrue([req hasServerSideVerificationOptions]);
}

- (void)testHasSSV_falseWhenNeitherSet {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req hasServerSideVerificationOptions]);
}

- (void)testCreateGADServerSideVerificationOptions_setsFields {
	Dictionary d = [AdmobTestFixtures makeRewardedAdRequestDictWithUnit:@"u" userId:@"u1" customData:@"bonus"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADServerSideVerificationOptions *opts = [req createGADServerSideVerificationOptions];
	XCTAssertEqualObjects(opts.userIdentifier, @"u1");
	XCTAssertEqualObjects(opts.customRewardString, @"bonus");
}

// ---------------------------------------------------------------------------
// getRawData round-trip
// ---------------------------------------------------------------------------

- (void)testGetRawData_roundTrip {
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"ca-app-pub-round/trip"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	Dictionary back = [req getRawData];
	String unitId = back[String("ad_unit_id")];
	XCTAssertTrue(strcmp(unitId.utf8().get_data(), "ca-app-pub-round/trip") == 0);
}

@end
