//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "load_ad_request.h"
#import "AdmobTestFixtures.h"

// ============================================================================
// File-scope helpers – table-driven test cases
// ============================================================================

typedef struct {
	const char *input;
	GADMediaAspectRatio expected;
} MediaAspectRatioCase;

typedef struct {
	const char *input;
	GADAdChoicesPosition expected;
} AdChoicesPlacementCase;

typedef struct {
	const char *input;
	UIViewContentMode expected;
} ContentModeCase;

// ============================================================================
// LoadAdRequestNativeAdOptionsTests
// ============================================================================

@interface LoadAdRequestNativeAdOptionsTests : XCTestCase
@end

@implementation LoadAdRequestNativeAdOptionsTests

// ---------------------------------------------------------------------------
// Private helpers – extract a specific GADAdLoaderOptions subtype from the
// array returned by createNativeAdLoaderOptions.  All return nil when the
// requested type is not present so the calling test can assert and stop
// cleanly rather than crashing with a bad cast.
// ---------------------------------------------------------------------------

- (nullable GADNativeAdImageAdLoaderOptions *)imageOptionsFrom:(NSArray<GADAdLoaderOptions *> *)options {
	for (GADAdLoaderOptions *opt in options) {
		if ([opt isKindOfClass:[GADNativeAdImageAdLoaderOptions class]]) {
			return (GADNativeAdImageAdLoaderOptions *)opt;
		}
	}
	return nil;
}

- (nullable GADNativeAdMediaAdLoaderOptions *)mediaOptionsFrom:(NSArray<GADAdLoaderOptions *> *)options {
	for (GADAdLoaderOptions *opt in options) {
		if ([opt isKindOfClass:[GADNativeAdMediaAdLoaderOptions class]]) {
			return (GADNativeAdMediaAdLoaderOptions *)opt;
		}
	}
	return nil;
}

- (nullable GADNativeAdViewAdOptions *)viewAdOptionsFrom:(NSArray<GADAdLoaderOptions *> *)options {
	for (GADAdLoaderOptions *opt in options) {
		if ([opt isKindOfClass:[GADNativeAdViewAdOptions class]]) {
			return (GADNativeAdViewAdOptions *)opt;
		}
	}
	return nil;
}

// ---------------------------------------------------------------------------
// createNativeAdLoaderOptions – basic structure
// ---------------------------------------------------------------------------

- (void)testCreateNativeAdLoaderOptions_always_returnsNonNil {
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:[AdmobTestFixtures makeMinimalNativeRequest]];
	XCTAssertNotNil([req createNativeAdLoaderOptions]);
}

- (void)testCreateNativeAdLoaderOptions_withNoNativeKeys_returnsEmptyArray {
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:[AdmobTestFixtures makeMinimalNativeRequest]];
	XCTAssertEqual([req createNativeAdLoaderOptions].count, 0UL);
}

- (void)testCreateNativeAdLoaderOptions_onBannerRequest_returnsEmptyArray {
	// createNativeAdLoaderOptions is safe to call on any request type; a banner
	// request carries no native keys and must produce an empty array.
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"BANNER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqual([req createNativeAdLoaderOptions].count, 0UL);
}

// ---------------------------------------------------------------------------
// createNativeAdLoaderOptions – image loading options (GADNativeAdImageAdLoaderOptions)
// ---------------------------------------------------------------------------

- (void)testCreateNativeAdLoaderOptions_withReturnUrlsTrue_producesImageOptionsObject {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithReturnUrlsForImageAssets:YES]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];
	XCTAssertNotNil([self imageOptionsFrom:options],
			@"returnUrls=YES must produce a GADNativeAdImageAdLoaderOptions object");
}

- (void)testCreateNativeAdLoaderOptions_withReturnUrlsTrue_disableImageLoadingIsYES {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithReturnUrlsForImageAssets:YES]];
	GADNativeAdImageAdLoaderOptions *imageOpts = [self imageOptionsFrom:[req createNativeAdLoaderOptions]];
	XCTAssertNotNil(imageOpts);
	XCTAssertTrue(imageOpts.disableImageLoading);
}

- (void)testCreateNativeAdLoaderOptions_withReturnUrlsFalse_disableImageLoadingIsNO {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithReturnUrlsForImageAssets:NO]];
	GADNativeAdImageAdLoaderOptions *imageOpts = [self imageOptionsFrom:[req createNativeAdLoaderOptions]];
	XCTAssertNotNil(imageOpts);
	XCTAssertFalse(imageOpts.disableImageLoading);
}

