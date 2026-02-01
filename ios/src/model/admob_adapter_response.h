//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_adapter_response_h
#define admob_adapter_response_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include "core/object/class_db.h"


@interface AdmobAdapterResponse : NSObject

@property (nonatomic, strong) NSString *adapterClassName;
@property (nonatomic, strong) NSString *networkTag;

/**
 * Initializes the adapter response wrapper with the Google Mobile Ads adapter response info
 * @param info The GADAdNetworkResponseInfo object from the Google Mobile Ads SDK
 */
- (instancetype) initWithAdapterResponseInfo:(GADAdNetworkResponseInfo *)info;

/**
 * Builds a Godot-compatible Dictionary containing the adapter response data
 * @return A Dictionary object with the adapter response details
 */
- (Dictionary) buildRawData;

@end

#endif /* admob_adapter_response_h */
