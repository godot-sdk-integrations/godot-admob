//
// © 2024-present https://github.com/cengiz-pz
//

#import "applovin_mediation_network.h"

@implementation ApplovinMediationNetwork

static NSString *_TAG = @"applovin";
static NSString *const ADAPTER_CLASS = @"GADMediationAdapterAppLovin";

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
	/*
	 * [ALPrivacySettings setHasUserConsent:YES];
	 */
	Class privacyClass = ClassOrThrow(@"ALPrivacySettings");
	SEL consentSel = SelectorForClassOrThrow(@"setHasUserConsent:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, hasGdprConsent);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [ALPrivacySettings setDoNotSell:YES];
	 */
	Class privacyClass = ClassOrThrow(@"ALPrivacySettings");
	SEL doNotSellSel = SelectorForClassOrThrow(@"setDoNotSell:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, doNotSellSel, hasCcpaConsent);
}

@end
