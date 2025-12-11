//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef load_ad_request_h
#define load_ad_request_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"

#import "ad_position.h"


@interface LoadAdRequest : NSObject

@property (nonatomic, assign) Dictionary rawData;

- (instancetype) initWithDictionary:(Dictionary) adData;

- (NSString*) adUnitId;
- (NSString*) requestAgent;
- (NSString*) adSize;
- (NSString*) adPosition;
- (BOOL) hasCollapsiblePosition;
- (NSString*) collapsiblePosition;
- (BOOL) anchorToSafeArea;
- (NSArray*) keywords;
- (BOOL) hasUserId;
- (NSString*) userId;
- (BOOL) hasCustomData;
- (NSString*) customData;
- (Array) networkExtras;

- (GADAdSize) getGADAdSize;
- (AdPosition) getAdPosition;
- (GADRequest*) createGADRequest;

- (BOOL) hasServerSideVerificationOptions;
- (GADServerSideVerificationOptions *) createGADServerSideVerificationOptions;

- (Dictionary) getRawData;

@end

#endif /* load_ad_request_h */
