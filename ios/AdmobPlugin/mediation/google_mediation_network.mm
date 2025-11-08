//
// © 2024-present https://github.com/cengiz-pz
//

#import "google_mediation_network.h"

@implementation GoogleMediationNetwork

static NSString *const _TAG = @"google";
static NSString *const _ADAPTER_CLASS = @"GADMobileAds";

+ (NSString *)TAG {
	return _TAG;
}

+ (NSString *)ADAPTER_CLASS {
	return _ADAPTER_CLASS;
}

- (instancetype)init {
	return [super initWithTag:_TAG];
}

- (NSString *)getAdapterClassName {
	return _ADAPTER_CLASS;
}

- (void)applyGDPRSettings:(BOOL)hasGdprConsent {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

@end
