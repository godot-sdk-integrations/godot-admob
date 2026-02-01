//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_ad_error_h
#define admob_ad_error_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"


@interface AdmobAdError : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) AdmobAdError *cause;

/**
 * Initializes the ad error wrapper with the Google Mobile Ads error object
 * @param nsError The NSError object from the Google Mobile Ads SDK
 */
- (instancetype) initWithNsError:(NSError*) nsError;

/**
 * Builds a Godot-compatible Dictionary containing the ad error data
 * @return A Dictionary object with the error details
 */
- (Dictionary) buildRawData;

@end

#endif /* admob_ad_error_h */
