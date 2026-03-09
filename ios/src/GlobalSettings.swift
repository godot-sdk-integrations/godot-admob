//
// © 2026-present https://github.com/cengiz-pz
//

import Foundation
import GoogleMobileAds
import OSLog

@objc public class GlobalSettings: NSObject {

	private static let logger = Logger(
		subsystem: "org.godotengine.plugin.admob",
		category: "GlobalSettings"
	)

	private static let prefsName = "godot_admob_settings"
	private static let prefKeyAdVolume = "ad_volume"
	private static let prefKeyAdsMuted = "ads_muted"
	private static let prefKeyApplyAtStartup = "apply_at_startup"

	@objc override public init() {
		super.init()
	}

	@objc public static func loadSettings() -> AdSettings {
		let userDefaults = UserDefaults.standard

		let volume = userDefaults.object(forKey: prefKeyAdVolume) as? Float ?? AdSettings.defaultAdVolume
		let muted = userDefaults.object(forKey: prefKeyAdsMuted) as? Bool ?? AdSettings.defaultAdsMuted
		let applyAtStartup = userDefaults.object(forKey: prefKeyApplyAtStartup) as? Bool
			?? AdSettings.defaultApplyAtStartup

		return AdSettings(
			adVolume: NSNumber(value: volume),
			areAdsMuted: NSNumber(value: muted),
			applyAtStartup: NSNumber(value: applyAtStartup)
		)
	}

	@objc public static func saveSettings(_ settings: AdSettings) {
		let userDefaults = UserDefaults.standard

		if let volume = settings.adVolume {
			userDefaults.set(volume, forKey: GlobalSettings.prefKeyAdVolume)
		}

		if let muted = settings.areAdsMuted {
			userDefaults.set(muted, forKey: GlobalSettings.prefKeyAdsMuted)
		}

		if let applyAtStartup = settings.applyAtStartup {
			userDefaults.set(applyAtStartup, forKey: GlobalSettings.prefKeyApplyAtStartup)
		}

		userDefaults.synchronize()
	}

	@objc public static func applyToGADMobileAds(_ settings: AdSettings) {
		if let muted = settings.areAdsMuted?.boolValue {
			MobileAds.shared.isApplicationMuted = muted
		}

		if let volume = settings.adVolume?.floatValue {
			let clampedVolume = max(0.0, min(1.0, volume))
			MobileAds.shared.applicationVolume = clampedVolume

			// FIX: Extracted muted string to a local variable to bring line under 140 chars (line_length)
			let mutedString = MobileAds.shared.isApplicationMuted ? "YES" : "NO"
			Self.logger.debug(
				"AdMob Settings: Volume set to \(clampedVolume, format: .fixed(precision: 2)), Muted: \(mutedString)"
			)
		}
	}
}
