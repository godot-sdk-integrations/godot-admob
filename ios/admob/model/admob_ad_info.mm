//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_ad_info.h"

#import "load_ad_request.h"

#include "core/object/class_db.h"

static String const kAdIdProperty = "ad_id";
static String const kMeasuredWidthProperty = "measured_width";
static String const kMeasuredHeightProperty = "measured_height";
static String const kIsCollapsibleProperty = "is_collapsible";
static String const kLoadAdRequestProperty = "load_ad_request";


@interface AdmobAdInfo ()

@property (nonatomic, strong) NSString *adId;
@property (nonatomic, strong) LoadAdRequest *loadAdRequest;

/**
 * Initializes the ad info wrapper with the ad details
 * @param adId The ad's internal identifier
 * @param loadAdRequest The data that the ad was requested with
 */
- (instancetype) initWithId:(NSString *)adId request:(LoadAdRequest *)loadAdRequest;

/**
 * Builds a Godot-compatible Dictionary containing the ad info
 * @return A Dictionary object with the ad info
 */
- (Dictionary) buildRawData;

@end


@implementation AdmobAdInfo

- (instancetype) initWithId:(NSString *)adId request:(LoadAdRequest *)loadAdRequest {
	self = [super init];
	if (self) {
		_adId = adId;
		_isCollapsible = NO;
		_loadAdRequest = loadAdRequest;
	}
	return self;
}

- (NSString*) adUnitId {
	return [self.loadAdRequest adUnitId];
}

- (Dictionary) buildRawData {
	Dictionary dict = Dictionary();

	dict[kAdIdProperty] = [self.adId UTF8String];
	dict[kMeasuredWidthProperty] = (int) self.measuredWidth;
	dict[kMeasuredHeightProperty] = (int) self.measuredHeight;
	dict[kIsCollapsibleProperty] = self.isCollapsible;

	if (self.loadAdRequest) {
		dict[kLoadAdRequestProperty] = [self.loadAdRequest getRawData];
	}

	return dict;
}

@end
