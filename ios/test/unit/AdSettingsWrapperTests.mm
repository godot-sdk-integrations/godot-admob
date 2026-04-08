//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>

#import "admob_plugin-Swift.h"
#import "ad_settings_wrapper.h"
#import "AdmobTestFixtures.h"

// ============================================================================
// AdSettingsWrapperTests
// ============================================================================

@interface AdSettingsWrapperTests : XCTestCase
@end

@implementation AdSettingsWrapperTests

// ---------------------------------------------------------------------------
// -init
// ---------------------------------------------------------------------------

- (void)testDefaultInit_adVolumeIsDefaultValue {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	float volume = [[wrapper getAdVolume] floatValue];
	XCTAssertEqualWithAccuracy(volume, AdSettings.defaultAdVolume, 1e-4f);
}

- (void)testDefaultInit_adsMutedIsDefaultValue {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	XCTAssertEqual([wrapper areAdsMuted], AdSettings.defaultAdsMuted);
}

- (void)testDefaultInit_applyAtStartupIsDefaultValue {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	XCTAssertEqual([wrapper getApplyAtStartup], AdSettings.defaultApplyAtStartup);
}

// ---------------------------------------------------------------------------
// -initWithData:
// ---------------------------------------------------------------------------

- (void)testInitWithData_setsAllFields {
	Dictionary d = [AdmobTestFixtures makeAdSettingsDictWithVolume:0.5f muted:YES applyAtStartup:YES];
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] initWithData:d];
	XCTAssertEqualWithAccuracy([[wrapper getAdVolume] floatValue], 0.5f, 1e-4f);
	XCTAssertTrue([wrapper areAdsMuted]);
}

- (void)testInitWithData_applyAtStartupFalse {
	Dictionary d = [AdmobTestFixtures makeAdSettingsDictWithVolume:1.0f muted:NO applyAtStartup:NO];
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] initWithData:d];
	XCTAssertFalse([wrapper getApplyAtStartup]);
}

// ---------------------------------------------------------------------------
// setAdVolume: / getAdVolume
// ---------------------------------------------------------------------------

- (void)testSetGetAdVolume_zeroVolume {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdVolume:@(0.0f)];
	XCTAssertEqualWithAccuracy([[wrapper getAdVolume] floatValue], 0.0f, 1e-4f);
}

- (void)testSetGetAdVolume_fullVolume {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdVolume:@(1.0f)];
	XCTAssertEqualWithAccuracy([[wrapper getAdVolume] floatValue], 1.0f, 1e-4f);
}

- (void)testSetGetAdVolume_midVolume {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdVolume:@(0.75f)];
	XCTAssertEqualWithAccuracy([[wrapper getAdVolume] floatValue], 0.75f, 1e-3f);
}

// ---------------------------------------------------------------------------
// setAdsMuted: / areAdsMuted
// ---------------------------------------------------------------------------

- (void)testSetAdsMuted_true {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdsMuted:YES];
	XCTAssertTrue([wrapper areAdsMuted]);
}

- (void)testSetAdsMuted_false {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdsMuted:YES]; // set to true first
	[wrapper setAdsMuted:NO];
	XCTAssertFalse([wrapper areAdsMuted]);
}

// ---------------------------------------------------------------------------
// setApplyAtStartup: / getApplyAtStartup
// ---------------------------------------------------------------------------

- (void)testSetApplyAtStartup_true {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setApplyAtStartup:YES];
	XCTAssertTrue([wrapper getApplyAtStartup]);
}

- (void)testSetApplyAtStartup_false {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setApplyAtStartup:YES];
	[wrapper setApplyAtStartup:NO];
	XCTAssertFalse([wrapper getApplyAtStartup]);
}

// ---------------------------------------------------------------------------
// createAdSettings
// ---------------------------------------------------------------------------

- (void)testCreateAdSettings_allDefaultsWhenEmptyInit {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	// An empty wrapper has no keys set; createAdSettings should return nil fields
	AdSettings *settings = [wrapper createAdSettings];
	XCTAssertNotNil(settings);
	XCTAssertNil(settings.adVolume, @"Volume should be nil when not set");
	XCTAssertNil(settings.areAdsMuted, @"Muted should be nil when not set");
	XCTAssertNil(settings.applyAtStartup, @"Apply should be nil when not set");
}

- (void)testCreateAdSettings_reflectsSetVolume {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdVolume:@(0.3f)];
	AdSettings *settings = [wrapper createAdSettings];
	XCTAssertNotNil(settings.adVolume);
	XCTAssertEqualWithAccuracy(settings.adVolume.floatValue, 0.3f, 1e-3f);
}

- (void)testCreateAdSettings_reflectsSetMuted {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdsMuted:YES];
	AdSettings *settings = [wrapper createAdSettings];
	XCTAssertNotNil(settings.areAdsMuted);
	XCTAssertTrue(settings.areAdsMuted.boolValue);
}

- (void)testCreateAdSettings_reflectsSetApplyAtStartup {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setApplyAtStartup:YES];
	AdSettings *settings = [wrapper createAdSettings];
	XCTAssertNotNil(settings.applyAtStartup);
	XCTAssertTrue(settings.applyAtStartup.boolValue);
}

// ---------------------------------------------------------------------------
// -initWithAdSettings: - round-trip through AdSettings
// ---------------------------------------------------------------------------

- (void)testInitWithAdSettings_roundTrip_volume {
	AdSettings *input = [[AdSettings alloc] initWithAdVolume:@(0.6f)
	                                             areAdsMuted:@(NO)
	                                          applyAtStartup:@(YES)];
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] initWithAdSettings:input];
	XCTAssertEqualWithAccuracy([[wrapper getAdVolume] floatValue], 0.6f, 1e-3f);
}

- (void)testInitWithAdSettings_roundTrip_muted {
	AdSettings *input = [[AdSettings alloc] initWithAdVolume:@(1.0f)
	                                             areAdsMuted:@(YES)
	                                          applyAtStartup:@(NO)];
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] initWithAdSettings:input];
	XCTAssertTrue([wrapper areAdsMuted]);
}

- (void)testInitWithAdSettings_roundTrip_applyAtStartup {
	AdSettings *input = [[AdSettings alloc] initWithAdVolume:@(0.5f)
	                                             areAdsMuted:@(NO)
	                                          applyAtStartup:@(YES)];
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] initWithAdSettings:input];
	XCTAssertTrue([wrapper getApplyAtStartup]);
}

- (void)testInitWithAdSettings_nilVolumeIsNotStored {
	AdSettings *input = [[AdSettings alloc] initWithAdVolume:nil
	                                             areAdsMuted:nil
	                                          applyAtStartup:nil];
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] initWithAdSettings:input];
	// With nil volume the wrapper should not have the key set
	AdSettings *back = [wrapper createAdSettings];
	XCTAssertNil(back.adVolume);
}

// ---------------------------------------------------------------------------
// getRawData
// ---------------------------------------------------------------------------

- (void)testGetRawData_emptyAfterDefaultInit {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	Dictionary raw = [wrapper getRawData];
	XCTAssertEqual(raw.size(), 0);
}

- (void)testGetRawData_containsSetKeys {
	AdSettingsWrapper *wrapper = [[AdSettingsWrapper alloc] init];
	[wrapper setAdVolume:@(0.5f)];
	[wrapper setAdsMuted:YES];
	Dictionary raw = [wrapper getRawData];
	XCTAssertTrue(raw.has(String("ad_volume")));
	XCTAssertTrue(raw.has(String("ads_muted")));
	XCTAssertFalse(raw.has(String("apply_at_startup")));
}

@end
