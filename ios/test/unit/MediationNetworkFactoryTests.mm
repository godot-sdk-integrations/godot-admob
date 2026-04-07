//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>

#import "mediation_network_factory.h"
#import "mediation_network.h"

// Private adapter-class constants (declared here so tests don't rely on
// build-order of the concrete subclass headers)
static NSString *const kGoogleAdapterClass = @"GADMobileAds";
static NSString *const kGoogleInitClass = @"GADMobileAds"; // set per your impl
static NSString *const kApplovinAdapterClass = @"ALMediationAdapter";
static NSString *const kMetaAdapterClass = @"GADFBAdapter";
static NSString *const kUnityAdapterClass = @"GADUnityAdapter";
static NSString *const kIronsourceAdapterClass = @"GADMediationIronSource";
static NSString *const kMintegralAdapterClass = @"GADMMintegralBannerAdAdapter";

// ============================================================================
// MediationNetworkFactoryTests
// ============================================================================

@interface MediationNetworkFactoryTests : XCTestCase
@end

@implementation MediationNetworkFactoryTests

// ---------------------------------------------------------------------------
// createNetwork: — every supported tag
// ---------------------------------------------------------------------------

- (void)assertCreateNetworkTag:(NSString *)tag description:(NSString *)description {
	MediationNetwork *network = [MediationNetworkFactory createNetwork:tag];
	XCTAssertNotNil(network, @"createNetwork: should return non-nil for tag '%@' (%@)", tag, description);
	XCTAssertEqualObjects(network.tag, tag, @"Tag should be preserved for '%@'", tag);
}

- (void)testCreateNetwork_google {
	[self assertCreateNetworkTag:@"google" description:@"Google mediation"];
}

- (void)testCreateNetwork_applovin {
	[self assertCreateNetworkTag:@"applovin" description:@"AppLovin mediation"];
}

- (void)testCreateNetwork_chartboost {
	[self assertCreateNetworkTag:@"chartboost" description:@"Chartboost mediation"];
}

- (void)testCreateNetwork_dtexchange {
	[self assertCreateNetworkTag:@"dtexchange" description:@"DT Exchange mediation"];
}

- (void)testCreateNetwork_imobile {
	[self assertCreateNetworkTag:@"imobile" description:@"i-mobile mediation"];
}

- (void)testCreateNetwork_inmobi {
	[self assertCreateNetworkTag:@"inmobi" description:@"InMobi mediation"];
}

- (void)testCreateNetwork_ironsource {
	[self assertCreateNetworkTag:@"ironsource" description:@"IronSource mediation"];
}

- (void)testCreateNetwork_liftoff {
	[self assertCreateNetworkTag:@"liftoff" description:@"Liftoff mediation"];
}

- (void)testCreateNetwork_line {
	[self assertCreateNetworkTag:@"line" description:@"LINE mediation"];
}

- (void)testCreateNetwork_maio {
	[self assertCreateNetworkTag:@"maio" description:@"Maio mediation"];
}

- (void)testCreateNetwork_meta {
	[self assertCreateNetworkTag:@"meta" description:@"Meta (Facebook) mediation"];
}

- (void)testCreateNetwork_mintegral {
	[self assertCreateNetworkTag:@"mintegral" description:@"Mintegral mediation"];
}

- (void)testCreateNetwork_moloco {
	[self assertCreateNetworkTag:@"moloco" description:@"Moloco mediation"];
}

- (void)testCreateNetwork_mytarget {
	[self assertCreateNetworkTag:@"mytarget" description:@"MyTarget mediation"];
}

- (void)testCreateNetwork_pangle {
	[self assertCreateNetworkTag:@"pangle" description:@"Pangle mediation"];
}

- (void)testCreateNetwork_unity {
	[self assertCreateNetworkTag:@"unity" description:@"Unity Ads mediation"];
}

// ---------------------------------------------------------------------------
// createNetwork: — error / edge cases
// ---------------------------------------------------------------------------

- (void)testCreateNetwork_nil {
	MediationNetwork *network = [MediationNetworkFactory createNetwork:nil];
	XCTAssertNil(network, @"nil tag should return nil");
}

- (void)testCreateNetwork_emptyString {
	MediationNetwork *network = [MediationNetworkFactory createNetwork:@""];
	XCTAssertNil(network, @"Empty tag should return nil");
}

- (void)testCreateNetwork_unknownTag {
	MediationNetwork *network = [MediationNetworkFactory createNetwork:@"no_such_network_xyz"];
	XCTAssertNil(network, @"Unknown tag should return nil");
}

- (void)testCreateNetwork_uppercaseTagNormalised {
	// Factory performs lowercaseString before lookup
	MediationNetwork *network = [MediationNetworkFactory createNetwork:@"GOOGLE"];
	XCTAssertNotNil(network, @"Uppercase tag should be normalised and matched");
}

- (void)testCreateNetwork_mixedCaseTag {
	MediationNetwork *network = [MediationNetworkFactory createNetwork:@"AppLovin"];
	XCTAssertNotNil(network, @"Mixed-case tag should be normalised and matched");
}

- (void)testCreateNetwork_leadingTrailingWhitespace {
	MediationNetwork *network = [MediationNetworkFactory createNetwork:@"  meta  "];
	XCTAssertNotNil(network, @"Whitespace-padded tag should be trimmed and matched");
}

- (void)testCreateNetwork_returnsDistinctObjects {
	// Two calls with the same tag should return fresh instances, not cached singletons
	MediationNetwork *n1 = [MediationNetworkFactory createNetwork:@"unity"];
	MediationNetwork *n2 = [MediationNetworkFactory createNetwork:@"unity"];
	XCTAssertNotNil(n1);
	XCTAssertNotNil(n2);
	XCTAssertNotEqual(n1, n2, @"Factory should return distinct instances");
}

// ---------------------------------------------------------------------------
// getTagForAdapterClass: — adapter class -> tag lookups
// ---------------------------------------------------------------------------

- (void)testGetTagForAdapterClass_unknownClass {
	NSString *tag = [MediationNetworkFactory getTagForAdapterClass:@"com.unknown.Adapter"];
	XCTAssertNil(tag, @"Unknown adapter class should map to nil");
}

- (void)testGetTagForAdapterClass_nil {
	NSString *tag = [MediationNetworkFactory getTagForAdapterClass:nil];
	XCTAssertNil(tag);
}

- (void)testGetTagForAdapterClass_emptyString {
	NSString *tag = [MediationNetworkFactory getTagForAdapterClass:@""];
	XCTAssertNil(tag);
}

- (void)testGetTagForAdapterClass_whitespaceIsTrimmed {
	// Adapter class with leading/trailing spaces should still resolve if known
	// (uses trimming in the factory). If the class after trimming is unknown,
	// nil is expected — this test asserts trimming is applied.
	NSString *knownClass = @"GADUnityAdapter"; // Use the real Unity class name
	NSString *paddedClass = [NSString stringWithFormat:@"  %@  ", knownClass];
	NSString *tagFromPadded = [MediationNetworkFactory getTagForAdapterClass:paddedClass];
	NSString *tagFromExact = [MediationNetworkFactory getTagForAdapterClass:knownClass];
	XCTAssertEqualObjects(tagFromPadded, tagFromExact,
			@"Trimming must be applied before lookup for '%@'", paddedClass);
}

@end
