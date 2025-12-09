//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_ad_info.h"


static String const kAdIdProperty = "ad_id";
static String const kMeasuredWidthProperty = "measured_width";
static String const kMeasuredHeightProperty = "measured_height";
static String const kIsCollapsibleProperty = "is_collapsible";
static String const kLoadAdRequestProperty = "load_ad_request";


@interface AdmobAdInfo ()

@property (nonatomic, strong) NSString *adId;
@property (nonatomic, strong) LoadAdRequest *loadAdRequest;

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
