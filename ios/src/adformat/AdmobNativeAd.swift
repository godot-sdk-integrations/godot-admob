//
// © 2026-present https://github.com/cengiz-pz
//

import Foundation
import GoogleMobileAds
import OSLog
import UIKit

@objc public protocol AdmobNativeAdDelegate: AnyObject {
	func nativeAdDidLoad(_ adInfo: AdmobAdInfo, responseInfo: ResponseInfo)
	func nativeAdDidFailToLoad(_ adInfo: AdmobAdInfo, error: Error)
	func nativeAdDidRecordImpression(_ adInfo: AdmobAdInfo)
	func nativeAdDidRecordClick(_ adInfo: AdmobAdInfo)
	func nativeAdWillPresentScreen(_ adInfo: AdmobAdInfo)
	func nativeAdDidDismissScreen(_ adInfo: AdmobAdInfo)
	func nativeAdDidSizeMeasured(_ adInfo: AdmobAdInfo)
}

@objc public class AdmobNativeAd: NSObject {

	private static let logger = Logger(
		subsystem: "org.godotengine.plugin.admob",
		category: "AdmobNativeAd"
	)

	private let adInfo: AdmobAdInfo
	private let adRequest: Request
	private var delegate: AdmobNativeAdDelegate?
	private var parentView: UIView?

	private var nativeAd: NativeAd?
	private var adView: NativeAdView?
	private var containerView: UIView?
	private var adLoader: AdLoader?

	private var lastX: CGFloat = -1
	private var lastY: CGFloat = -1
	private var lastWidth: CGFloat = -1
	private var lastHeight: CGFloat = -1
	private var lastVisible: Bool = true

	@objc public init(adInfo: AdmobAdInfo, adRequest: Request, parentView: UIView, delegate: AdmobNativeAdDelegate) {
		self.adInfo = adInfo
		self.adRequest = adRequest
		self.parentView = parentView
		self.delegate = delegate

		super.init()
	}

