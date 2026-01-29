//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_plugin_native_bridge_h
#define admob_plugin_native_bridge_h

#import <Foundation/Foundation.h>

// Forward declarations
class AdmobPlugin;
@protocol NativeAdDelegate;


@interface AdmobPluginNativeAdBridge : NSObject <NativeAdDelegate>

@property (nonatomic, assign) AdmobPlugin* plugin;

- (instancetype)initWithPlugin:(AdmobPlugin*)plugin;

@end

#endif /* admob_plugin_native_bridge_h */
