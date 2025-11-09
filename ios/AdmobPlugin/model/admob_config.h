//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_config_h
#define admob_config_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"


@interface AdmobConfig : NSObject

@property (nonatomic, assign) Dictionary rawData;

- (instancetype) initWithDictionary:(Dictionary) rawData;

- (BOOL) isReal;
- (NSString*) maxContentRating;
- (NSNumber*) childDirectedTreatment;
- (NSNumber*) underAgeOfConsent;
- (BOOL) firstPartyIdEnabled;
- (NSNumber*) personalizationState;
- (NSArray*) testDeviceIds;

- (void) applyToGADRequestConfiguration:(GADRequestConfiguration*) requestConfiguration;

@end

#endif /* admob_config_h */
