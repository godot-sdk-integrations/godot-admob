//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_ad_error.h"


static String const kCodeProperty = "code";
static String const kDomainProperty = "domain";
static String const kMessageProperty = "message";
static String const kCauseProperty = "cause";


@implementation AdmobAdError

- (instancetype) initWithNsError:(NSError*) nsError {
	self = [super init];
	if (self) {
		_code = nsError.code;
		_domain = nsError.domain;

		NSString *localizedDescription = nsError.userInfo[NSLocalizedDescriptionKey];
		if (localizedDescription) {
			_message = localizedDescription;
		} else {
			_message = nil;
		}

		NSError *underlyingError = nsError.userInfo[NSUnderlyingErrorKey];
		if (underlyingError) {
			_cause = [[AdmobAdError alloc] initWithNsError:underlyingError];
		} else {
			_cause = nil;
		}
	}
	return self;
}

- (Dictionary) buildRawData {
	Dictionary dict = Dictionary();

	dict[kCodeProperty] = (int) self.code;
	dict[kDomainProperty] = [self.domain UTF8String];

	if (self.message) {
		dict[kMessageProperty] = [self.message UTF8String];
	}

	if (self.cause) {
		dict[kCauseProperty] = [self.cause buildRawData];
	}

	return dict;
}

@end
