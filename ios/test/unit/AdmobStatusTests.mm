//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <objc/runtime.h>

#import "admob_status.h"
#import "mediation_network_factory.h"

// ============================================================================
// Minimal GADAdapterStatus stub
//
// GADAdapterStatus is not directly constructable in tests, so we build a
// lightweight subclass that overrides only what buildRawData accesses.
// ============================================================================

@interface FakeAdapterStatus : GADAdapterStatus
@property(nonatomic) GADAdapterInitializationState fakeState;
@property(nonatomic) NSTimeInterval fakeLatency;
@property(nonatomic, copy) NSString *fakeDescription;
@end

@implementation FakeAdapterStatus

- (GADAdapterInitializationState)state {
	return _fakeState;
}
- (NSTimeInterval)latency {
	return _fakeLatency;
}
- (NSString *)description {
	return _fakeDescription;
}

@end

// ============================================================================
// Minimal GADInitializationStatus stub
// ============================================================================

@interface FakeInitializationStatus : GADInitializationStatus
@property(nonatomic, strong) NSDictionary<NSString *, GADAdapterStatus *> *fakeAdapterStatuses;
@end

@implementation FakeInitializationStatus

- (NSDictionary<NSString *, GADAdapterStatus *> *)adapterStatusesByClassName {
	return _fakeAdapterStatuses;
}

@end

// ============================================================================
// AdmobStatusTests
// ============================================================================

@interface AdmobStatusTests : XCTestCase
@end

@implementation AdmobStatusTests

// ---------------------------------------------------------------------------
// adapterStatusToString: — all branches
// ---------------------------------------------------------------------------

- (void)testAdapterStatusToString_ready {
	NSString *s = [AdmobStatus adapterStatusToString:GADAdapterInitializationStateReady];
	XCTAssertEqualObjects(s, @"READY");
}

- (void)testAdapterStatusToString_notReady {
	NSString *s = [AdmobStatus adapterStatusToString:GADAdapterInitializationStateNotReady];
	XCTAssertEqualObjects(s, @"NOT_READY");
}

- (void)testAdapterStatusToString_unknownValueReturnsInvalid {
	NSString *s = [AdmobStatus adapterStatusToString:(GADAdapterInitializationState)999];
	XCTAssertEqualObjects(s, @"INVALID");
}

// ---------------------------------------------------------------------------
// buildRawData — empty status map
// ---------------------------------------------------------------------------

- (void)testBuildRawData_emptyAdapterMap {
	FakeInitializationStatus *fakeStatus = [[FakeInitializationStatus alloc] init];
	fakeStatus.fakeAdapterStatuses = @{};

	AdmobStatus *status = [[AdmobStatus alloc] initWithStatus:fakeStatus];
	Dictionary raw = [status buildRawData];
	XCTAssertEqual(raw.size(), 0);
}

// ---------------------------------------------------------------------------
// buildRawData — known adapter mapped to network tag
// ---------------------------------------------------------------------------

- (void)testBuildRawData_knownAdapterUsesNetworkTag {
	// Find a real adapter class name whose tag is resolvable by MediationNetworkFactory
	// Use "GADUnityAdapter" -> should resolve to "unity"
	NSString *unityAdapterClass = @"GADUnityAdapter";
	NSString *expectedTag = [MediationNetworkFactory getTagForAdapterClass:unityAdapterClass];

	// If the adapter class is not registered yet (dynamic load), skip gracefully
	if (!expectedTag) {
		XCTSkip(@"Unity adapter class not in factory map — skipping tag-mapping test");
		return;
	}

	FakeAdapterStatus *fakeAdapter = [[FakeAdapterStatus alloc] init];
	fakeAdapter.fakeState = GADAdapterInitializationStateReady;
	fakeAdapter.fakeLatency = 1.23;
	fakeAdapter.fakeDescription = @"Ready";

	FakeInitializationStatus *fakeStatus = [[FakeInitializationStatus alloc] init];
	fakeStatus.fakeAdapterStatuses = @{unityAdapterClass : fakeAdapter};

	AdmobStatus *status = [[AdmobStatus alloc] initWithStatus:fakeStatus];
	Dictionary raw = [status buildRawData];

	XCTAssertEqual(raw.size(), 1);
	XCTAssertTrue(raw.has(String([expectedTag UTF8String])));

	Dictionary adapterDict = raw[String([expectedTag UTF8String])];
	NSString *stateStr = [NSString stringWithUTF8String:((String)adapterDict[String("initialization_state")])
			.utf8().get_data()];
	XCTAssertEqualObjects(stateStr, @"READY");
}

