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

// Network-Specific
- (void) applyApplovinSettings;
- (void) applyChartboostSettings;
- (void) applyDtexchangeSettings;
- (void) applyImobileSettings;
- (void) applyInmobiSettings;
- (void) applyIronsourceSettings;
- (void) applyLiftoffSettings;
- (void) applyLineSettings;
- (void) applyMaioSettings;
- (void) applyMetaSettings;
- (void) applyMintegralSettings;
- (void) applyMolocoSettings;
- (void) applyMytargetSettings;
- (void) applyPangleSettings;
- (void) applyUnitySettings;

@end

#endif /* privacy_settings_h */
