//
// © 2024-present https://github.com/cengiz-pz
//

#import "privacy_settings.h"

#import "gap_converter.h"
#import "admob_logger.h"
#import <objc/message.h>

// Replace the macro with an inline function to avoid ARC retain warnings
static inline Class ClassOrLog(NSString *className) {
    Class c = NSClassFromString(className);
    if (!c) os_log_debug(admob_log, "Class %@ not found", className);
    return c;
}

typedef void (^PrivacySetter)(PrivacySettings *instance);

static NSDictionary<NSString *, PrivacySetter> *PrivacySetters;

__attribute__((constructor))
static void initializePrivacySetters(void) {
	PrivacySetters = @{
		@"applovin": ^(PrivacySettings *instance) { [instance applyApplovinSettings]; },
		@"chartboost": ^(PrivacySettings *instance) { [instance applyChartboostSettings]; },
		@"dtexchange": ^(PrivacySettings *instance) { [instance applyDtexchangeSettings]; },
		@"imobile": ^(PrivacySettings *instance) { [instance applyImobileSettings]; },
		@"inmobi": ^(PrivacySettings *instance) { [instance applyInmobiSettings]; },
		@"ironsource": ^(PrivacySettings *instance) { [instance applyIronsourceSettings]; },
		@"liftoff": ^(PrivacySettings *instance) { [instance applyLiftoffSettings]; },
		@"line": ^(PrivacySettings *instance) { [instance applyLineSettings]; },
		@"maio": ^(PrivacySettings *instance) { [instance applyMaioSettings]; },
		@"meta": ^(PrivacySettings *instance) { [instance applyMetaSettings]; },
		@"mintegral": ^(PrivacySettings *instance) { [instance applyMintegralSettings]; },
		@"moloco": ^(PrivacySettings *instance) { [instance applyMolocoSettings]; },
		@"mytarget": ^(PrivacySettings *instance) { [instance applyMytargetSettings]; },
		@"pangle": ^(PrivacySettings *instance) { [instance applyPangleSettings]; },
		@"unity": ^(PrivacySettings *instance) { [instance applyUnitySettings]; }
	};
}

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
	Array enabledNetworksArray = [self enabledNetworks];
	os_log_debug(admob_log, "Found %d enabled networks to process", enabledNetworksArray.size());

	for (NSUInteger i = 0; i < enabledNetworksArray.size(); ++i) {
		NSString *network = [GAPConverter toNsString:enabledNetworksArray[i]];
		PrivacySetter setter = PrivacySetters[network];
		if (setter) {
			setter(self);
		} else {
			os_log_info(admob_log, "Privacy setter not found for network '%@'", network);
		}
	}
}

// Network-Specific Setters

