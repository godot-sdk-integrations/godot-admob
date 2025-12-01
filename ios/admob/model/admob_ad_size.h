//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_ad_size_h
#define admob_ad_size_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"


@interface AdmobAdSize : NSObject

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

/**
 * Initializes the ad size wrapper with the Google Mobile Ads size object
 * @param adSize The GADAdSize object from the Google Mobile Ads SDK
 */
- (instancetype) initWithAdSize:(GADAdSize) adSize;

/**
 * Builds a Godot-compatible Dictionary containing the ad size data
 * @return A Dictionary object with the size details
 */
- (Dictionary) buildRawData;

@end

#endif /* admob_ad_size_h */
