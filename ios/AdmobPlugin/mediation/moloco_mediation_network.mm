//
// © 2024-present https://github.com/cengiz-pz
//

#import "moloco_mediation_network.h"

@implementation MolocoMediationNetwork

static NSString *_TAG = @"moloco";
static NSString *const ADAPTER_CLASS = @"MolocoMediationAdapter";

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
	 * [MolocoPrivacySettings setHasUserConsent:YES];
	 */
	Class privacyClass = ClassOrThrow(@"MolocoSDK.MolocoPrivacySettings");

	SEL consentSel = SelectorForClassOrThrow(@"setHasUserConsent:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, hasGdprConsent);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [MolocoPrivacySettings setIsDoNotSell:NO];
	 */
	Class privacyClass = ClassOrThrow(@"MolocoSDK.MolocoPrivacySettings");

	SEL dntSel = SelectorForClassOrThrow(@"setIsDoNotSell:", privacyClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, dntSel, !hasCcpaConsent);
}

@end