- (void)testCreateNativeAdLoaderOptions_withRequestMultipleImagesTrue_shouldRequestMultipleImagesIsYES {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithRequestMultipleImages:YES]];
	GADNativeAdImageAdLoaderOptions *imageOpts = [self imageOptionsFrom:[req createNativeAdLoaderOptions]];
	XCTAssertNotNil(imageOpts);
	XCTAssertTrue(imageOpts.shouldRequestMultipleImages);
}

- (void)testCreateNativeAdLoaderOptions_withRequestMultipleImagesFalse_shouldRequestMultipleImagesIsNO {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithRequestMultipleImages:NO]];
	GADNativeAdImageAdLoaderOptions *imageOpts = [self imageOptionsFrom:[req createNativeAdLoaderOptions]];
	XCTAssertNotNil(imageOpts);
	XCTAssertFalse(imageOpts.shouldRequestMultipleImages);
}

- (void)testCreateNativeAdLoaderOptions_withBothImageKeys_producesSingleImageOptionsObject {
	// Both image-related keys must be collapsed into one GADNativeAdImageAdLoaderOptions, not two.
	Dictionary d = [AdmobTestFixtures makeMinimalNativeRequest];
	d["native_return_urls_for_image_assets"] = true;
	d["native_request_multiple_images"] = true;
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	NSUInteger imageCount = 0;
	for (GADAdLoaderOptions *opt in options) {
		if ([opt isKindOfClass:[GADNativeAdImageAdLoaderOptions class]]) {
			imageCount++;
		}
	}
	XCTAssertEqual(imageCount, 1UL, @"Both image keys must map to a single options object");
}

- (void)testCreateNativeAdLoaderOptions_withBothImageKeys_bothPropertiesSetCorrectly {
	Dictionary d = [AdmobTestFixtures makeMinimalNativeRequest];
	d["native_return_urls_for_image_assets"] = true;
	d["native_request_multiple_images"] = true;
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADNativeAdImageAdLoaderOptions *imageOpts = [self imageOptionsFrom:[req createNativeAdLoaderOptions]];

	XCTAssertNotNil(imageOpts);
	XCTAssertTrue(imageOpts.disableImageLoading);
	XCTAssertTrue(imageOpts.shouldRequestMultipleImages);
}

// ---------------------------------------------------------------------------
// createNativeAdLoaderOptions – media aspect ratio (GADNativeAdMediaAdLoaderOptions)
// ---------------------------------------------------------------------------

- (void)testCreateNativeAdLoaderOptions_allMediaAspectRatioValues_mappedCorrectly {
	MediaAspectRatioCase cases[] = {
		{"UNKNOWN",   GADMediaAspectRatioUnknown},
		{"ANY",       GADMediaAspectRatioAny},
		{"LANDSCAPE", GADMediaAspectRatioLandscape},
		{"PORTRAIT",  GADMediaAspectRatioPortrait},
		{"SQUARE",    GADMediaAspectRatioSquare},
	};

	for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i) {
		NSString *input = [NSString stringWithUTF8String:cases[i].input];
		LoadAdRequest *req = [[LoadAdRequest alloc]
				initWithDictionary:[AdmobTestFixtures makeNativeRequestWithMediaAspectRatio:input]];
		GADNativeAdMediaAdLoaderOptions *mediaOpts = [self mediaOptionsFrom:[req createNativeAdLoaderOptions]];

		XCTAssertNotNil(mediaOpts, @"Expected GADNativeAdMediaAdLoaderOptions for ratio '%s'", cases[i].input);
		XCTAssertEqual(mediaOpts.mediaAspectRatio, cases[i].expected,
				@"Ratio '%s' should map to %ld", cases[i].input, (long)cases[i].expected);
	}
}

- (void)testCreateNativeAdLoaderOptions_unknownMediaAspectRatioString_fallsBackToUnknown {
	Dictionary d = [AdmobTestFixtures makeMinimalNativeRequest];
	d["native_media_aspect_ratio"] = String("NOT_A_REAL_RATIO");
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADNativeAdMediaAdLoaderOptions *mediaOpts = [self mediaOptionsFrom:[req createNativeAdLoaderOptions]];

	XCTAssertNotNil(mediaOpts);
	XCTAssertEqual(mediaOpts.mediaAspectRatio, GADMediaAspectRatioUnknown);
}

