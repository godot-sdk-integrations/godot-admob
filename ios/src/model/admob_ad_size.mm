//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_ad_size.h"


static String const kWidthProperty = "width";
static String const kHeightProperty = "height";


@implementation AdmobAdSize

- (instancetype) initWithAdSize:(GADAdSize) adSize {
	self = [super init];
	if (self) {
		_width = adSize.size.width;;
		_height = adSize.size.height;
	}
	return self;
}

- (Dictionary) buildRawData {
	Dictionary dict = Dictionary();

	dict[kWidthProperty] = (int) self.width;
	dict[kHeightProperty] = (int) self.height;

	return dict;
}

@end
