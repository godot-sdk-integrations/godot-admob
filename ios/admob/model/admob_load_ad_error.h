//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_load_ad_error_h
#define admob_load_ad_error_h

#include "core/object/class_db.h"

#import "admob_ad_error.h"
#import "admob_response.h"


@interface AdmobLoadAdError : AdmobAdError

@property (nonatomic, strong) AdmobResponse *responseInfo;

/**
 * Initializes the load ad error wrapper with the Google Mobile Ads error object
 * @param nsError The NSError object from the Google Mobile Ads SDK
 */
- (instancetype) initWithNsError:(NSError*) nsError;

/**
 * Builds a Godot-compatible Dictionary containing the load ad error data
 * @return A Dictionary object with the error details
 */
- (Dictionary) buildRawData;

@end

#endif /* admob_load_ad_error_h */
