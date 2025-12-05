//
// © 2024-present https://github.com/cengiz-pz
//

#import "banner.h"

#import "admob_plugin_implementation.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "admob_ad_error.h"
#import "admob_load_ad_error.h"


@implementation BannerAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
		self.isLoaded = NO;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	self.gadAdSize = [loadAdRequest getGADAdSize];
	self.adPosition = [loadAdRequest getAdPosition];
	self.adUnitId = [loadAdRequest adUnitId];

	[self addBanner];

	[self.bannerView loadRequest:[loadAdRequest createGADRequest]];
}

- (void) destroy {
	[self.bannerView setHidden:YES];
	[self.bannerView removeFromSuperview];
	self.bannerView = nil;
}

- (void) hide {
	[self.bannerView setHidden:YES];
}

- (void) show {
	[self.bannerView setHidden:NO];
}

- (int) getWidth {
	return self.bannerView.bounds.size.width;
}

- (int) getHeight {
	return self.bannerView.bounds.size.height;
}

- (int) getWidthInPixels {
	CGFloat scale = [[UIScreen mainScreen] scale];
	return (int)(self.bannerView.bounds.size.width * scale);
}

- (int) getHeightInPixels {
	CGFloat scale = [[UIScreen mainScreen] scale];
	return (int)(self.bannerView.bounds.size.height * scale);
}

- (void) addBanner {
	self.bannerView = [[GADBannerView alloc] initWithAdSize:self.gadAdSize];
	self.bannerView.adUnitID = self.adUnitId;
	self.bannerView.delegate = self;
	self.bannerView.rootViewController = self;
	[self.bannerView setHidden:YES];
	self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
	[GDTAppDelegateService.viewController.view addSubview:self.bannerView];
	if (self.adPosition != AdPositionCustom) {
		[self updateBannerPosition:static_cast<AdPosition>(self.adPosition)];
	} else {
		self.bannerView.frame = CGRectZero;
	}
}

- (void) addBannerConstraint:(NSLayoutAttribute)attribute toView:(id)toView {
	[GDTAppDelegateService.viewController.view addConstraint:
				[NSLayoutConstraint constraintWithItem:self.bannerView attribute:attribute relatedBy:NSLayoutRelationEqual
							toItem:toView attribute:attribute multiplier:1 constant:0]];
}

- (void) addBannerConstraint:(NSLayoutAttribute)attribute toView:(id)toView attributeConstant:(CGFloat)constant {
	[GDTAppDelegateService.viewController.view addConstraint:
				[NSLayoutConstraint constraintWithItem:self.bannerView attribute:attribute relatedBy:NSLayoutRelationEqual
							toItem:toView attribute:attribute multiplier:1 constant:constant]];
}

- (void) updateBannerPosition:(AdPosition) adPosition {
	os_log_debug(admob_log, "BannerAd updateBannerPosition: position=%lu", (unsigned long) adPosition);
	[GDTAppDelegateService.viewController.view removeConstraints:self.bannerView.constraints];

	switch (adPosition) {
		case AdPositionTop:
			[self addBannerConstraint:NSLayoutAttributeCenterX toView:GDTAppDelegateService.viewController.view];
			[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionBottom:
			[self addBannerConstraint:NSLayoutAttributeCenterX toView:GDTAppDelegateService.viewController.view];
			[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionLeft:
			[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionRight:
			[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionTopLeft:
			[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionTopRight:
			[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionBottomLeft:
			[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionBottomRight:
			[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			break;

		case AdPositionCenter:
			[self addBannerConstraint:NSLayoutAttributeCenterX toView:GDTAppDelegateService.viewController.view];
			[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view];
			break;

		case AdPositionCustom:
			// Do nothing, position set externally
			break;
	}

	[GDTAppDelegateService.viewController.view layoutIfNeeded];
}

- (void) bannerViewDidReceiveAd:(GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidReceiveAd %@", self.adId);
	if (self.isLoaded) {
		AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_REFRESHED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[[[AdmobResponse alloc] initWithResponseInfo:bannerView.responseInfo] buildRawData],
				bannerView.isCollapsible);
	}
	else {
		self.isLoaded = YES;
		AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[[[AdmobResponse alloc] initWithResponseInfo:bannerView.responseInfo] buildRawData],
				bannerView.isCollapsible);
	}
}

- (void) bannerView: (GADBannerView *) bannerView didFailToReceiveAdWithError: (NSError *) error {
	AdmobLoadAdError *loadAdError = [[AdmobLoadAdError alloc] initWithNsError:error];
	os_log_error(admob_log, "BannerAd bannerView:didFailToReceiveAdWithError: %@", loadAdError.message);

	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[loadAdError buildRawData]);
}

- (void) bannerViewDidRecordClick: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidRecordClick");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) bannerViewDidRecordImpression: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidRecordImpression");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) bannerViewWillPresentScreen: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewWillPresentScreen");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_OPENED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) bannerViewDidDismissScreen: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidDismissScreen");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_CLOSED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

@end
