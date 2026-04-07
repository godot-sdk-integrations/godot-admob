//
// © 2026-present https://github.com/cengiz-pz
//

#pragma once

#import <Foundation/Foundation.h>

#include "core/variant/variant.h"

/// Factory methods that construct Godot Dictionary / Array values so every
/// unit-test file shares one canonical source of test data instead of
/// duplicating boilerplate.
@interface AdmobTestFixtures : NSObject

// -- Load-ad-request dictionaries --------------------------------------------

/// Minimal ad-request dictionary: ad_unit_id only.
+ (Dictionary)makeLoadAdRequestDictWithUnit:(NSString *)adUnitId;

/// Full banner ad-request dictionary (ad_unit_id + ad_size + ad_position).
+ (Dictionary)makeLoadAdRequestDictWithUnit:(NSString *)adUnitId
                                     adSize:(NSString *)adSize
                                 adPosition:(NSString *)adPosition;

/// Ad-request dictionary with collapsible_position set.
+ (Dictionary)makeCollapsibleAdRequestDictWithUnit:(NSString *)adUnitId
                                 collapsiblePosition:(NSString *)position;

/// Rewarded ad-request dictionary with user_id and custom_data.
+ (Dictionary)makeRewardedAdRequestDictWithUnit:(NSString *)adUnitId
                                         userId:(NSString *)userId
                                     customData:(NSString *)customData;

/// Ad-request dictionary carrying keyword array.
+ (Dictionary)makeAdRequestDictWithUnit:(NSString *)adUnitId
                               keywords:(NSArray<NSString *> *)keywords;

/// Inline-adaptive ad-request with optional maxHeight (pass 0 to omit).
+ (Dictionary)makeInlineAdaptiveAdRequestDictWithUnit:(NSString *)adUnitId
                                        adaptiveWidth:(CGFloat)width
                                            maxHeight:(CGFloat)maxHeight;

// -- AdmobConfig dictionaries ------------------------------------------------

/// Full config dictionary.
+ (Dictionary)makeConfigDictIsReal:(BOOL)isReal
                 maxAdContentRating:(NSString *)rating
           childDirectedTreatment:(int)childDirected
              underAgeOfConsent:(int)underAge
              firstPartyIdEnabled:(BOOL)firstParty
             personalizationState:(int)personalization
                    testDeviceIds:(NSArray<NSString *> *)deviceIds;

/// Minimal config dictionary (isReal only, no optional keys).
+ (Dictionary)makeMinimalConfigDictIsReal:(BOOL)isReal;

// -- ConsentInfo / UMP request parameters ------------------------------------

/// UMP request parameters dictionary (real, tagged for under-age).
+ (Dictionary)makeUmpParamsDictIsReal:(BOOL)isReal
              tagForUnderAgeOfConsent:(BOOL)underAge;

/// UMP request parameters dictionary with debug geography.
+ (Dictionary)makeUmpDebugParamsDictWithGeography:(int)geography
                              testDeviceHashedIds:(NSArray<NSString *> *)deviceIds;

// -- AdSettings dictionaries -------------------------------------------------

/// Ad-settings dictionary with all three fields set.
+ (Dictionary)makeAdSettingsDictWithVolume:(float)volume
                                     muted:(BOOL)muted
                            applyAtStartup:(BOOL)apply;

// -- Server-side verification dictionaries -----------------------------------

+ (Dictionary)makeSsvDictWithUserId:(NSString *)userId customData:(NSString *)customData;

// -- Generic helpers ---------------------------------------------------------

/// Builds a Godot String array from an NSArray of NSString objects.
+ (Array)makeGodotStringArray:(NSArray<NSString *> *)strings;

@end
