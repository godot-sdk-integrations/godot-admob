//
// © 2026-present https://github.com/cengiz-pz
//

#ifndef ad_settings_wrapper_h
#define ad_settings_wrapper_h

#import <Foundation/Foundation.h>

#include "core/object/object.h"
#include "core/object/class_db.h"

#import "admob_plugin-Swift.h"

@interface AdSettingsWrapper : NSObject

- (instancetype)init;
- (instancetype)initWithData:(Dictionary)data;
- (instancetype)initWithAdSettings:(AdSettings *)adSettings;

- (NSNumber *)getAdVolume;
- (void)setAdVolume:(NSNumber *)volume;

- (BOOL)areAdsMuted;
- (void)setAdsMuted:(BOOL)muted;

- (BOOL)getApplyAtStartup;
- (void)setApplyAtStartup:(BOOL)apply;

- (AdSettings *)createAdSettings;

- (Dictionary)getRawData;

@end

#endif /* ad_settings_wrapper_h */