- (void) applyApplovinSettings {
	os_log_debug(admob_log, "Applying privacy settings for AppLovin");

	Class privacyClass = ClassOrLog(@"ALPrivacySettings");
	if (privacyClass) {
		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			SEL consentSel = NSSelectorFromString(@"setHasUserConsent:");
			if ([privacyClass respondsToSelector:consentSel]) {
				((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, [self hasGdprConsent]);
			} else {
				os_log_error(admob_log, "Could not find ALPrivacySettings:setHasUserConsent:");
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			SEL doNotSellSel = NSSelectorFromString(@"setDoNotSell:");
			if ([privacyClass respondsToSelector:doNotSellSel]) {
				((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, doNotSellSel, [self hasCcpaSaleConsent]);
			} else {
				os_log_error(admob_log, "Could not find ALPrivacySettings:setDoNotSell:");
			}
		}
	} else {
		os_log_error(admob_log, "ALPrivacySettings class not found!");
	}
}

- (void) applyChartboostSettings {
	os_log_debug(admob_log, "Applying privacy settings for Chartboost");

	Class chartboostClass = ClassOrLog(@"Chartboost");
	if (chartboostClass) {
		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			Class gdprConsentClass = ClassOrLog(@"CHBGDPRDataUseConsent");
			if (gdprConsentClass) {
				@try {
					// Enum constants are compile-time ints, so we hardcode the values
					NSUInteger nonBehavioralValue = 0; // User does not consent to behavioral targeting (GDPR)
					NSUInteger behavioralValue = 1; // User consents to behavioral targeting (GDPR)

					id consent = ((id (*)(id, SEL, NSUInteger))objc_msgSend)(
						gdprConsentClass,
						NSSelectorFromString(@"gdprConsent:"),
						[self hasGdprConsent] ? behavioralValue : nonBehavioralValue
					);

					((void (*)(id, SEL, id))objc_msgSend)(
						chartboostClass,
						NSSelectorFromString(@"addDataUseConsent:"),
						consent
					);
				} @catch (NSException *e) {
					os_log_error(admob_log, "Failed to set Chartboost GDPR consent: %@ — %@", e.name, e.reason);
				}
			} else {
				os_log_error(admob_log, "CHBGDPRDataUseConsent class not found!");
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			Class ccpaConsentClass = ClassOrLog(@"CHBCCPADataUseConsent");
			if (ccpaConsentClass) {
				@try {
					// Enum constants are compile-time ints, so we hardcode the values
					NSUInteger optOutSaleValue = 0; // User does not consent to the sale of personal information (CCPA)
					NSUInteger optInSaleValue = 1; // User consents to the sale of personal information (CCPA)

					id consent = ((id (*)(id, SEL, NSUInteger))objc_msgSend)(
						ccpaConsentClass,
						NSSelectorFromString(@"ccpaConsent:"),
						[self hasCcpaSaleConsent] ? optInSaleValue : optOutSaleValue
					);

					((void (*)(id, SEL, id))objc_msgSend)(
						chartboostClass,
						NSSelectorFromString(@"addDataUseConsent:"),
						consent
					);
				} @catch (NSException *e) {
					os_log_error(admob_log, "Failed to set Chartboost CCPA consent: %@ — %@", e.name, e.reason);
				}
			} else {
				os_log_error(admob_log, "CHBCCPADataUseConsent class not found!");
			}
		}
	} else {
		os_log_error(admob_log, "Chartboost class not found!");
	}
}

- (void) applyDtexchangeSettings {
	os_log_debug(admob_log, "Applying privacy settings for DT Exchange");

	Class sdkClass = ClassOrLog(@"IASDKCore");
	if (sdkClass) {
		SEL sharedSel = NSSelectorFromString(@"sharedInstance");

		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			@try {
				if ([sdkClass respondsToSelector:sharedSel]) {
					id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
					SEL gdprSel = NSSelectorFromString(@"setGDPRConsent:");
					if ([sdk respondsToSelector:gdprSel]) {
						((void (*)(id, SEL, BOOL))objc_msgSend)(sdk, gdprSel, [self hasGdprConsent]);
					}
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set IASDKCore GDPR consent: %@ — %@", e.name, e.reason);
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				if ([sdkClass respondsToSelector:sharedSel]) {
					id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
					[sdk setValue:@"1YNN" forKey:@"CCPAString"];
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set IASDKCore CCPAString: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "IASDKCore class not found!");
	}
}

- (void) applyImobileSettings {
	os_log_info(admob_log, "Privacy settings are not applicable for Imobile");
}

- (void) applyInmobiSettings {
	os_log_debug(admob_log, "Applying privacy settings for InMobi");

	if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY) && [self hasGdprConsent]) {
		@try {
			Class consentClass = ClassOrLog(@"GADMInMobiConsent");
			if (consentClass) {
				Class constantsClass = ClassOrLog(@"InMobiSDK.IMCommonConstants");
				if (constantsClass) {
					id consentDict = [[NSMutableDictionary alloc] init];
					[consentDict setValue:@"1" forKey:@"gdpr"];
					NSString *key = [constantsClass valueForKey:@"IM_GDPR_CONSENT_AVAILABLE"];
					if (key) [consentDict setValue:@"true" forKey:key];

					SEL updateSel = NSSelectorFromString(@"updateGDPRConsent:");
					if ([consentClass respondsToSelector:updateSel]) {
						((void (*)(id, SEL, id))objc_msgSend)(consentClass, updateSel, consentDict);
					}
				} else {
					os_log_error(admob_log, "InMobiSDK.IMCommonConstants class not found!");
				}
			} else {
				os_log_error(admob_log, "GADMInMobiConsent class not found!");
			}
		} @catch (NSException *e) {
			os_log_error(admob_log, "Failed to update InMobi GDPR consent: %@ — %@", e.name, e.reason);
		}
	}
}

- (void) applyIronsourceSettings {
	os_log_debug(admob_log, "Applying privacy settings for ironSource");

	Class levelPlayClass = ClassOrLog(@"LevelPlay");
	if (levelPlayClass) {
		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			@try {
				SEL consentSel = NSSelectorFromString(@"setConsent:");
				if ([levelPlayClass respondsToSelector:consentSel]) {
					((void (*)(id, SEL, BOOL))objc_msgSend)(levelPlayClass, consentSel, [self hasGdprConsent]);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set LevelPlay GDPR consent: %@ — %@", e.name, e.reason);
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				SEL metaSel = NSSelectorFromString(@"setMetaDataWithKey:value:");
				if ([levelPlayClass respondsToSelector:metaSel]) {
					NSString *value = [self hasCcpaSaleConsent] ? @"YES" : @"NO";
					((void (*)(id, SEL, id, id))objc_msgSend)(levelPlayClass, metaSel, @"do_not_sell", value);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set LevelPlay CCPA meta data: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "LevelPlay class not found!");
	}
}

- (void) applyLiftoffSettings {
	os_log_debug(admob_log, "Applying privacy settings for Liftoff Monetize");

	Class vungleClass = ClassOrLog(@"VungleAdsSDK.VunglePrivacySettings");
	if (vungleClass) {
		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				SEL ccpaSel = NSSelectorFromString(@"setCCPAStatus:");
				if ([vungleClass respondsToSelector:ccpaSel]) {
					((void (*)(id, SEL, BOOL))objc_msgSend)(vungleClass, ccpaSel, [self hasCcpaSaleConsent]);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Liftoff Monetize consent: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "VungleAdsSDK.VunglePrivacySettings class not found!");
	}
}

- (void) applyLineSettings {
	os_log_info(admob_log, "Privacy settings are not applicable for Line");
}

- (void) applyMaioSettings {
	os_log_info(admob_log, "Privacy settings are not applicable for Maio");
}

- (void) applyMetaSettings {
	os_log_info(admob_log, "Privacy settings are not applicable for Meta");
}

- (void) applyMintegralSettings {
	os_log_debug(admob_log, "Applying privacy settings for Mintegral");

	Class sdkClass = ClassOrLog(@"MTGSDK");
	if (sdkClass) {
		SEL sharedSel = NSSelectorFromString(@"sharedInstance");

		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			@try {
				if ([sdkClass respondsToSelector:sharedSel]) {
					id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
					SEL consentSel = NSSelectorFromString(@"setConsentStatus:");
					if ([sdk respondsToSelector:consentSel]) {
						((void (*)(id, SEL, BOOL))objc_msgSend)(sdk, consentSel, [self hasGdprConsent]);
					}
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Mintegral GDPR consent status: %@ — %@", e.name, e.reason);
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				if ([sdkClass respondsToSelector:sharedSel]) {
					id sdk = ((id (*)(id, SEL))objc_msgSend)(sdkClass, sharedSel);
					SEL dntSel = NSSelectorFromString(@"setDoNotTrackStatus:");
					if ([sdk respondsToSelector:dntSel]) {
						((void (*)(id, SEL, BOOL))objc_msgSend)(sdk, dntSel, ![self hasCcpaSaleConsent]);
					}
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Mintegral CCPA consent status: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "MTGSDK class not found!");
	}
}

- (void) applyMolocoSettings {
	os_log_debug(admob_log, "Applying privacy settings for Moloco");

	Class privacyClass = ClassOrLog(@"MolocoSDK.MolocoPrivacySettings");
	if (privacyClass) {
		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			@try {
				SEL consentSel = NSSelectorFromString(@"setHasUserConsent:");
				if ([privacyClass respondsToSelector:consentSel]) {
					((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, [self hasGdprConsent]);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Moloco GDPR consent: %@ — %@", e.name, e.reason);
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				SEL dntSel = NSSelectorFromString(@"setIsDoNotSell:");
				if ([privacyClass respondsToSelector:dntSel]) {
					((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, dntSel, ![self hasCcpaSaleConsent]);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Moloco CCPA consent: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "MolocoSDK.MolocoPrivacySettings class not found!");
	}
}

- (void) applyMytargetSettings {
	os_log_debug(admob_log, "Applying privacy settings for myTarget");

	Class privacyClass = ClassOrLog(@"MTRGPrivacy");
	if (privacyClass) {
		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			@try {
				SEL consentSel = NSSelectorFromString(@"setUserConsent:");
				if ([privacyClass respondsToSelector:consentSel]) {
					((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, consentSel, [self hasGdprConsent]);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set myTarget GDPR consent: %@ — %@", e.name, e.reason);
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				SEL ageSel = NSSelectorFromString(@"setUserAgeRestricted:");
				if ([privacyClass respondsToSelector:ageSel]) {
					((void (*)(id, SEL, BOOL))objc_msgSend)(privacyClass, ageSel, [self isAgeRestrictedUser]);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set myTarget restricted user status: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "MTRGPrivacy class not found!");
	}
}

- (void) applyPangleSettings {
	os_log_debug(admob_log, "Applying privacy settings for Pangle");

	Class adapterClass = ClassOrLog(@"GADMediationAdapterPangle");
	if (adapterClass) {
		if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
			@try {
				Class consentTypeClass = NSClassFromString(@"PAGGDPRConsentType");
				id consentValue = [self hasGdprConsent]
					? [consentTypeClass valueForKey:@"PAGGDPRConsentTypeConsent"]
					: [consentTypeClass valueForKey:@"PAGGDPRConsentTypeNoConsent"];

				SEL gdprSel = NSSelectorFromString(@"setGDPRConsent:");
				if (consentValue && [adapterClass respondsToSelector:gdprSel]) {
					((void (*)(id, SEL, id))objc_msgSend)(adapterClass, gdprSel, consentValue);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Pangle GDPR consent: %@ — %@", e.name, e.reason);
			}
		}

		if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
			@try {
				Class consentTypeClass = NSClassFromString(@"PAGGDPRConsentType");
				id consentValue = [self hasCcpaSaleConsent]
					? [consentTypeClass valueForKey:@"PAGPAConsentTypeConsent"]
					: [consentTypeClass valueForKey:@"PAGPAConsentTypeNoConsent"];

				SEL paSel = NSSelectorFromString(@"setPAConsent:");
				if (consentValue && [adapterClass respondsToSelector:paSel]) {
					((void (*)(id, SEL, id))objc_msgSend)(adapterClass, paSel, consentValue);
				}
			} @catch (NSException *e) {
				os_log_error(admob_log, "Failed to set Pangle CCPA consent: %@ — %@", e.name, e.reason);
			}
		}
	} else {
		os_log_error(admob_log, "GADMediationAdapterPangle class not found!");
	}
}

- (void) applyUnitySettings {
	os_log_debug(admob_log, "Applying privacy settings for Unity");

	@try {
		Class metaClass = ClassOrLog(@"UADSMetaData");
		if (metaClass) {
			/* UADSMetaData is an *instance* class – allocate + init */
			id metaData = ((id (*)(id, SEL))objc_msgSend)(
				((id (*)(id, SEL))objc_msgSend)(metaClass, NSSelectorFromString(@"alloc")),
				NSSelectorFromString(@"init"));
			if (metaData) {
				SEL setSel = NSSelectorFromString(@"set:value:");
				BOOL doCommit = NO;

				if (self.rawData.has(HAS_GDPR_CONSENT_PROPERTY)) {
					((void (*)(id, SEL, id, id))objc_msgSend)(metaData, setSel, @"gdpr.consent", @([self hasGdprConsent]));
					doCommit = YES;
				}

				if (self.rawData.has(HAS_CCPA_SALE_CONSENT_PROPERTY)) {
					((void (*)(id, SEL, id, id))objc_msgSend)(metaData, setSel, @"privacy.consent", @([self hasCcpaSaleConsent]));
					doCommit = YES;
				}

				if (doCommit) {
					((void (*)(id, SEL))objc_msgSend)(metaData, NSSelectorFromString(@"commit"));
				}
			} else {
				os_log_error(admob_log, "Failed to create UADSMetaData instance!");
			}
		} else {
			os_log_error(admob_log, "UADSMetaData class not found!");
		}
	} @catch (NSException *e) {
		os_log_error(admob_log, "Failed to set Unity Ads privacy settings: %@ — %@", e.name, e.reason);
	}
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