	@objc public func load() {
		guard parentView != nil else {
			Self.logger.debug("AdmobNativeAd: Error - parent view is nil")
			return
		}

		let adUnitId = adInfo.adUnitId() ?? ""
		Self.logger.debug("AdmobNativeAd: Loading native ad with unit id: \(adUnitId)")

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			guard let rootVC = self.getRootViewController() else {
				Self.logger.debug("AdmobNativeAd: Error - root view controller is nil")
				return
			}

			self.adLoader = AdLoader(
				adUnitID: adUnitId,
				rootViewController: rootVC,
				adTypes: [.native],
				options: []
			)

			self.adLoader?.delegate = self
			self.adLoader?.load(self.adRequest)
		}
	}

	@objc public func show() {
		guard let containerView = containerView else {
			Self.logger.debug("AdmobNativeAd: Error - native ad not loaded yet")
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
		guard let containerView = containerView, parentView != nil else { return }

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

			if width > 0 { frame.size.width = width }
			if height > 0 { frame.size.height = height }

			containerView.frame = frame
			containerView.isHidden = !visible
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

private extension AdmobNativeAd {

	func createNativeAdView() {
		guard let parentView = parentView, let nativeAd = nativeAd else {
			Self.logger.debug("AdmobNativeAd: Error - parent view or native ad is nil")
			return
		}

		let adView = NativeAdView()
		adView.translatesAutoresizingMaskIntoConstraints = false
		self.adView = adView

		let container = UIView()
		container.backgroundColor = .clear
		container.translatesAutoresizingMaskIntoConstraints = false
		containerView = container

		container.addSubview(adView)
		NSLayoutConstraint.activate([
			adView.topAnchor.constraint(equalTo: container.topAnchor),
			adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])

		createAdViewElements(adView: adView, nativeAd: nativeAd)
		bindNativeAd(adView: adView, nativeAd: nativeAd)

		container.isHidden = true
		parentView.addSubview(container)

		let screenWidth = UIScreen.main.bounds.width
		let padding: CGFloat = 16
		NSLayoutConstraint.activate([
			container.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: padding),
			container.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -padding),
			container.widthAnchor.constraint(equalToConstant: screenWidth - (padding * 2))
		])

		#if DEBUG
		container.layer.borderColor = UIColor.red.withAlphaComponent(0.3).cgColor
		container.layer.borderWidth = 2
		adView.layer.borderColor = UIColor.green.withAlphaComponent(0.3).cgColor
		adView.layer.borderWidth = 2
		#endif

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			adView.setNeedsLayout()
			adView.layoutIfNeeded()
			let scale = UIScreen.main.scale
			let widthDp = Int(round(adView.bounds.width / scale * 160))
			let heightDp = Int(round(adView.bounds.height / scale * 160))
			self.adInfo.measuredWidth = widthDp
			self.adInfo.measuredHeight = heightDp
			Self.logger.debug("AdmobNativeAd: Measured size - width: \(widthDp)dp, height: \(heightDp)dp")
			self.delegate?.nativeAdDidSizeMeasured(self.adInfo)
		}
	}

	func createAdViewElements(adView: NativeAdView, nativeAd: NativeAd) {
		let mainStack = UIStackView()
		mainStack.axis = .vertical
		mainStack.spacing = 8
		mainStack.translatesAutoresizingMaskIntoConstraints = false
		adView.addSubview(mainStack)

		let headerStack = UIStackView()
		headerStack.axis = .horizontal
		headerStack.spacing = 8
		headerStack.alignment = .center

		if nativeAd.icon != nil {
			let iconView = UIImageView()
			iconView.contentMode = .scaleAspectFit
			iconView.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				iconView.widthAnchor.constraint(equalToConstant: 40),
				iconView.heightAnchor.constraint(equalToConstant: 40)
			])
			adView.iconView = iconView
			headerStack.addArrangedSubview(iconView)
		}

		let textStack = UIStackView()
		textStack.axis = .vertical
		textStack.spacing = 2

		let headlineLabel = UILabel()
		headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
		headlineLabel.numberOfLines = 2
		adView.headlineView = headlineLabel
		textStack.addArrangedSubview(headlineLabel)

		if nativeAd.advertiser != nil {
			let advertiserLabel = UILabel()
			advertiserLabel.font = UIFont.systemFont(ofSize: 12)
			advertiserLabel.textColor = .gray
			adView.advertiserView = advertiserLabel
			textStack.addArrangedSubview(advertiserLabel)
		}

		headerStack.addArrangedSubview(textStack)
		mainStack.addArrangedSubview(headerStack)

		let mediaContent = nativeAd.mediaContent
		if mediaContent.hasVideoContent || mediaContent.mainImage != nil {
			let mediaView = MediaView()
			mediaView.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([mediaView.heightAnchor.constraint(equalToConstant: 160)])
			adView.mediaView = mediaView
			mainStack.addArrangedSubview(mediaView)
		}

		if nativeAd.body != nil {
			let bodyLabel = UILabel()
			bodyLabel.font = UIFont.systemFont(ofSize: 14)
			bodyLabel.numberOfLines = 3
			adView.bodyView = bodyLabel
			mainStack.addArrangedSubview(bodyLabel)
		}

		if nativeAd.starRating != nil {
			adView.starRatingView = createStarRatingView()
			mainStack.addArrangedSubview(adView.starRatingView!)
		}

		if nativeAd.store != nil || nativeAd.price != nil {
			mainStack.addArrangedSubview(createBottomInfoStack(adView: adView, nativeAd: nativeAd))
		}

		if nativeAd.callToAction != nil {
			mainStack.addArrangedSubview(createCallToActionButton(adView: adView))
		}

		NSLayoutConstraint.activate([
			mainStack.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
			mainStack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
			mainStack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
			mainStack.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12)
		])

		adView.backgroundColor = .white
		adView.layer.cornerRadius = 8
		adView.layer.borderWidth = 1
		adView.layer.borderColor = UIColor.lightGray.cgColor
	}

	func createBottomInfoStack(adView: NativeAdView, nativeAd: NativeAd) -> UIStackView {
		let bottomStack = UIStackView()
		bottomStack.axis = .horizontal
		bottomStack.spacing = 8

		if nativeAd.store != nil {
			let storeLabel = UILabel()
			storeLabel.font = UIFont.systemFont(ofSize: 12)
			storeLabel.textColor = .gray
			adView.storeView = storeLabel
			bottomStack.addArrangedSubview(storeLabel)
		}

		if nativeAd.price != nil {
			let priceLabel = UILabel()
			priceLabel.font = UIFont.systemFont(ofSize: 12)
			priceLabel.textColor = .gray
			adView.priceView = priceLabel
			bottomStack.addArrangedSubview(priceLabel)
		}

		return bottomStack
	}

	func createCallToActionButton(adView: NativeAdView) -> UIButton {
		let ctaButton = UIButton(type: .system)
		ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		ctaButton.backgroundColor = UIColor.systemBlue
		ctaButton.setTitleColor(.white, for: .normal)
		ctaButton.layer.cornerRadius = 8
		ctaButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([ctaButton.heightAnchor.constraint(equalToConstant: 44)])
		ctaButton.isUserInteractionEnabled = false
		adView.callToActionView = ctaButton
		return ctaButton
	}

	func createStarRatingView() -> UIView {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false

		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 2
		stackView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			stackView.topAnchor.constraint(equalTo: container.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			container.heightAnchor.constraint(equalToConstant: 16)
		])

		for _ in 0..<5 {
			let imageView = UIImageView()
			imageView.contentMode = .scaleAspectFit
			imageView.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				imageView.widthAnchor.constraint(equalToConstant: 16),
				imageView.heightAnchor.constraint(equalToConstant: 16)
			])
			stackView.addArrangedSubview(imageView)
		}

		return container
	}

	func bindNativeAd(adView: NativeAdView, nativeAd: NativeAd) {
		adView.nativeAd = nativeAd

		if let headlineView = adView.headlineView as? UILabel {
			headlineView.text = nativeAd.headline
		}
		if let mediaView = adView.mediaView {
			mediaView.mediaContent = nativeAd.mediaContent
		}
		if let ctaView = adView.callToActionView as? UIButton {
			ctaView.setTitle(nativeAd.callToAction, for: .normal)
		}
		if let iconView = adView.iconView as? UIImageView, let icon = nativeAd.icon {
			iconView.image = icon.image
		}
		if let bodyView = adView.bodyView as? UILabel {
			bodyView.text = nativeAd.body
		}
		if let advertiserView = adView.advertiserView as? UILabel {
			advertiserView.text = nativeAd.advertiser
		}
		if let storeView = adView.storeView as? UILabel {
			storeView.text = nativeAd.store
		}
		if let priceView = adView.priceView as? UILabel {
			priceView.text = nativeAd.price
		}

		bindStarRating(adView: adView, nativeAd: nativeAd)
	}

	func bindStarRating(adView: NativeAdView, nativeAd: NativeAd) {
		guard let starRatingContainer = adView.starRatingView,
			let stackView = starRatingContainer.subviews.first as? UIStackView,
			let rating = nativeAd.starRating else { return }

		let ratingValue = rating.doubleValue
		let fullStars = Int(ratingValue)
		let hasHalfStar = (ratingValue - Double(fullStars)) >= 0.5

		for (index, view) in stackView.arrangedSubviews.enumerated() {
			guard let imageView = view as? UIImageView else { continue }
			if index < fullStars {
				imageView.image = UIImage(systemName: "star.fill")
			} else if index == fullStars && hasHalfStar {
				imageView.image = UIImage(systemName: "star.leadinghalf.filled")
			} else {
				imageView.image = UIImage(systemName: "star")
			}
			imageView.tintColor = .systemYellow
		}
	}
}

