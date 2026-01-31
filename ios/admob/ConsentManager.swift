//
// © 2024-present https://github.com/cengiz-pz
//

import Foundation
import UIKit
import OSLog
import UserMessagingPlatform

@objc public class ConsentManager: NSObject {

	private static let logger = Logger(
		subsystem: "org.godotengine.plugin.admob",
		category: "ConsentManager"
	)

	private var umpForm: ConsentForm?

	// Utility: Always run work on the main thread
	private func runOnMain(_ block: @escaping () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			DispatchQueue.main.async(execute: block)
		}
	}

	@objc public func getConsentStatusString() -> String {
		let status = ConsentInformation.shared.consentStatus
		switch status {
		case .unknown:
			return "UNKNOWN"
		case .required:
			return "REQUIRED"
		case .notRequired:
			return "NOT_REQUIRED"
		case .obtained:
			return "OBTAINED"
		@unknown default:
			return "UNKNOWN"
		}
	}

	@objc public func isFormAvailable() -> Bool {
		return ConsentInformation.shared.formStatus == .available
	}

	@objc public func reset() {
		Self.logger.debug("ConsentManager.reset called")
		ConsentInformation.shared.reset()
	}

	@objc public func requestConsentInfoUpdate(
		with parameters: RequestParameters,
		completion: @escaping (NSError?) -> Void
	) {
		ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
			completion(error as NSError?)
		}
	}

	@objc public func loadForm(completion: @escaping (NSError?) -> Void) {
		runOnMain { [weak self] in
			ConsentForm.load { form, error in
				if let error = error {
					completion(error as NSError)
					return
				}
				self?.umpForm = form
				completion(nil)
			}
		}
	}

	@objc public func showForm(
		from viewController: UIViewController,
		completion: @escaping (NSError?) -> Void
	) {
		runOnMain { [weak self] in
			guard let self = self else { return }

			guard let form = self.umpForm else {
				let error = NSError(
					domain: "org.godotengine.plugin.admob",
					code: -1,
					userInfo: [NSLocalizedDescriptionKey: "Consent form not loaded"]
				)
				completion(error)
				return
			}

			let wrapper = ConsentWrapperViewController()
			wrapper.wrappedForm = form
			wrapper.presentationCompletion = completion
			wrapper.modalPresentationStyle = .fullScreen

			viewController.present(wrapper, animated: true, completion: nil)
		}
	}
}

class ConsentWrapperViewController: UIViewController {

	var wrappedForm: ConsentForm?
	var presentationCompletion: ((NSError?) -> Void)?

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}

	override var shouldAutorotate: Bool {
		return true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		guard let form = wrappedForm else { return }

		form.present(from: self) { [weak self] error in
			self?.presentationCompletion?(error as NSError?)
			self?.dismiss(animated: false, completion: nil)
		}

		wrappedForm = nil
	}
}
