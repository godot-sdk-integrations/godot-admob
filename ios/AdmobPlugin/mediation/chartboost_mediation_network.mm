//
// © 2024-present https://github.com/cengiz-pz
//

#import "chartboost_mediation_network.h"

@implementation ChartboostMediationNetwork

static NSString *const _TAG = @"chartboost";
static NSString *const _ADAPTER_CLASS = @"GADMediationAdapterChartboost";

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
	 * CHBGDPRDataUseConsent *dataUseConsent = [CHBGDPRDataUseConsent gdprConsent:CHBGDPRConsentNonBehavioral];
	 * [Chartboost addDataUseConsent:dataUseConsent];
	 */
	Class chartboostClass = ClassOrThrow(@"Chartboost");
	Class gdprConsentClass = ClassOrThrow(@"CHBGDPRDataUseConsent");

	// Enum constants are compile-time ints, so we hardcode the values
	NSUInteger nonBehavioralValue = 0; // User does not consent to behavioral targeting (GDPR)
	NSUInteger behavioralValue = 1; // User consents to behavioral targeting (GDPR)

	id consent = ((id (*)(id, SEL, NSUInteger))objc_msgSend)(
		gdprConsentClass,
		SelectorOrThrow(@"gdprConsent:"),
		hasGdprConsent ? behavioralValue : nonBehavioralValue
	);

	((void (*)(id, SEL, id))objc_msgSend)(
		chartboostClass,
		SelectorOrThrow(@"addDataUseConsent:"),
		consent
	);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * CHBCCPADataUseConsent *dataUseConsent = [CHBCCPADataUseConsent ccpaConsent:CHBCCPAConsentOptInSale];
	 * [Chartboost addDataUseConsent:dataUseConsent];
	 */
	Class chartboostClass = ClassOrThrow(@"Chartboost");
	Class ccpaConsentClass = ClassOrThrow(@"CHBCCPADataUseConsent");

	// Enum constants are compile-time ints, so we hardcode the values
	NSUInteger optOutSaleValue = 0; // User does not consent to the sale of personal information (CCPA)
	NSUInteger optInSaleValue = 1; // User consents to the sale of personal information (CCPA)

	id consent = ((id (*)(id, SEL, NSUInteger))objc_msgSend)(
		ccpaConsentClass,
		SelectorOrThrow(@"ccpaConsent:"),
		hasCcpaConsent ? optInSaleValue : optOutSaleValue
	);

	((void (*)(id, SEL, id))objc_msgSend)(
		chartboostClass,
		SelectorOrThrow(@"addDataUseConsent:"),
		consent
	);
}

@end
