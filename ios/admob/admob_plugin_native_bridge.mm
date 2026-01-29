//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_plugin_native_bridge.h"
#import "admob_plugin.h"
#import "admob_plugin-Swift.h"
#import "admob_ad_info.h"
#import "admob_response.h"
#import "admob_logger.h"


@implementation AdmobPluginNativeAdBridge

- (instancetype)initWithPlugin:(AdmobPlugin*)plugin {
	if (self = [super init]) {
		_plugin = plugin;
	}
	return self;
}

- (void)nativeAdDidLoad:(AdmobAdInfo *)adInfo responseInfo:(GADResponseInfo *)responseInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidLoad");

	Dictionary godotAdInfo = [adInfo buildRawData];

	AdmobResponse *response = [[AdmobResponse alloc] initWithResponseInfo:responseInfo];
	Dictionary godotResponseInfo = [response buildRawData];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_LOADED_SIGNAL, godotAdInfo, godotResponseInfo);
}

- (void)nativeAdDidFailToLoad:(AdmobAdInfo *)adInfo error:(NSError *)error {
	os_log_error(admob_log, "NativeAdDelegate: nativeAdDidFailToLoad with error: %@", error.localizedDescription);

	Dictionary godotAdInfo = [adInfo buildRawData];

	// Convert NSError to Godot Dictionary
	Dictionary godotError;
	godotError["code"] = (int)error.code;
	godotError["message"] = [error.localizedDescription UTF8String];
	godotError["domain"] = [[error domain] UTF8String];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_FAILED_TO_LOAD_SIGNAL, godotAdInfo, godotError);
}

- (void)nativeAdDidRecordImpression:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidRecordImpression");

	Dictionary godotAdInfo = [adInfo buildRawData];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_IMPRESSION_SIGNAL, godotAdInfo);
}

- (void)nativeAdDidRecordClick:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidRecordClick");

	Dictionary godotAdInfo = [adInfo buildRawData];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_CLICKED_SIGNAL, godotAdInfo);
}

- (void)nativeAdWillPresentScreen:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdWillPresentScreen");

	Dictionary godotAdInfo = [adInfo buildRawData];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_OPENED_SIGNAL, godotAdInfo);
}

- (void)nativeAdDidDismissScreen:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidDismissScreen");

	Dictionary godotAdInfo = [adInfo buildRawData];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_CLOSED_SIGNAL, godotAdInfo);
}

- (void)nativeAdDidSizeMeasured:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidSizeMeasured");

	Dictionary godotAdInfo = [adInfo buildRawData];

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_SIZE_MEASURED_SIGNAL, godotAdInfo);
}

@end