extension AdmobNativeAd: NativeAdLoaderDelegate {
	public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
		Self.logger.debug("AdmobNativeAd: Ad loaded successfully")

		self.nativeAd = nativeAd
		nativeAd.delegate = self

		createNativeAdView()

		delegate?.nativeAdDidLoad(self.adInfo, responseInfo: nativeAd.responseInfo)
	}

	public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
		Self.logger.error("AdmobNativeAd: Failed to load ad with error: \(error.localizedDescription)")
		delegate?.nativeAdDidFailToLoad(self.adInfo, error: error)
	}
}

extension AdmobNativeAd: NativeAdDelegate {

	public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
		Self.logger.debug("AdmobNativeAd: Impression recorded")
		delegate?.nativeAdDidRecordImpression(self.adInfo)
	}

	public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
		Self.logger.debug("AdmobNativeAd: Click recorded")
		delegate?.nativeAdDidRecordClick(self.adInfo)
	}

	public func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
		Self.logger.debug("AdmobNativeAd: Will present screen")
		delegate?.nativeAdWillPresentScreen(self.adInfo)
	}

	public func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
		Self.logger.debug("AdmobNativeAd: Did dismiss screen")
		delegate?.nativeAdDidDismissScreen(self.adInfo)
	}

	public func nativeAdWillLeaveApplication(_ nativeAd: NativeAd) {
		Self.logger.debug("AdmobNativeAd: Will leave application")
	}
}
