//
// © 2026-present https://github.com/cengiz-pz
//

import XCTest
import GoogleMobileAds
@testable import admob_plugin

// ============================================================================
// GlobalSettingsTests
//
// All reads/writes use a private UserDefaults suite so production data is
// never touched and tests remain fully isolated from one another.
// ============================================================================

final class GlobalSettingsTests: XCTestCase {

	// Test-suite name that avoids any collision with the production suite.
	private let testSuiteName = "org.godotengine.plugin.admob.test.\(UUID().uuidString)"

    // Start the SDK exactly once for the whole test class.
    // class setUp is synchronous; a semaphore lets us await the async
    // completion handler without changing the method signature.
    override class func setUp() {
        super.setUp()
        let semaphore = DispatchSemaphore(value: 0)
        MobileAds.shared.start { _ in semaphore.signal() }
        semaphore.wait()
    }

	override func setUp() {
		super.setUp()

		// Reset GADMobileAds shared state so tests that mutate it cannot
		// interfere with one another regardless of execution order.
		MobileAds.shared.isApplicationMuted = false
		MobileAds.shared.applicationVolume = 1.0

		let ud = UserDefaults(suiteName: testSuiteName)!
		ud.removePersistentDomain(forName: testSuiteName)
		GlobalSettings.userDefaults = ud
	}

	override func tearDown() {
		UserDefaults(suiteName: testSuiteName)?.removePersistentDomain(forName: testSuiteName)
		super.tearDown()
	}

	// -----------------------------------------------------------------------
	// Helpers
	// -----------------------------------------------------------------------

	/// Writes the three settings keys directly into the shared UserDefaults
	/// so that GlobalSettings.loadSettings() can read them back.
	private func writeSettings(volume: Float, muted: Bool, applyAtStartup: Bool) {
		let ud = UserDefaults(suiteName: testSuiteName)!
		ud.set(volume, forKey: "ad_volume")
		ud.set(muted, forKey: "ads_muted")
		ud.set(applyAtStartup, forKey: "apply_at_startup")
		ud.synchronize()
	}

	private func clearSettings() {
		let ud = UserDefaults(suiteName: testSuiteName)!
		ud.removeObject(forKey: "ad_volume")
		ud.removeObject(forKey: "ads_muted")
		ud.removeObject(forKey: "apply_at_startup")
		ud.synchronize()
	}

	// -----------------------------------------------------------------------
	// GlobalSettings.loadSettings — default values
	// -----------------------------------------------------------------------

	func testLoadSettings_defaultVolume_whenNoValueStored() {
		clearSettings()
		let settings = GlobalSettings.loadSettings()
		XCTAssertEqual(settings.adVolume?.floatValue ?? -1,
					AdSettings.defaultAdVolume,
					accuracy: 1e-4,
					"Default volume should match AdSettings.defaultAdVolume")
	}

	func testLoadSettings_defaultMuted_whenNoValueStored() {
		clearSettings()
		let settings = GlobalSettings.loadSettings()
		XCTAssertEqual(settings.areAdsMuted?.boolValue ?? !AdSettings.defaultAdsMuted,
					AdSettings.defaultAdsMuted,
					"Default muted should match AdSettings.defaultAdsMuted")
	}

	func testLoadSettings_defaultApplyAtStartup_whenNoValueStored() {
		clearSettings()
		let settings = GlobalSettings.loadSettings()
		XCTAssertEqual(settings.applyAtStartup?.boolValue ?? !AdSettings.defaultApplyAtStartup,
					AdSettings.defaultApplyAtStartup,
					"Default applyAtStartup should match AdSettings.defaultApplyAtStartup")
	}

	// -----------------------------------------------------------------------
	// GlobalSettings.saveSettings + loadSettings — round-trips
	// -----------------------------------------------------------------------

