//
// © 2024-present https://github.com/cengiz-pz
//

#import "unity_mediation_network.h"

@implementation UnityMediationNetwork

static NSString *const _TAG = @"unity";
static NSString *const _ADAPTER_CLASS = @"GADMediationAdapterUnity";

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
	 * UADSMetaData *gdprMetaData = [[UADSMetaData alloc] init];
	 * [gdprMetaData set:@"gdpr.consent" value:@YES];
	 * [gdprMetaData commit];
	 */
	Class metaClass = ClassOrThrow(@"UADSMetaData");

	/* UADSMetaData is an *instance* class – allocate + init */
	id metaData = ((id (*)(id, SEL))objc_msgSend)(((id (*)(id, SEL))objc_msgSend)(metaClass, SelectorOrThrow(@"alloc")), SelectorOrThrow(@"init"));
	SEL setSel = SelectorOrThrow(@"set:value:");

	((void (*)(id, SEL, id, id))objc_msgSend)(metaData, setSel, @"gdpr.consent", @(hasGdprConsent));

	((void (*)(id, SEL))objc_msgSend)(metaData, SelectorOrThrow(@"commit"));
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * UADSMetaData *ccpaMetaData = [[UADSMetaData alloc] init];
	 * [ccpaMetaData set:@"privacy.consent" value:@YES];
	 * [ccpaMetaData commit];
	 */
	Class metaClass = ClassOrThrow(@"UADSMetaData");

	/* UADSMetaData is an *instance* class – allocate + init */
	id metaData = ((id (*)(id, SEL))objc_msgSend)(((id (*)(id, SEL))objc_msgSend)(metaClass, SelectorOrThrow(@"alloc")), SelectorOrThrow(@"init"));

	SEL setSel = SelectorOrThrow(@"set:value:");

	((void (*)(id, SEL, id, id))objc_msgSend)(metaData, setSel, @"privacy.consent", @(hasCcpaConsent));

	((void (*)(id, SEL))objc_msgSend)(metaData, SelectorOrThrow(@"commit"));
}

@end
