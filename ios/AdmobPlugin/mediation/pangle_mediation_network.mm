//
// © 2024-present https://github.com/cengiz-pz
//

#import "pangle_mediation_network.h"

@implementation PangleMediationNetwork

static NSString *_TAG = @"pangle";
static NSString *const ADAPTER_CLASS = @"GADMediationAdapterPangle";

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
	 * [GADMediationAdapterPangle setGDPRConsent:PAGGDPRConsentTypeConsent];
	 */
	Class adapterClass = ClassOrThrow(ADAPTER_CLASS);

	int consentValue = hasGdprConsent ? 1 : 0;

	SEL gdprSel = SelectorForClassOrThrow(@"setGDPRConsent:", adapterClass);
	((void (*)(id, SEL, int))objc_msgSend)(adapterClass, gdprSel, consentValue);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [GADMediationAdapterPangle setPAConsent:PAGPAConsentTypeConsent];
	 */
	Class adapterClass = ClassOrThrow(ADAPTER_CLASS);

	int consentValue = hasCcpaConsent ? 1 : 0;

	SEL paSel = SelectorForClassOrThrow(@"setPAConsent:", adapterClass);
	((void (*)(id, SEL, int))objc_msgSend)(adapterClass, paSel, consentValue);
}

@end