- (void)testCreateNativeAdLoaderOptions_withOnlyMediaAspectRatio_noImageOrViewOptions {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithMediaAspectRatio:@"LANDSCAPE"]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	XCTAssertNil([self imageOptionsFrom:options], @"Only media key set — must not produce image options");
	XCTAssertNil([self viewAdOptionsFrom:options], @"Only media key set — must not produce view ad options");
	XCTAssertEqual(options.count, 1UL);
}

// ---------------------------------------------------------------------------
// createNativeAdLoaderOptions – AdChoices placement (GADNativeAdViewAdOptions)
// ---------------------------------------------------------------------------

- (void)testCreateNativeAdLoaderOptions_allAdChoicesPlacementValues_mappedCorrectly {
	AdChoicesPlacementCase cases[] = {
		{"TOP_LEFT",     GADAdChoicesPositionTopLeftCorner},
		{"TOP_RIGHT",    GADAdChoicesPositionTopRightCorner},
		{"BOTTOM_RIGHT", GADAdChoicesPositionBottomRightCorner},
		{"BOTTOM_LEFT",  GADAdChoicesPositionBottomLeftCorner},
	};

	for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i) {
		NSString *input = [NSString stringWithUTF8String:cases[i].input];
		LoadAdRequest *req = [[LoadAdRequest alloc]
				initWithDictionary:[AdmobTestFixtures makeNativeRequestWithAdChoicesPlacement:input]];
		GADNativeAdViewAdOptions *viewOpts = [self viewAdOptionsFrom:[req createNativeAdLoaderOptions]];

		XCTAssertNotNil(viewOpts,
				@"Expected GADNativeAdViewAdOptions for placement '%s'", cases[i].input);
		XCTAssertEqual(viewOpts.preferredAdChoicesPosition, cases[i].expected,
				@"Placement '%s' should map to %ld", cases[i].input, (long)cases[i].expected);
	}
}

- (void)testCreateNativeAdLoaderOptions_unknownAdChoicesPlacementString_fallsBackToTopRight {
	// The SDK default is top-right; the production switch default branch must
	// map any unrecognised string to GADAdChoicesPositionTopRightCorner.
	Dictionary d = [AdmobTestFixtures makeMinimalNativeRequest];
	d["native_ad_choices_placement"] = String("CENTRE"); // common misspelling – not a valid key
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	GADNativeAdViewAdOptions *viewOpts = [self viewAdOptionsFrom:[req createNativeAdLoaderOptions]];

	XCTAssertNotNil(viewOpts);
	XCTAssertEqual(viewOpts.preferredAdChoicesPosition, GADAdChoicesPositionTopRightCorner);
}

- (void)testCreateNativeAdLoaderOptions_withOnlyAdChoicesPlacement_noImageOrMediaOptions {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithAdChoicesPlacement:@"BOTTOM_LEFT"]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	XCTAssertNil([self imageOptionsFrom:options], @"Only placement key set — must not produce image options");
	XCTAssertNil([self mediaOptionsFrom:options], @"Only placement key set — must not produce media options");
	XCTAssertEqual(options.count, 1UL);
}

// ---------------------------------------------------------------------------
// createNativeAdLoaderOptions – isolation: each category is independent
// ---------------------------------------------------------------------------

- (void)testCreateNativeAdLoaderOptions_withOnlyReturnUrls_noMediaOrViewOptions {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithReturnUrlsForImageAssets:YES]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	XCTAssertNil([self mediaOptionsFrom:options], @"Only returnUrls set — must not produce media options");
	XCTAssertNil([self viewAdOptionsFrom:options], @"Only returnUrls set — must not produce view ad options");
	XCTAssertEqual(options.count, 1UL);
}

- (void)testCreateNativeAdLoaderOptions_withOnlyMultipleImages_noMediaOrViewOptions {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithRequestMultipleImages:YES]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	XCTAssertNil([self mediaOptionsFrom:options]);
	XCTAssertNil([self viewAdOptionsFrom:options]);
	XCTAssertEqual(options.count, 1UL);
}

// ---------------------------------------------------------------------------
// createNativeAdLoaderOptions – combined: all options set
// ---------------------------------------------------------------------------