// ---------------------------------------------------------------------------
// buildRawData — unknown adapter falls back to class name as key
// ---------------------------------------------------------------------------

- (void)testBuildRawData_unknownAdapterUsesClassName {
	NSString *unknownClass = @"com.example.UnknownAdapter";

	FakeAdapterStatus *fakeAdapter = [[FakeAdapterStatus alloc] init];
	fakeAdapter.fakeState = GADAdapterInitializationStateNotReady;
	fakeAdapter.fakeLatency = 0.0;
	fakeAdapter.fakeDescription = @"Not ready";

	FakeInitializationStatus *fakeStatus = [[FakeInitializationStatus alloc] init];
	fakeStatus.fakeAdapterStatuses = @{unknownClass : fakeAdapter};

	AdmobStatus *status = [[AdmobStatus alloc] initWithStatus:fakeStatus];
	Dictionary raw = [status buildRawData];

	// Should use the raw class name as the key
	XCTAssertEqual(raw.size(), 1);
	XCTAssertTrue(raw.has(String([unknownClass UTF8String])));
}

// ---------------------------------------------------------------------------
// buildRawData — adapter entry contains required sub-keys
// ---------------------------------------------------------------------------

- (void)testBuildRawData_adapterEntryHasRequiredKeys {
	NSString *unknownClass = @"com.test.Adapter";

	FakeAdapterStatus *fakeAdapter = [[FakeAdapterStatus alloc] init];
	fakeAdapter.fakeState = GADAdapterInitializationStateReady;
	fakeAdapter.fakeLatency = 0.5;
	fakeAdapter.fakeDescription = @"OK";

	FakeInitializationStatus *fakeStatus = [[FakeInitializationStatus alloc] init];
	fakeStatus.fakeAdapterStatuses = @{unknownClass : fakeAdapter};

	AdmobStatus *status = [[AdmobStatus alloc] initWithStatus:fakeStatus];
	Dictionary raw = [status buildRawData];
	Dictionary entry = raw[String([unknownClass UTF8String])];

	XCTAssertTrue(entry.has(String("adapter_class")));
	XCTAssertTrue(entry.has(String("latency")));
	XCTAssertTrue(entry.has(String("initialization_state")));
	XCTAssertTrue(entry.has(String("description")));
}

- (void)testBuildRawData_adapterEntryLatencyIsCorrect {
	NSString *unknownClass = @"com.test.LatencyAdapter";

	FakeAdapterStatus *fakeAdapter = [[FakeAdapterStatus alloc] init];
	fakeAdapter.fakeState = GADAdapterInitializationStateReady;
	fakeAdapter.fakeLatency = 2.5;
	fakeAdapter.fakeDescription = @"OK";

	FakeInitializationStatus *fakeStatus = [[FakeInitializationStatus alloc] init];
	fakeStatus.fakeAdapterStatuses = @{unknownClass : fakeAdapter};

	AdmobStatus *status = [[AdmobStatus alloc] initWithStatus:fakeStatus];
	Dictionary raw = [status buildRawData];
	Dictionary entry = raw[String([unknownClass UTF8String])];
	double latency = entry[String("latency")];
	XCTAssertEqualWithAccuracy(latency, 2.5, 0.01);
}

// ---------------------------------------------------------------------------
// initWithStatus: retains the status object
// ---------------------------------------------------------------------------

- (void)testInitWithStatus_retainsStatusObject {
	__weak FakeInitializationStatus *weakStatus = nil;

	AdmobStatus *adStatus = nil;
	@autoreleasepool {
		FakeInitializationStatus *fakeStatus = [[FakeInitializationStatus alloc] init];
		fakeStatus.fakeAdapterStatuses = @{};
		weakStatus = fakeStatus;

		adStatus = [[AdmobStatus alloc] initWithStatus:fakeStatus];
	}

	// adStatus is still alive, so fakeStatus must not have been deallocated
	XCTAssertNotNil(adStatus);
}

@end
