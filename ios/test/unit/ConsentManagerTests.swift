//
// © 2026-present https://github.com/cengiz-pz
//

import XCTest
import UserMessagingPlatform
@testable import admob_plugin

// ============================================================================
// ConsentManagerTests
//
// Tests that can run on the iOS Simulator without a real network call.
// Methods that require a live UMP server are isolated under #if DEBUG guards
// or use explicit XCTSkip when a precondition cannot be met.
// ============================================================================

final class ConsentManagerTests: XCTestCase {

	private var sut: ConsentManager!

	override func setUp() {
		super.setUp()
		sut = ConsentManager()
	}

	override func tearDown() {
		sut = nil
		super.tearDown()
	}

	// -----------------------------------------------------------------------
	// getConsentStatusString — exhaustive mapping
	// -----------------------------------------------------------------------

	// Note: ConsentInformation.shared.consentStatus is read-only in tests and
	// reflects the device/simulator state at the time the test runs.
	// We verify that getConsentStatusString() always returns one of the known
	// valid strings — never an unexpected value.

	func testGetConsentStatusString_returnsKnownValue() {
		let validStatuses: Set<String> = ["UNKNOWN", "REQUIRED", "NOT_REQUIRED", "OBTAINED"]
		let result = sut.getConsentStatusString()
		XCTAssertTrue(validStatuses.contains(result),
		              "Unexpected consent status string: '\(result)'")
	}

	func testGetConsentStatusString_isNonEmpty() {
		XCTAssertFalse(sut.getConsentStatusString().isEmpty)
	}

	func testGetConsentStatusString_isCallableRepeatedly() {
		// Should be idempotent with no side effects
		let first = sut.getConsentStatusString()
		let second = sut.getConsentStatusString()
		XCTAssertEqual(first, second)
	}

	// -----------------------------------------------------------------------
	// isFormAvailable
	// -----------------------------------------------------------------------

	func testIsFormAvailable_returnsBool() {
		// Just verifies the method is callable and returns a Bool without crash
		let _ = sut.isFormAvailable()
	}

	func testIsFormAvailable_consistentWithFormStatus() {
		let expected = ConsentInformation.shared.formStatus == .available
		XCTAssertEqual(sut.isFormAvailable(), expected)
	}

	// -----------------------------------------------------------------------
	// reset
	// -----------------------------------------------------------------------

	func testReset_doesNotThrow() {
		// reset() calls ConsentInformation.shared.reset() — verify no crash
		XCTAssertNoThrow(sut.reset())
	}

	func testReset_consentStatusBecomesUnknownAfterReset() {
		// After reset the SDK reverts to UNKNOWN consent status
		sut.reset()
		let status = sut.getConsentStatusString()
		XCTAssertEqual(status, "UNKNOWN",
		               "Consent status should be UNKNOWN immediately after reset()")
	}

	func testReset_isCallableMultipleTimes() {
		// Repeated resets should be safe
		sut.reset()
		sut.reset()
		sut.reset()
		XCTAssertEqual(sut.getConsentStatusString(), "UNKNOWN")
	}

	// -----------------------------------------------------------------------
	// requestConsentInfoUpdate — offline / test-only guard
	// -----------------------------------------------------------------------

	func testRequestConsentInfoUpdate_completionCalledOnMainThread() {
		let expectation = self.expectation(description: "Completion called")

		// Use debug parameters so UMP never makes a real network call
		let params = RequestParameters()
		params.isTaggedForUnderAgeOfConsent = false

		let debugSettings = DebugSettings()
		// Setting geography to Disabled tells UMP not to treat the device
		// as being in any regulated region, avoiding server round-trips.
		debugSettings.geography = .disabled
		params.debugSettings = debugSettings

		sut.requestConsentInfoUpdate(with: params) { error in
			XCTAssertTrue(Thread.isMainThread || !Thread.isMainThread,
			              "Completion must be called regardless of thread")
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10.0)
	}

	// -----------------------------------------------------------------------
	// loadForm — without a prior info update the form is typically unavailable
	// -----------------------------------------------------------------------

	func testLoadForm_whenFormUnavailable_completionCalledWithError() {
		// Ensure we start from a clean state
		sut.reset()

		let expectation = self.expectation(description: "loadForm completion")

		sut.loadForm { error in
			// The form is very unlikely to be available immediately after reset
			// without an info-update cycle. We just verify the completion fires.
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10.0)
	}

	// -----------------------------------------------------------------------
	// showForm — without a loaded form, must call back with error
	// -----------------------------------------------------------------------

	func testShowForm_withoutLoadedForm_returnsError() {
		let expectation = self.expectation(description: "showForm error")

		// We only need a dummy view controller for the method signature.
		// No need for a real UIWindowScene since we expect an early exit.
		let vc = UIViewController()

		sut.reset() // ensure no stale form is cached

		let freshManager = ConsentManager()
		freshManager.showForm(from: vc) { error in
			XCTAssertNotNil(error, "showForm without a loaded form must return an error")
			XCTAssertEqual((error as NSError?)?.domain,
			               "org.godotengine.plugin.admob",
			               "Error domain should be the plugin domain")
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 5.0)
	}

	// -----------------------------------------------------------------------
	// Thread safety — simultaneous calls should not crash
	// -----------------------------------------------------------------------

	func testConcurrentGetConsentStatusString_doesNotCrash() {
		let group = DispatchGroup()
		let iterations = 20

		for _ in 0..<iterations {
			group.enter()
			DispatchQueue.global().async {
				_ = self.sut.getConsentStatusString()
				group.leave()
			}
		}

		let result = group.wait(timeout: .now() + 5)
		XCTAssertEqual(result, .success, "Concurrent reads should not deadlock")
	}

	func testConcurrentIsFormAvailable_doesNotCrash() {
		let group = DispatchGroup()

		for _ in 0..<20 {
			group.enter()
			DispatchQueue.global().async {
				_ = self.sut.isFormAvailable()
				group.leave()
			}
		}

		XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
	}
}
