//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_config.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdSupport/AdSupport.h>

#import "gap_converter.h"


const String IS_REAL_PROPERTY = "is_real";
const String MAX_AD_CONTENT_RATING_PROPERTY = "max_ad_content_rating";
const String CHILD_DIRECTED_TREATMENT_PROPERTY = "tag_for_child_directed_treatment";
const String UNDER_AGE_OF_CONSENT_PROPERTY = "tag_for_under_age_of_consent";
const String FIRST_PARTY_ID_ENABLED_PROPERTY = "first_party_id_enabled";
const String PERSONALIZATION_STATE_PROPERTY = "personalization_state";
const String TEST_DEVICE_IDS_PROPERTY = "test_device_ids";


@implementation AdmobConfig

- (instancetype) initWithDictionary:(Dictionary) rawData {
	if ((self = [super init])) {
		self.rawData = rawData;
	}
	return self;
}

- (BOOL) isReal {
	return self.rawData[IS_REAL_PROPERTY];
}

- (NSString*) maxContentRating {
	return [GAPConverter toNsString:(String) self.rawData[MAX_AD_CONTENT_RATING_PROPERTY]];
}

- (NSNumber*) childDirectedTreatment {
	NSNumber* value;
	if (self.rawData.has(CHILD_DIRECTED_TREATMENT_PROPERTY)) {
		int property = self.rawData[CHILD_DIRECTED_TREATMENT_PROPERTY];
		if (property == 1) {
			value = @YES;
		} else if (property == 0) {
			value = @NO;
		} else {
			value = nil;  // unspecified
		}
	} else {
		value = nil;	// unspecified
	}
	return value;
}

- (NSNumber*) underAgeOfConsent {
	NSNumber* value;
	if (self.rawData.has(UNDER_AGE_OF_CONSENT_PROPERTY)) {
		int property = self.rawData[UNDER_AGE_OF_CONSENT_PROPERTY];
		if (property == 1) {
			value = @YES;
		} else if (property == 0) {
			value = @NO;
		} else {
			value = nil;  // unspecified
		}
	} else {
		value = nil;	// unspecified
	}
	return value;
}

- (BOOL) firstPartyIdEnabled {
	return self.rawData[FIRST_PARTY_ID_ENABLED_PROPERTY];
}

- (NSNumber*) personalizationState {
	return [NSNumber numberWithInt: self.rawData[PERSONALIZATION_STATE_PROPERTY]];
}

- (NSArray*) testDeviceIds {
	if (self.rawData.has(TEST_DEVICE_IDS_PROPERTY)) {
		return [GAPConverter toNsStringArray:(Array) self.rawData[TEST_DEVICE_IDS_PROPERTY]];
	} else {
		return @[];
	}
}

- (void) applyToGADRequestConfiguration:(GADRequestConfiguration *)config {
	// Content rating
	if ([self maxContentRating]) {
		config.maxAdContentRating = [self maxContentRating];
	}

	// Child-directed treatment
	if ([self childDirectedTreatment] != nil) {
		config.tagForChildDirectedTreatment = [self childDirectedTreatment];
	}

	// Under age of consent
	if ([self underAgeOfConsent] != nil) {
		config.tagForUnderAgeOfConsent = [self underAgeOfConsent];
	}

	// First-party ID
	config.publisherFirstPartyIDEnabled = [self firstPartyIdEnabled];

	// Personalization state
	config.publisherPrivacyPersonalizationState =
		[GAPConverter intToPublisherPrivacyPersonalizationState:[self personalizationState]];

	// --- Test Device IDs ---
	NSMutableArray<NSString *> *testDeviceIds = [config.testDeviceIdentifiers mutableCopy] ?: [NSMutableArray array];

	if (![self isReal]) {
		// 1. Real device advertising ID (if authorized)
		NSString *advertisingId = nil;
		NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];

		if (@available(iOS 14.0, *)) {
			if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized &&
				![idfa.UUIDString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
				advertisingId = idfa.UUIDString;
			}
		} else {
			if (![idfa.UUIDString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
				advertisingId = idfa.UUIDString;
			}
		}

		if (advertisingId) {
			[testDeviceIds addObject:advertisingId];
		}

		// 2. Hashed device ID (fallback)
		[testDeviceIds addObject:[GAPConverter getAdmobDeviceID]];
	}

	// 3. User-provided test device IDs
	NSArray *userTestIds = [self testDeviceIds];
	if (userTestIds.count > 0) {
		[testDeviceIds addObjectsFromArray:userTestIds];
	}

	if (testDeviceIds.count > 0) {
		config.testDeviceIdentifiers = [testDeviceIds copy];
	}
}

@end
