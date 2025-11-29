//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef load_ad_request_h
#define load_ad_request_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"


@interface LoadAdRequest : NSObject

@property (nonatomic, assign) Dictionary rawData;

- (instancetype) initWithDictionary:(Dictionary) adData;

- (NSString*) adUnitId;
- (NSString*) requestAgent;
- (NSString*) adSize;
- (NSString*) adPosition;
- (BOOL) hasCollapsiblePosition;
- (NSString*) collapsiblePosition;
- (NSArray*) keywords;
- (NSString*) userId;
- (NSString*) customData;
- (Array) networkExtras;

- (GADRequest*) createGADRequest;

@end

#endif /* load_ad_request_h */
