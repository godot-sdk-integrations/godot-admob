//
// © 2024-present https://github.com/cengiz-pz
//

#import "banner.h"

#import "admob_plugin.h"
#import "admob_response.h"
#import "admob_logger.h"
#import "admob_ad_error.h"
#import "admob_ad_info.h"
#import "admob_load_ad_error.h"


@interface AdmobAdInfo (Access)
- (instancetype) initWithId:(NSString *)adId request:(LoadAdRequest *)loadAdRequest;
- (Dictionary) buildRawData;
@end


@interface BannerAd ()
// Store the constraints applied to the superview so they can be removed cleanly later
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *activeConstraints;

@property (nonatomic, strong) AdmobAdInfo *adInfo;

@property (nonatomic) BOOL anchorToSafeArea;
@end


@implementation BannerAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
		self.isLoaded = NO;
		// Initialize the array to track constraints
		self.activeConstraints = [NSMutableArray array];
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	self.adInfo = [[AdmobAdInfo alloc] initWithId:self.adId request:loadAdRequest];

	self.gadAdSize = [loadAdRequest getGADAdSize];
	self.adPosition = [loadAdRequest getAdPosition];
	self.adUnitId = [loadAdRequest adUnitId];
	self.anchorToSafeArea = [loadAdRequest anchorToSafeArea];

	[self addBanner];

	// Create the request on the current thread (Game Thread) to safely access Godot data
	GADRequest *request = [loadAdRequest createGADRequest];

	// Pass the pre-created request to the Main Thread
	[self.bannerView loadRequest:request];
}

- (void) destroy {
	[self.bannerView setHidden:YES];

	// Clean up constraints explicitly
	if (self.activeConstraints.count > 0) {
		[GDTAppDelegateService.viewController.view removeConstraints:self.activeConstraints];
		[self.activeConstraints removeAllObjects];
	}

	[self.bannerView removeFromSuperview];
	self.bannerView = nil;
}

- (void) hide {
	[self.bannerView setHidden:YES];
}

- (void) show {
	[self.bannerView setHidden:NO];

	CGFloat width = self.bannerView.bounds.size.width;
	CGFloat height = self.bannerView.bounds.size.height;

	os_log_debug(admob_log, "INLINE_ADAPTIVE actual size = %.0fx%.0f", width, height);

	self.adInfo.measuredWidth = roundf(width);
	self.adInfo.measuredHeight = roundf(height);
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", BANNER_AD_SIZE_MEASURED_SIGNAL, [self.adInfo buildRawData]);
}

- (void) moveToX:(real_t)x y:(real_t)y {
	CGFloat scale = [[UIScreen mainScreen] scale];
	CGRect frame = self.bannerView.frame;
	frame.origin = CGPointMake(x / scale, y / scale);
	self.bannerView.frame = frame;
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

	if (self.adPosition == AdPositionCustom) {
		// Use Frame-based layout for Custom position
		self.bannerView.translatesAutoresizingMaskIntoConstraints = YES;
		[GDTAppDelegateService.viewController.view addSubview:self.bannerView];

		// The position will be updated later via move_banner_ad()
	} else {
		// Use Auto Layout for standard positions (Top, Bottom, etc.)
		self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
		[GDTAppDelegateService.viewController.view addSubview:self.bannerView];
		[self updateBannerPosition:static_cast<AdPosition>(self.adPosition)];
	}
}

- (void) addBannerConstraint:(NSLayoutAttribute)attribute toView:(id)toView {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.bannerView 
																attribute:attribute 
																relatedBy:NSLayoutRelationEqual
																	toItem:toView 
																attribute:attribute 
																multiplier:1 
																constant:0];

	[GDTAppDelegateService.viewController.view addConstraint:constraint];
	[self.activeConstraints addObject:constraint]; // Track this constraint
}

- (void) addBannerConstraint:(NSLayoutAttribute)attribute toView:(id)toView attributeConstant:(CGFloat)constant {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.bannerView 
																attribute:attribute 
																relatedBy:NSLayoutRelationEqual
																	toItem:toView 
																attribute:attribute 
																multiplier:1 
																constant:constant];

	[GDTAppDelegateService.viewController.view addConstraint:constraint];
	[self.activeConstraints addObject:constraint]; // Track this constraint
}