- (void)testCreateNativeAdLoaderOptions_withAllOptions_producesThreeOptionsObjects {
	// makeFullNativeRequest sets all three GADAdLoaderOptions categories:
	//   image  (returnUrls + multipleImages → 1 GADNativeAdImageAdLoaderOptions)
	//   media  (aspect ratio             → 1 GADNativeAdMediaAdLoaderOptions)
	//   view   (adChoices placement      → 1 GADNativeAdViewAdOptions)
	// native_image_scale_type and native_disable_validator are NOT AdLoader options
	// so they must not add extra objects to the array.
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeFullNativeRequest]];
	XCTAssertEqual([req createNativeAdLoaderOptions].count, 3UL);
}

- (void)testCreateNativeAdLoaderOptions_withAllOptions_allThreeTypesPresent {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeFullNativeRequest]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	XCTAssertNotNil([self imageOptionsFrom:options],  @"Full request must contain image options");
	XCTAssertNotNil([self mediaOptionsFrom:options],  @"Full request must contain media options");
	XCTAssertNotNil([self viewAdOptionsFrom:options], @"Full request must contain view ad options");
}

- (void)testCreateNativeAdLoaderOptions_withAllOptions_correctValuesForEachType {
	// Verify that all three option objects carry the expected values from
	// makeFullNativeRequest (LANDSCAPE, returnUrls=YES, multiImg=YES, BOTTOM_LEFT).
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeFullNativeRequest]];
	NSArray<GADAdLoaderOptions *> *options = [req createNativeAdLoaderOptions];

	GADNativeAdImageAdLoaderOptions *imageOpts = [self imageOptionsFrom:options];
	XCTAssertTrue(imageOpts.disableImageLoading);
	XCTAssertTrue(imageOpts.shouldRequestMultipleImages);

	GADNativeAdMediaAdLoaderOptions *mediaOpts = [self mediaOptionsFrom:options];
	XCTAssertEqual(mediaOpts.mediaAspectRatio, GADMediaAspectRatioLandscape);

	GADNativeAdViewAdOptions *viewOpts = [self viewAdOptionsFrom:options];
	XCTAssertEqual(viewOpts.preferredAdChoicesPosition, GADAdChoicesPositionBottomLeftCorner);
}

// ---------------------------------------------------------------------------
// hasNativeImageScaleType
// ---------------------------------------------------------------------------

- (void)testHasNativeImageScaleType_whenAbsent_returnsNO {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeMinimalNativeRequest]];
	XCTAssertFalse([req hasNativeImageScaleType]);
}

- (void)testHasNativeImageScaleType_whenPresent_returnsYES {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithImageScaleType:@"CENTER_CROP"]];
	XCTAssertTrue([req hasNativeImageScaleType]);
}

- (void)testHasNativeImageScaleType_onBannerRequest_returnsNO {
	// Banner requests never carry native option keys; the predicate must be safe
	// to call on any request type.
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"BANNER" adPosition:@"BOTTOM"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req hasNativeImageScaleType]);
}

// ---------------------------------------------------------------------------
// nativeImageContentMode
// ---------------------------------------------------------------------------

- (void)testNativeImageContentMode_whenAbsent_returnsScaleAspectFit {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeMinimalNativeRequest]];
	XCTAssertEqual([req nativeImageContentMode], UIViewContentModeScaleAspectFit);
}

- (void)testNativeImageContentMode_allValidValues_mappedCorrectly {
	// FIT_CENTER and CENTER_INSIDE both map to ScaleAspectFit because iOS has
	// only one "fit-within-bounds" content mode.  FIT_START and MATRIX both
	// map to TopLeft as the closest available approximation (documented in
	// load_ad_request.h).
	ContentModeCase cases[] = {
		{"FIT_CENTER",    UIViewContentModeScaleAspectFit},
		{"CENTER_INSIDE", UIViewContentModeScaleAspectFit},
		{"FIT_XY",        UIViewContentModeScaleToFill},
		{"CENTER_CROP",   UIViewContentModeScaleAspectFill},
		{"CENTER",        UIViewContentModeCenter},
		{"FIT_END",       UIViewContentModeBottomRight},
		{"FIT_START",     UIViewContentModeTopLeft},
		{"MATRIX",        UIViewContentModeTopLeft},
	};

	for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i) {
		NSString *input = [NSString stringWithUTF8String:cases[i].input];
		LoadAdRequest *req = [[LoadAdRequest alloc]
				initWithDictionary:[AdmobTestFixtures makeNativeRequestWithImageScaleType:input]];
		XCTAssertEqual([req nativeImageContentMode], cases[i].expected,
				@"Scale type '%s' should map to UIViewContentMode %ld",
				cases[i].input, (long)cases[i].expected);
	}
}

