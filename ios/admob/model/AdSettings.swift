//
// © 2026-present https://github.com/cengiz-pz
//

import Foundation

@objc public final class AdSettings: NSObject {
	@objc public static let defaultAdVolume: Float = 1.0
	@objc public static let defaultAdsMuted: Bool = false
	@objc public static let defaultApplyAtStartup: Bool = false

	@objc public let adVolume: NSNumber?
	@objc public let areAdsMuted: NSNumber?
	@objc public let applyAtStartup: NSNumber?

	@objc public init(adVolume: NSNumber?, areAdsMuted: NSNumber?, applyAtStartup: NSNumber?) {
		self.adVolume = adVolume
		self.areAdsMuted = areAdsMuted
		self.applyAtStartup = applyAtStartup
		super.init()
	}
}