- (void) updateBannerPosition:(AdPosition) adPosition {
	os_log_debug(admob_log, "BannerAd updateBannerPosition: position=%lu", (unsigned long) adPosition);

	// Remove only the active positioning constraints
	if (self.activeConstraints.count > 0) {
		[GDTAppDelegateService.viewController.view removeConstraints:self.activeConstraints];
		[self.activeConstraints removeAllObjects];
	}

	switch (adPosition) {
		case AdPositionTop:
			[self addBannerConstraint:NSLayoutAttributeCenterX toView:GDTAppDelegateService.viewController.view];
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionBottom:
			[self addBannerConstraint:NSLayoutAttributeCenterX toView:GDTAppDelegateService.viewController.view];
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionLeft:
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionRight:
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionTopLeft:
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionTopRight:
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeTop toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionBottomLeft:
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeLeft toView:GDTAppDelegateService.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view];
			}
			break;

		case AdPositionBottomRight:
			if (self.anchorToSafeArea) {
				[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view.safeAreaLayoutGuide];
			} else {
				[self addBannerConstraint:NSLayoutAttributeRight toView:GDTAppDelegateService.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:GDTAppDelegateService.viewController.view];
			}
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

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidReceiveAd %@", self.adId);

	self.adInfo.isCollapsible = bannerView.isCollapsible;

	// Wait for layout pass
	dispatch_async(dispatch_get_main_queue(), ^{
		// Force layout of root view
		[GDTAppDelegateService.viewController.view layoutIfNeeded];

		// Wait one more runloop tick so layout has completed
		dispatch_async(dispatch_get_main_queue(), ^{
			CGFloat width = bannerView.bounds.size.width;
			CGFloat height = bannerView.bounds.size.height;

			os_log_debug(admob_log, "INLINE_ADAPTIVE actual size = %.0fx%.0f", width, height);

			self.adInfo.measuredWidth = width;
			self.adInfo.measuredHeight = height;

			// Emit loaded events
			if (self.isLoaded) {
				AdmobPlugin::get_singleton()->call_deferred("emit_signal", 
					BANNER_AD_REFRESHED_SIGNAL,
					[self.adInfo buildRawData],
					[[[AdmobResponse alloc] initWithResponseInfo:bannerView.responseInfo] buildRawData]
				);
			} else {
				self.isLoaded = YES;
				AdmobPlugin::get_singleton()->call_deferred("emit_signal", 
					BANNER_AD_LOADED_SIGNAL,
					[self.adInfo buildRawData],
					[[[AdmobResponse alloc] initWithResponseInfo:bannerView.responseInfo] buildRawData]
				);
			}
		});
	});
}


- (void) bannerView: (GADBannerView *) bannerView didFailToReceiveAdWithError: (NSError *) error {
	AdmobLoadAdError *loadAdError = [[AdmobLoadAdError alloc] initWithNsError:error];
	os_log_error(admob_log, "BannerAd bannerView:didFailToReceiveAdWithError: %@", loadAdError.message);

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", BANNER_AD_FAILED_TO_LOAD_SIGNAL, [self.adInfo buildRawData],
				[loadAdError buildRawData]);
}

- (void) bannerViewDidRecordClick: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidRecordClick");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", BANNER_AD_CLICKED_SIGNAL, [self.adInfo buildRawData]);
}

- (void) bannerViewDidRecordImpression: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidRecordImpression");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", BANNER_AD_IMPRESSION_SIGNAL, [self.adInfo buildRawData]);
}

- (void) bannerViewWillPresentScreen: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewWillPresentScreen");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", BANNER_AD_OPENED_SIGNAL, [self.adInfo buildRawData]);
}

- (void) bannerViewDidDismissScreen: (GADBannerView*) bannerView {
	os_log_debug(admob_log, "BannerAd bannerViewDidDismissScreen");
	AdmobPlugin::get_singleton()->call_deferred("emit_signal", BANNER_AD_CLOSED_SIGNAL, [self.adInfo buildRawData]);
}

@end