	func testSaveAndLoadSettings_volumeRoundTrip() {
		let input = AdSettings(adVolume: 0.42, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.saveSettings(input)
		let loaded = GlobalSettings.loadSettings()
		XCTAssertEqual(loaded.adVolume?.floatValue ?? -1, 0.42, accuracy: 1e-3)
	}

	func testSaveAndLoadSettings_mutedRoundTrip() {
		let input = AdSettings(adVolume: 1.0, areAdsMuted: true, applyAtStartup: false)
		GlobalSettings.saveSettings(input)
		let loaded = GlobalSettings.loadSettings()
		XCTAssertTrue(loaded.areAdsMuted?.boolValue ?? false)
	}

	func testSaveAndLoadSettings_notMutedRoundTrip() {
		let input = AdSettings(adVolume: 1.0, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.saveSettings(input)
		let loaded = GlobalSettings.loadSettings()
		XCTAssertFalse(loaded.areAdsMuted?.boolValue ?? true)
	}

	func testSaveAndLoadSettings_applyAtStartupRoundTrip() {
		let input = AdSettings(adVolume: 0.5, areAdsMuted: false, applyAtStartup: true)
		GlobalSettings.saveSettings(input)
		let loaded = GlobalSettings.loadSettings()
		XCTAssertTrue(loaded.applyAtStartup?.boolValue ?? false)
	}

	func testSaveAndLoadSettings_zeroVolume() {
		let input = AdSettings(adVolume: 0.0, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.saveSettings(input)
		let loaded = GlobalSettings.loadSettings()
		XCTAssertEqual(loaded.adVolume?.floatValue ?? -1, 0.0, accuracy: 1e-4)
	}

	func testSaveAndLoadSettings_fullVolume() {
		let input = AdSettings(adVolume: 1.0, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.saveSettings(input)
		let loaded = GlobalSettings.loadSettings()
		XCTAssertEqual(loaded.adVolume?.floatValue ?? -1, 1.0, accuracy: 1e-4)
	}

	func testSaveSettings_overwritesPreviousValue() {
		let first = AdSettings(adVolume: 0.2, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.saveSettings(first)

		let second = AdSettings(adVolume: 0.9, areAdsMuted: true, applyAtStartup: true)
		GlobalSettings.saveSettings(second)

		let loaded = GlobalSettings.loadSettings()
		XCTAssertEqual(loaded.adVolume?.floatValue ?? -1, 0.9, accuracy: 1e-3)
		XCTAssertTrue(loaded.areAdsMuted?.boolValue ?? false)
	}

	// -----------------------------------------------------------------------
	// GlobalSettings.saveSettings — nil fields are not stored
	// -----------------------------------------------------------------------

	func testSaveSettings_nilVolumeDoesNotOverwriteExistingValue() {
		// Write a known volume first
		writeSettings(volume: 0.7, muted: false, applyAtStartup: false)

		// Save with nil volume — must not clear the previously stored volume
		let nilVolume = AdSettings(adVolume: nil, areAdsMuted: nil, applyAtStartup: nil)
		GlobalSettings.saveSettings(nilVolume)

		let loaded = GlobalSettings.loadSettings()
		XCTAssertEqual(loaded.adVolume?.floatValue ?? -1, 0.7, accuracy: 1e-3,
					"Existing volume must survive a save with nil volume")
	}

	// -----------------------------------------------------------------------
	// GlobalSettings.applyToGADMobileAds — functional checks
	// -----------------------------------------------------------------------

	func testApplyToGADMobileAds_setsMutedTrue() {
		let settings = AdSettings(adVolume: 1.0, areAdsMuted: true, applyAtStartup: false)
		GlobalSettings.applyToGADMobileAds(settings)
		XCTAssertTrue(MobileAds.shared.isApplicationMuted,
					"MobileAds.shared.isApplicationMuted should be true after applying muted=true")
	}

	func testApplyToGADMobileAds_setsMutedFalse() {
		let settings = AdSettings(adVolume: 1.0, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.applyToGADMobileAds(settings)
		XCTAssertFalse(MobileAds.shared.isApplicationMuted)
	}

	func testApplyToGADMobileAds_setsVolumeNormally() {
		let settings = AdSettings(adVolume: 0.5, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.applyToGADMobileAds(settings)
		XCTAssertEqual(MobileAds.shared.applicationVolume, 0.5, accuracy: 1e-3)
	}

	func testApplyToGADMobileAds_clampsVolumeAboveOne() {
		// Volume > 1.0 should be clamped to 1.0
		let settings = AdSettings(adVolume: 2.5, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.applyToGADMobileAds(settings)
		XCTAssertLessThanOrEqual(MobileAds.shared.applicationVolume, 1.0)
	}

	func testApplyToGADMobileAds_clampsVolumeBelowZero() {
		// Volume < 0.0 should be clamped to 0.0
		let settings = AdSettings(adVolume: -0.5, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.applyToGADMobileAds(settings)
		XCTAssertGreaterThanOrEqual(MobileAds.shared.applicationVolume, 0.0)
	}

	func testApplyToGADMobileAds_zeroVolumeIsClampedToZero() {
		let settings = AdSettings(adVolume: 0.0, areAdsMuted: false, applyAtStartup: false)
		GlobalSettings.applyToGADMobileAds(settings)
		XCTAssertEqual(MobileAds.shared.applicationVolume, 0.0, accuracy: 1e-4)
	}

	func testApplyToGADMobileAds_nilVolumeDoesNotCrash() {
		let settings = AdSettings(adVolume: nil, areAdsMuted: nil, applyAtStartup: false)
		XCTAssertNoThrow(GlobalSettings.applyToGADMobileAds(settings))
	}

	func testApplyToGADMobileAds_nilMutedDoesNotCrash() {
		let settings = AdSettings(adVolume: 1.0, areAdsMuted: nil, applyAtStartup: false)
		XCTAssertNoThrow(GlobalSettings.applyToGADMobileAds(settings))
	}

	// -----------------------------------------------------------------------
	// AdSettings default values — accessed via static properties
	// -----------------------------------------------------------------------

	func testAdSettingsDefaultAdVolume_isInValidRange() {
		let vol = AdSettings.defaultAdVolume
		XCTAssertGreaterThanOrEqual(vol, 0.0)
		XCTAssertLessThanOrEqual(vol, 1.0)
	}
}
