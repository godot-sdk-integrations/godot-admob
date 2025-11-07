//
// © 2024-present https://github.com/cengiz-pz
//

#import "mytarget_mediation_network.h"

@implementation MytargetMediationNetwork

static NSString *_TAG = @"mytarget";
static NSString *const ADAPTER_CLASS = @"GADMediationAdapterMyTarget";

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
	 * [MTRGPrivacy setUserConsent:YES];
	 */
	Class privacyClass = ClassOrThrow(@"MTRGPrivacy");

	SEL consentSel = SelectorForClassOrThrow(@"setUserConsent:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, hasGdprConsent);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	/*
	 * [MTRGPrivacy setUserAgeRestricted:YES];
	 */
	Class privacyClass = ClassOrThrow(@"MTRGPrivacy");

	SEL ageSel = SelectorForClassOrThrow(@"setUserAgeRestricted:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, ageSel, isAgeRestrictedUser);
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [MTRGPrivacy setCcpaUserConsent:YES];
	 */
	Class privacyClass = ClassOrThrow(@"MTRGPrivacy");

	SEL consentSel = SelectorForClassOrThrow(@"setCcpaUserConsent:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, hasCcpaConsent);
}

@end