- (void)testNativeImageContentMode_unknownValue_returnsScaleAspectFit {
	Dictionary d = [AdmobTestFixtures makeMinimalNativeRequest];
	d["native_image_scale_type"] = String("NOT_A_REAL_SCALE_TYPE");
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertEqual([req nativeImageContentMode], UIViewContentModeScaleAspectFit);
}

- (void)testNativeImageContentMode_fitStartAndMatrixBothMapToTopLeft {
	// Both MATRIX and FIT_START share UIViewContentModeTopLeft as the closest
	// iOS approximation.  This is a secondary guard for the shared branch in
	// the production switch statement.
	LoadAdRequest *fitStart = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithImageScaleType:@"FIT_START"]];
	LoadAdRequest *matrix = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithImageScaleType:@"MATRIX"]];

	XCTAssertEqual([fitStart nativeImageContentMode], UIViewContentModeTopLeft);
	XCTAssertEqual([matrix nativeImageContentMode], UIViewContentModeTopLeft);
}

- (void)testNativeImageContentMode_fitCenterAndCenterInsideBothMapToScaleAspectFit {
	// Both FIT_CENTER and CENTER_INSIDE map to ScaleAspectFit.  This is a
	// secondary guard verifying the shared mapping for completeness.
	LoadAdRequest *fitCenter = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithImageScaleType:@"FIT_CENTER"]];
	LoadAdRequest *centerInside = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithImageScaleType:@"CENTER_INSIDE"]];

	XCTAssertEqual([fitCenter nativeImageContentMode], UIViewContentModeScaleAspectFit);
	XCTAssertEqual([centerInside nativeImageContentMode], UIViewContentModeScaleAspectFit);
}

// ---------------------------------------------------------------------------
// isNativeValidatorDisabled
// ---------------------------------------------------------------------------

- (void)testIsNativeValidatorDisabled_whenAbsent_returnsNO {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeMinimalNativeRequest]];
	XCTAssertFalse([req isNativeValidatorDisabled]);
}

- (void)testIsNativeValidatorDisabled_whenExplicitlyYES_returnsYES {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithValidatorDisabled:YES]];
	XCTAssertTrue([req isNativeValidatorDisabled]);
}

- (void)testIsNativeValidatorDisabled_whenExplicitlyNO_returnsNO {
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeNativeRequestWithValidatorDisabled:NO]];
	XCTAssertFalse([req isNativeValidatorDisabled]);
}

- (void)testIsNativeValidatorDisabled_onBannerRequest_returnsNO {
	// The predicate must be safe to call on any request type, not only native.
	Dictionary d = [AdmobTestFixtures makeLoadAdRequestDictWithUnit:@"u" adSize:@"BANNER" adPosition:@"TOP"];
	LoadAdRequest *req = [[LoadAdRequest alloc] initWithDictionary:d];
	XCTAssertFalse([req isNativeValidatorDisabled]);
}

// ---------------------------------------------------------------------------
// Combined scenario
// ---------------------------------------------------------------------------

- (void)testFullNativeRequest_nativeOptionPredicatesReturnCorrectValues {
	// A full native request must have all option predicates return the correct
	// values without any option interfering with another.
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeFullNativeRequest]];

	XCTAssertTrue([req hasNativeImageScaleType]);
	XCTAssertEqual([req nativeImageContentMode], UIViewContentModeScaleAspectFill); // CENTER_CROP
	XCTAssertTrue([req isNativeValidatorDisabled]);
}

- (void)testFullNativeRequest_imageScaleTypeDoesNotAffectAdLoaderOptionsCount {
	// native_image_scale_type is applied to the UIImageView after the ad loads,
	// not to the AdLoader.  It must not appear as an extra GADAdLoaderOptions object.
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeFullNativeRequest]];
	// Full request has image + media + view = 3 objects; scale type and
	// validator flag are NOT loader options and must not inflate the count.
	XCTAssertEqual([req createNativeAdLoaderOptions].count, 3UL);
}

- (void)testFullNativeRequest_validatorFlagDoesNotAffectAdLoaderOptionsCount {
	// native_disable_validator has no public SDK API and must not inflate the
	// options array count either.
	LoadAdRequest *req = [[LoadAdRequest alloc]
			initWithDictionary:[AdmobTestFixtures makeFullNativeRequest]];
	XCTAssertEqual([req createNativeAdLoaderOptions].count, 3UL);
}

@end
