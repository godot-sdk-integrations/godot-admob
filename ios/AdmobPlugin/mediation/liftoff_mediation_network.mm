//
// © 2024-present https://github.com/cengiz-pz
//

#import "liftoff_mediation_network.h"

@implementation LiftoffMediationNetwork

static NSString *_TAG = @"liftoff";
static NSString *const ADAPTER_CLASS = @"GADMediationAdapterVungle";

+ (NSString *)TAG {
	return _TAG;
}

- (instancetype)init {
	return [super initWithTag:_TAG];
}

- (NSString *)getAdapterClassName {
	return ADAPTER_CLASS;
}

- (void)applyGDPRSettings:(BOOL)hasGdprConsent {
	// Starting in Vungle SDK version 7.4.1, Liftoff Monetize automatically reads GDPR consent set by UMP SDK.
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [VunglePrivacySettings setCCPAStatus:YES];
	 */
	Class vungleClass = ClassOrThrow(@"VungleAdsSDK.VunglePrivacySettings");

	SEL ccpaSel = SelectorForClassOrThrow(@"setCCPAStatus:", vungleClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(vungleClass, ccpaSel, hasCcpaConsent);
}

@end
