//
// © 2024-present https://github.com/cengiz-pz
//

#import "privacy_settings.h"

#import "mediation_network.h"
#import "mediation_network_factory.h"
#import "gap_converter.h"
#import "admob_logger.h"
#import <objc/message.h>


static NSString *const LOG_TAG = @"godot::AdmobPlugin::PrivacySettings";

const String HAS_GDPR_CONSENT_PROPERTY = "has_gdpr_consent";
const String IS_AGE_RESTRICTED_USER_PROPERTY = "is_age_restricted_user";
const String HAS_CCPA_SALE_CONSENT_PROPERTY = "has_ccpa_sale_consent";
const String ENABLED_NETWORKS_PROPERTY = "enabled_networks";

@implementation PrivacySettings

- (instancetype) initWithDictionary:(Dictionary) rawData {
	if ((self = [super init])) {
		self.rawData = rawData;
	}
	return self;
}

- (void) applyPrivacySettings {
	os_log_debug(admob_log, "%@:: applyPrivacySettings()", LOG_TAG);
	Array enabledNetworksArray = [self enabledNetworks];
	os_log_debug(admob_log, "%@:: Found %d enabled networks to process", LOG_TAG, enabledNetworksArray.size());

	for (NSUInteger i = 0; i < enabledNetworksArray.size(); ++i) {
		NSString *networkTag = [GAPConverter toNsString:enabledNetworksArray[i]];
		MediationNetwork *network = [MediationNetworkFactory createNetwork:networkTag];
		if (!network) {
			NSLog(@"%@:: Mediation network not found for network tag '%@'", LOG_TAG, networkTag);
		} else {
			[network applyPrivacySettings:self];
		}
	}
}

// Predicates

- (BOOL)containsGdprConsentData {
	return self.rawData.has(HAS_GDPR_CONSENT_PROPERTY);
}


- (BOOL)containsAgeRestrictedUserData {
	return self.rawData.has(IS_AGE_RESTRICTED_USER_PROPERTY);
}


- (BOOL)containsCcpaSaleConsentData {
	return self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY);
}

// Getters

- (BOOL) hasGdprConsent {
	return self.rawData[HAS_GDPR_CONSENT_PROPERTY];
}

- (BOOL) isAgeRestrictedUser {
	return self.rawData[IS_AGE_RESTRICTED_USER_PROPERTY];
}

- (BOOL) hasCcpaSaleConsent {
	return self.rawData[HAS_CCPA_SALE_CONSENT_PROPERTY];
}

- (Array) enabledNetworks {
	return self.rawData.has(ENABLED_NETWORKS_PROPERTY) ? (Array) self.rawData[ENABLED_NETWORKS_PROPERTY] : Array();
}

@end
