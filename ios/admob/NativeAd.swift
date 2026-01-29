//
// © 2024-present https://github.com/cengiz-pz
//

import Foundation
import UIKit
import GoogleMobileAds

@objc protocol NativeAdDelegate: AnyObject {
	func nativeAdDidLoad(_ adInfo: AdmobAdInfo, responseInfo: GADResponseInfo)
	func nativeAdDidFailToLoad(_ adInfo: AdmobAdInfo, error: Error)
	func nativeAdDidRecordImpression(_ adInfo: AdmobAdInfo)
	func nativeAdDidRecordClick(_ adInfo: AdmobAdInfo)
	func nativeAdWillPresentScreen(_ adInfo: AdmobAdInfo)
	func nativeAdDidDismissScreen(_ adInfo: AdmobAdInfo)
	func nativeAdDidSizeMeasured(_ adInfo: AdmobAdInfo)
}

@objc public class NativeAd: NSObject {
	private let adInfo: AdmobAdInfo
	private let adRequest: GADRequest
	private weak var delegate: NativeAdDelegate?
	private var parentView: UIView?

	private var nativeAd: GADNativeAd?
	private var adView: GADNativeAdView?
	private var containerView: UIView?

	private var lastX: CGFloat = -1
	private var lastY: CGFloat = -1
	private var lastWidth: CGFloat = -1
	private var lastHeight: CGFloat = -1
	private var lastVisible: Bool = true

	@objc public init(adInfo: AdmobAdInfo, adRequest: GADRequest, parentView: UIView, delegate: NativeAdDelegate) {
		self.adInfo = adInfo
		self.adRequest = adRequest
		self.parentView = parentView
		self.delegate = delegate

		super.init()
	}

