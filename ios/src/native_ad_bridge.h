//
// © 2026-present https://github.com/cengiz-pz
//

#ifndef native_ad_bridge_h
#define native_ad_bridge_h

#import <Foundation/Foundation.h>

#import "admob_plugin-Swift.h"

// Forward declarations
class AdmobPlugin;
@protocol AdmobNativeAdDelegate;


@interface NativeAdBridge : NSObject <AdmobNativeAdDelegate>

@property (nonatomic, assign) AdmobPlugin* plugin;

- (instancetype)initWithPlugin:(AdmobPlugin*)plugin;

@end

#endif /* native_ad_bridge_h */
