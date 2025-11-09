//
// © 2024-present https://github.com/cengiz-pz
//

#import "mintegral_mediation_network.h"

@implementation MintegralMediationNetwork

static NSString *const _TAG = @"mintegral";
static NSString *const _ADAPTER_CLASS = @"GADMediationAdapterMintegral";

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
	/*
	 * [[MTGSDK sharedInstance] setConsentStatus:YES];
	 */
	Class sdkClass = ClassOrThrow(@"MTGSDK");

	SEL sharedSel = SelectorForClassOrThrow(@"sharedInstance", sdkClass);

	id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
	SEL consentSel = SelectorForClassOrThrow(@"setConsentStatus:", sdk);
	((void (*)(id, SEL, BOOL))objc_msgSend)(sdk, consentSel, hasGdprConsent);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [[MTGSDK sharedInstance] setDoNotTrackStatus:NO];
	 */
	Class sdkClass = ClassOrThrow(@"MTGSDK");

	SEL sharedSel = SelectorForClassOrThrow(@"sharedInstance", sdkClass);

	id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
	SEL dntSel = SelectorForClassOrThrow(@"setDoNotTrackStatus:", sdk);
	((void (*)(id, SEL, BOOL))objc_msgSend)(sdk, dntSel, !hasCcpaConsent);
}

@end