	@objc public func load() {
		guard let parentView = parentView else {
			NSLog("NativeAd: Error - parent view is nil")
			return
		}

		// Get ad unit ID from LoadAdRequest
		let loadRequest = adInfo.loadAdRequest
		let adUnitId = loadRequest?.adUnitId() ?? ""

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			let adLoader = GADAdLoader(
				adUnitID: adUnitId,
				rootViewController: self.getRootViewController(),
				adTypes: [.native],
				options: [GADNativeAdViewAdOptions()]
			)

			adLoader.delegate = self
			adLoader.load(self.adRequest)
		}
	}

	@objc public func show() {
		guard let containerView = containerView else {
			NSLog("NativeAd: Error - native ad not loaded yet")
			return
		}

		DispatchQueue.main.async {
			containerView.isHidden = false
		}
	}

	@objc public func hide() {
		guard let containerView = containerView else { return }

		DispatchQueue.main.async {
			containerView.isHidden = true
		}
	}

	@objc public func remove() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.containerView?.removeFromSuperview()
			self.containerView = nil
			self.adView = nil
			self.nativeAd = nil
		}
	}

	@objc public func updateLayout(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, visible: Bool) {
		guard let containerView = containerView, let parentView = parentView else { return }

		// Check if layout parameters have changed
		if x == lastX && y == lastY && width == lastWidth && height == lastHeight && visible == lastVisible {
			return
		}

		lastX = x
		lastY = y
		lastWidth = width
		lastHeight = height
		lastVisible = visible

		DispatchQueue.main.async {
			var frame = containerView.frame
			frame.origin.x = x
			frame.origin.y = y

			if width > 0 {
				frame.size.width = width
			}
			if height > 0 {
				frame.size.height = height
			}

			containerView.frame = frame
			containerView.isHidden = !visible
		}
	}

	private func createNativeAdView() {
		guard let parentView = parentView else { return }

		// Load the XIB file
		let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)
		guard let loadedAdView = nibObjects?.first as? GADNativeAdView else {
			NSLog("NativeAd: Error - failed to load NativeAdView XIB")
			return
		}

		adView = loadedAdView

		// Bind native ad to view
		if let nativeAd = nativeAd {
			bindNativeAd(adView: loadedAdView, nativeAd: nativeAd)
		}

		// Create container view
		let container = UIView()
		container.backgroundColor = .clear
		container.translatesAutoresizingMaskIntoConstraints = false
		containerView = container

		// Add ad view to container
		loadedAdView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(loadedAdView)

		// Set constraints for ad view within container
		NSLayoutConstraint.activate([
			loadedAdView.topAnchor.constraint(equalTo: container.topAnchor),
			loadedAdView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			loadedAdView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			loadedAdView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])

		// Add container to parent view
		container.isHidden = true
		parentView.addSubview(container)

		// Debug overlay (remove in production)
		#if DEBUG
		container.layer.borderColor = UIColor.red.withAlphaComponent(0.3).cgColor
		container.layer.borderWidth = 2
		loadedAdView.layer.borderColor = UIColor.green.withAlphaComponent(0.3).cgColor
		loadedAdView.layer.borderWidth = 2
		#endif

		// Measure size after layout
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			loadedAdView.setNeedsLayout()
			loadedAdView.layoutIfNeeded()

			let scale = UIScreen.main.scale
			let widthDp = Int(round(loadedAdView.bounds.width / scale * 160))
			let heightDp = Int(round(loadedAdView.bounds.height / scale * 160))

			self.adInfo.measuredWidth = widthDp
			self.adInfo.measuredHeight = heightDp

			self.delegate?.nativeAdDidSizeMeasured(self.adInfo)
		}
	}

	private func bindNativeAd(adView: GADNativeAdView, nativeAd: GADNativeAd) {
		// Set the native ad
		adView.nativeAd = nativeAd

		// Bind headline
		if let headlineView = adView.headlineView as? UILabel {
			headlineView.text = nativeAd.headline
		}

		// Bind media content
		if let mediaView = adView.mediaView {
			mediaView.mediaContent = nativeAd.mediaContent
		}

		// Bind call to action
		if let callToActionView = adView.callToActionView as? UIButton {
			callToActionView.setTitle(nativeAd.callToAction, for: .normal)
			callToActionView.isUserInteractionEnabled = false
		}

		// Bind icon
		if let iconView = adView.iconView as? UIImageView {
			if let icon = nativeAd.icon {
				iconView.image = icon.image
			}
		}

		// Optional: Bind body text if present
		if let bodyView = adView.bodyView as? UILabel {
			bodyView.text = nativeAd.body
		}

		// Optional: Bind advertiser if present
		if let advertiserView = adView.advertiserView as? UILabel {
			advertiserView.text = nativeAd.advertiser
		}

		// Optional: Bind store if present
		if let storeView = adView.storeView as? UILabel {
			storeView.text = nativeAd.store
		}

		// Optional: Bind price if present
		if let priceView = adView.priceView as? UILabel {
			priceView.text = nativeAd.price
		}

		// Optional: Bind star rating if present
		if let starRatingView = adView.starRatingView as? UIImageView {
			if let starRating = nativeAd.starRating {
				// You can implement star rating visualization here
				starRatingView.isHidden = false
			} else {
				starRatingView.isHidden = true
			}
		}
	}

	private func getRootViewController() -> UIViewController? {
		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
		let rootViewController = windowScene.windows.first?.rootViewController {
			return rootViewController
		}
		return nil
	}
}

// MARK: - GADNativeAdLoaderDelegate
extension NativeAd: GADNativeAdLoaderDelegate {
	public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
		NSLog("NativeAd: Ad loaded successfully")

		self.nativeAd = nativeAd
		nativeAd.delegate = self

		createNativeAdView()

		delegate?.nativeAdDidLoad(adInfo, responseInfo: nativeAd.responseInfo)
	}

	public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
		NSLog("NativeAd: Failed to load ad with error: \(error.localizedDescription)")
		delegate?.nativeAdDidFailToLoad(adInfo, error: error)
	}
}

// MARK: - GADNativeAdDelegate
extension NativeAd: GADNativeAdDelegate {
	public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
		NSLog("NativeAd: Impression recorded")
		delegate?.nativeAdDidRecordImpression(adInfo)
	}

	public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
		NSLog("NativeAd: Click recorded")
		delegate?.nativeAdDidRecordClick(adInfo)
	}

	public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
		NSLog("NativeAd: Will present screen")
		delegate?.nativeAdWillPresentScreen(adInfo)
	}

	public func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
		NSLog("NativeAd: Did dismiss screen")
		delegate?.nativeAdDidDismissScreen(adInfo)
	}

	public func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
		NSLog("NativeAd: Will leave application")
	}
}

// MARK: - GADAdLoaderDelegate
extension NativeAd: GADAdLoaderDelegate {
	public func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
		NSLog("NativeAd: Ad loader finished loading")
	}
}
