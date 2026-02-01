//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_load_ad_error.h"


static String const kResponseInfoProperty = "response_info";


@implementation AdmobLoadAdError

- (instancetype) initWithNsError:(NSError*) nsError {
	self = [super initWithNsError: nsError];
	if (self) {
		GADResponseInfo* gadResponseInfo = nsError.userInfo[GADErrorUserInfoKeyResponseInfo];
		if (gadResponseInfo) {
			_responseInfo = [[AdmobResponse alloc] initWithResponseInfo:gadResponseInfo];
		}
	}
	return self;
}

- (Dictionary) buildRawData {
	Dictionary dict = [super buildRawData];

	if (self.responseInfo) {
		dict[kResponseInfoProperty] = [self.responseInfo buildRawData];
	}

	return dict;
}

@end
