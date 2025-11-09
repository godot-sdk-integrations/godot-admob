//
// © 2024-present https://github.com/cengiz-pz
//

#import "ironsource_mediation_network.h"

@implementation IronsourceMediationNetwork

static NSString *const _TAG = @"ironsource";
static NSString *const _ADAPTER_CLASS = @"GADMediationAdapterIronSource";

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
	 * [LevelPlay setConsent:YES];
	 */
	Class levelPlayClass = ClassOrThrow(@"LevelPlay");

	SEL consentSel = SelectorForClassOrThrow(@"setConsent:", levelPlayClass);
	((void (*)(id, SEL, BOOL))objc_msgSend)(levelPlayClass, consentSel, hasGdprConsent);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [LevelPlay setMetaDataWithKey:@"do_not_sell" value:@"NO"];
	 */
	Class levelPlayClass = ClassOrThrow(@"LevelPlay");

	SEL metaSel = SelectorForClassOrThrow(@"setMetaDataWithKey:value:", levelPlayClass);
	NSString *value = hasCcpaConsent ? @"YES" : @"NO";
	((void (*)(id, SEL, id, id))objc_msgSend)(levelPlayClass, metaSel, @"do_not_sell", value);
}

@end
