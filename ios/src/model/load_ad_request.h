//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef load_ad_request_h
#define load_ad_request_h

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

#include "core/object/class_db.h"

#import "ad_position.h"

@interface LoadAdRequest : NSObject

@property(nonatomic, assign) Dictionary rawData;

- (instancetype)initWithDictionary:(Dictionary)adData;

// -- General request properties ------------------------------------------------

- (NSString *)adUnitId;
- (NSString *)requestAgent;
- (NSString *)adSize;
- (BOOL)hasAdaptiveWidth;
- (CGFloat)adaptiveWidth;
- (BOOL)hasAdaptiveMaxHeight;
- (CGFloat)adaptiveMaxHeight;
- (NSString *)adPosition;
- (BOOL)hasCollapsiblePosition;
- (NSString *)collapsiblePosition;
- (BOOL)anchorToSafeArea;
- (NSArray *)keywords;
- (BOOL)hasUserId;
- (NSString *)userId;
- (BOOL)hasCustomData;
- (NSString *)customData;
- (Array)networkExtras;

- (GADAdSize)getGADAdSize;
- (AdPosition)getAdPosition;
- (GADRequest *)createGADRequest;

- (BOOL)hasServerSideVerificationOptions;
- (GADServerSideVerificationOptions *)createGADServerSideVerificationOptions;

// -- Native ad options ---------------------------------------------------------

/**
 * Builds the array of @c GADAdLoaderOptions objects for the @c AdLoader, applying
 * only the keys that were explicitly set by the caller in the request dictionary.
 * Keys that are absent produce no option object, so all unset options remain at
 * their SDK defaults.
 *
 * The following option types are produced, each only when the corresponding key
 * is present:
 * - @c GADNativeAdImageAdLoaderOptions  – @c native_return_urls_for_image_assets,
 *                                         @c native_request_multiple_images
 * - @c GADNativeAdMediaAdLoaderOptions  – @c native_media_aspect_ratio
 * - @c GADNativeAdViewAdOptions         – @c native_ad_choices_placement
 */
- (NSArray<GADAdLoaderOptions *> *)createNativeAdLoaderOptions;

/**
 * Returns @c YES when the request dictionary contains a @c native_image_scale_type key.
 */
- (BOOL)hasNativeImageScaleType;

/**
 * Translates the GDScript @c NativeImageScaleType enum string to the matching
 * @c UIViewContentMode.  Falls back to @c UIViewContentModeScaleAspectFit
 * (the iOS @c UIImageView default) when the key is absent or unrecognised.
 *
 * Mapping notes:
 *  - @c FIT_CENTER / @c CENTER_INSIDE → @c UIViewContentModeScaleAspectFit  (aspect-fit, centered)
 *  - @c FIT_XY                        → @c UIViewContentModeScaleToFill     (stretch to fill)
 *  - @c CENTER_CROP                   → @c UIViewContentModeScaleAspectFill (aspect-fill, cropped)
 *  - @c CENTER                        → @c UIViewContentModeCenter          (center, no scaling)
 *  - @c FIT_START / @c MATRIX         → @c UIViewContentModeTopLeft         (closest approximation)
 *  - @c FIT_END                       → @c UIViewContentModeBottomRight     (closest approximation)
 */
- (UIViewContentMode)nativeImageContentMode;

/**
 * Returns @c YES when the request dictionary sets @c native_disable_validator to @c true.
 *
 * @note The Google Mobile Ads iOS SDK does not expose a public API equivalent to
 * Android's native ad validator. This flag is surfaced here for forward-compatibility
 * and is logged by the caller; it has no effect on the SDK call itself.
 */
- (BOOL)isNativeValidatorDisabled;

- (Dictionary)getRawData;

@end

#endif /* load_ad_request_h */
