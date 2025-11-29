//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_status_h
#define admob_status_h

#import <Foundation/Foundation.h>

#include "core/object/class_db.h"

@import GoogleMobileAds;


/**
 * @brief Represents the initialization status data received from the Mobile Ads SDK.
 *
 * This class mirrors the Java implementation by processing the AdMob initialization
 * status map and preparing it for use in Godot (via a Dictionary).
 */
@interface AdmobStatus : NSObject

/** Key for the adapter class name in the status dictionary. */
extern String const kAdmobAdapterClassProperty;
/** Key for the initialization latency in the status dictionary. */
extern String const kAdmobLatencyProperty;
/** Key for the initialization state (NOT_READY/READY/INVALID) in the status dictionary. */
extern String const kAdmobInitializationStateProperty;
/** Key for the adapter description in the status dictionary. */
extern String const kAdmobDescriptionProperty;


@property (nonatomic, strong, readonly) GADInitializationStatus *status;


/**
 * @brief Initializes the status object with the raw AdMob initialization status.
 *
 * @param status The platform-specific initialization status object (e.g., GADInitializationStatus).
 * @return An initialized AdmobStatus object.
 */
- (instancetype)initWithStatus:(GADInitializationStatus*)status;

/**
 * @brief Processes the raw status data into a Dictionary suitable for Godot.
 *
 * @return A GodotDictionary containing the structured initialization status data.
 */
- (Dictionary)buildRawData;

// Helper method to convert the status enum to a string.
+ (NSString *)adapterStatusToString:(GADAdapterInitializationState)adapterInitializationState;

@end

#endif /* admob_status_h */
