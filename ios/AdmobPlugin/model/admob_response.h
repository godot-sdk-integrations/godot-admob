//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_response_h
#define admob_response_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"


@interface AdmobResponse : NSObject

/**
 * Initializes the response wrapper with the Google Mobile Ads response info
 * @param info The GADResponseInfo object from the Google Mobile Ads SDK
 */
- (instancetype)initWithResponseInfo:(GADResponseInfo *)info;

/**
 * Builds a Godot-compatible Dictionary containing the response data
 * @return A Dictionary object with the response details
 */
- (Dictionary)buildRawData;

@end

#endif /* admob_response_h */
