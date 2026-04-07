//
// © 2026-present https://github.com/cengiz-pz
//

#import <XCTest/XCTest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "admob_ad_size.h"

// ============================================================================
// AdmobAdSizeTests
// ============================================================================

@interface AdmobAdSizeTests : XCTestCase
@end

@implementation AdmobAdSizeTests

// ---------------------------------------------------------------------------
// Initialisation
// ---------------------------------------------------------------------------

- (void)testInitWithBanner_storesDimensions {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeBanner];
	XCTAssertEqual(adSize.width, GADAdSizeBanner.size.width);
	XCTAssertEqual(adSize.height, GADAdSizeBanner.size.height);
}

- (void)testInitWithMediumRectangle_storesDimensions {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeMediumRectangle];
	XCTAssertEqual(adSize.width, GADAdSizeMediumRectangle.size.width);
	XCTAssertEqual(adSize.height, GADAdSizeMediumRectangle.size.height);
}

- (void)testInitWithLeaderboard_storesDimensions {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeLeaderboard];
	XCTAssertEqual(adSize.width, GADAdSizeLeaderboard.size.width);
	XCTAssertEqual(adSize.height, GADAdSizeLeaderboard.size.height);
}

- (void)testInitWithFullBanner_storesDimensions {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeFullBanner];
	XCTAssertEqual(adSize.width, GADAdSizeFullBanner.size.width);
	XCTAssertEqual(adSize.height, GADAdSizeFullBanner.size.height);
}

- (void)testInitWithSkyscraper_storesDimensions {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeSkyscraper];
	XCTAssertEqual(adSize.width, GADAdSizeSkyscraper.size.width);
	XCTAssertEqual(adSize.height, GADAdSizeSkyscraper.size.height);
}

// ---------------------------------------------------------------------------
// buildRawData
// ---------------------------------------------------------------------------

- (void)testBuildRawData_containsWidthKey {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeBanner];
	Dictionary dict = [adSize buildRawData];
	XCTAssertTrue(dict.has(String("width")));
}

- (void)testBuildRawData_containsHeightKey {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeBanner];
	Dictionary dict = [adSize buildRawData];
	XCTAssertTrue(dict.has(String("height")));
}

- (void)testBuildRawData_widthMatchesBanner {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeBanner];
	Dictionary dict = [adSize buildRawData];
	int width = dict[String("width")];
	XCTAssertEqual(width, (int)GADAdSizeBanner.size.width);
}

- (void)testBuildRawData_heightMatchesBanner {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeBanner];
	Dictionary dict = [adSize buildRawData];
	int height = dict[String("height")];
	XCTAssertEqual(height, (int)GADAdSizeBanner.size.height);
}

- (void)testBuildRawData_mediumRectangleValues {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeMediumRectangle];
	Dictionary dict = [adSize buildRawData];
	// Medium rectangle is 300×250 in portrait
	XCTAssertEqual((int)dict[String("width")], 300);
	XCTAssertEqual((int)dict[String("height")], 250);
}

- (void)testBuildRawData_leaderboardValues {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeLeaderboard];
	Dictionary dict = [adSize buildRawData];
	// Leaderboard is 728×90
	XCTAssertEqual((int)dict[String("width")], 728);
	XCTAssertEqual((int)dict[String("height")], 90);
}

- (void)testBuildRawData_containsOnlyTwoKeys {
	AdmobAdSize *adSize = [[AdmobAdSize alloc] initWithAdSize:GADAdSizeBanner];
	Dictionary dict = [adSize buildRawData];
	XCTAssertEqual(dict.size(), 2);
}

@end
