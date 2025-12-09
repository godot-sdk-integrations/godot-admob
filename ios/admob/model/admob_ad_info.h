//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_ad_info_h
#define admob_ad_info_h

#include "core/object/class_db.h"

#import "load_ad_request.h"


@interface AdmobAdInfo : NSObject

@property (nonatomic) NSInteger measuredWidth;
@property (nonatomic) NSInteger measuredHeight;
@property (nonatomic) BOOL isCollapsible;

/**
 * Initializes the ad info wrapper with the ad details
 * @param adId The ad's internal identifier
 * @param loadAdRequest The data that the ad was requested with
 */
- (instancetype) initWithId:(NSString *)adId request:(LoadAdRequest *)loadAdRequest;

/**
 * Builds a Godot-compatible Dictionary containing the ad info
 * @return A Dictionary object with the ad info
 */
- (Dictionary) buildRawData;

@end

#endif /* admob_ad_info_h */
