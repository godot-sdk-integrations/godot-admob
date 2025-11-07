//
// © 2024-present https://github.com/cengiz-pz
//

#import "mediation_network.h"

#import "privacy_settings.h"

static NSString *const CLASS_NAME = @"MediationNetwork";
static NSString *const LOG_TAG = @"godot::AdmobPlugin::MediationNetwork";

@implementation MediationNetwork

- (instancetype)initWithTag:(NSString *)tag {
	self = [super init];
	if (self) {
		_tag = tag;
	}
	return self;
}

- (NSString *)getAdapterClassName {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Abstract method must be overridden" userInfo:nil];
}

- (void)applyGDPRSettings:(BOOL)hasGdprConsent {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Abstract method must be overridden" userInfo:nil];
}

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Abstract method must be overridden" userInfo:nil];
}

- (void)applyCCPASettings:(BOOL)hasCcpaConsent {
	@throw [NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Abstract method must be overridden" userInfo:nil];
}

- (void)applyPrivacySettings:(PrivacySettings *)settings {
	if ([settings containsGdprConsentData]) {
		@try {
			[self applyGDPRSettings:[settings hasGdprConsent]];
			NSLog(@"%@:: GDPR consent set successfully for %@", LOG_TAG, self.tag);
		} @catch (NSException *exception) {
			if ([exception.name isEqualToString:@"UnsupportedOperationException"]) {
				NSLog(@"%@:: GDPR settings not needed by %@", LOG_TAG, self.tag);
			} else {
				NSLog(@"%@:: %@:: %@:: Failed to set GDPR settings for %@", LOG_TAG, exception.name, exception.reason, self.tag);
			}
		}
	}
	
	if ([settings containsAgeRestrictedUserData]) {
		@try {
			[self applyAgeRestrictedUserSettings:[settings isAgeRestrictedUser]];
			NSLog(@"%@:: Age-restricted user settings set successfully for %@", LOG_TAG, self.tag);
		} @catch (NSException *exception) {
			if ([exception.name isEqualToString:@"UnsupportedOperationException"]) {
				NSLog(@"%@:: Age-restricted user settings not needed by %@", LOG_TAG, self.tag);
			} else {
				NSLog(@"%@:: %@:: %@:: Failed to set age-restricted user settings for %@", LOG_TAG, exception.name, exception.reason, self.tag);
			}
		}
	}
	
	if ([settings containsCcpaSaleConsentData]) {
		@try {
			[self applyCCPASettings:[settings hasCcpaSaleConsent]];
			NSLog(@"%@:: CCPA sale consent set successfully for %@", LOG_TAG, self.tag);
		} @catch (NSException *exception) {
			if ([exception.name isEqualToString:@"UnsupportedOperationException"]) {
				NSLog(@"%@:: CCPA settings not needed by %@", LOG_TAG, self.tag);
			} else {
				NSLog(@"%@:: %@:: %@:: Failed to set CCPA settings for %@", LOG_TAG, exception.name, exception.reason, self.tag);
			}
		}
	}
}

@end
