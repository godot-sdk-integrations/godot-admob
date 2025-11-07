//
// © 2024-present https://github.com/cengiz-pz
//

#import "inmobi_mediation_network.h"

@implementation InmobiMediationNetwork

static NSString *_TAG = @"inmobi";
static NSString *const ADAPTER_CLASS = @"GADMediationAdapterInMobi";

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
	 * NSMutableDictionary *consentObject = [[NSMutableDictionary alloc] init];
	 * [consentObject setObject:@"1" forKey:@"gdpr"];
	 * [consentObject setObject:@"true" forKey:IM_GDPR_CONSENT_AVAILABLE];
	 * [GADMInMobiConsent updateGDPRConsent:consentObject];
	 */
	Class consentClass = ClassOrThrow(@"GADMInMobiConsent");
	Class constantsClass = ClassOrThrow(@"InMobiSDK.IMCommonConstants");

	id consentDict = [[NSMutableDictionary alloc] init];
	[consentDict setValue:(hasGdprConsent ? @"1" : @"0") forKey:@"gdpr"];
	NSString *key = (NSString*) ClassValueOrThrow(constantsClass, @"IM_GDPR_CONSENT_AVAILABLE");
	[consentDict setValue:@"true" forKey:key];

	SEL updateSel = SelectorForClassOrThrow(@"updateGDPRConsent:", consentClass);
	((void (*)(id, SEL, id))objc_msgSend)(consentClass, updateSel, consentDict);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	// In version 10.5.6.0, the InMobi adapter added support to read IAB U.S. Privacy string from NSUserDefaults.
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

@end
