//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef privacy_settings_h
#define privacy_settings_h

#import <Foundation/Foundation.h>

#include "core/object/class_db.h"


@interface PrivacySettings : NSObject

@property (nonatomic, assign) Dictionary rawData;

- (instancetype) initWithDictionary:(Dictionary) rawData;

- (void) applyPrivacySettings;

- (BOOL)containsGdprConsentData;

- (BOOL)containsAgeRestrictedUserData;

- (BOOL)containsCcpaSaleConsentData;

- (BOOL) hasGdprConsent;

- (BOOL) isAgeRestrictedUser;

- (BOOL) hasCcpaSaleConsent;

@end

#endif /* privacy_settings_h */
