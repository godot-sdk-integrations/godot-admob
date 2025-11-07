//
// © 2024-present https://github.com/cengiz-pz
//

#import "dtexchange_mediation_network.h"

@implementation DtexchangeMediationNetwork

static NSString *_TAG = @"dtexchange";
static NSString *const ADAPTER_CLASS = @"GADMediationAdapterFyber";

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
	 * [IASDKCore.sharedInstance setGDPRConsent:YES];
	 */
	Class sdkClass = ClassOrThrow(@"IASDKCore");
	SEL sharedSel = SelectorForClassOrThrow(@"sharedInstance", sdkClass);

	id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
	SEL gdprSel = SelectorForClassOrThrow(@"setGDPRConsent:", sdk);
	((void (*)(id, SEL, BOOL))objc_msgSend)(sdk, gdprSel, hasGdprConsent);
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Not supported" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	/*
	 * [IASDKCore.sharedInstance setCCPAString:@"myCCPAConsentString"];
	 */
	Class sdkClass = ClassOrThrow(@"IASDKCore");
	SEL sharedSel = SelectorForClassOrThrow(@"sharedInstance", sdkClass);

	id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);

	// "1---": CCPA does not apply, for example, the user is not a California resident
	// "1YNN": User does NOT opt out, ad experience continues
	// "1YYN": User opts out of targeted advertising
	NSString *privacyString = [NSString stringWithFormat:@"1Y%@N", hasCcpaConsent ? @"N" : @"Y"];

	[sdk setValue:privacyString forKey:@"CCPAString"];
}

@end
