//
// © 2026-present https://github.com/cengiz-pz
//

#import "native_ad_bridge.h"

#import "admob_plugin.h"
#import "admob_ad_info.h"
#import "admob_response.h"
#import "admob_ad_error.h"
#import "admob_load_ad_error.h"
#import "admob_logger.h"


@interface AdmobAdInfo (Access)
- (Dictionary) buildRawData;
@end

@implementation NativeAdBridge

- (instancetype)initWithPlugin:(AdmobPlugin*)plugin {
	if (self = [super init]) {
		_plugin = plugin;
	}
	return self;
}

- (void)nativeAdDidLoad:(AdmobAdInfo *)adInfo responseInfo:(GADResponseInfo *)responseInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidLoad");

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_LOADED_SIGNAL, [adInfo buildRawData],
			[[[AdmobResponse alloc] initWithResponseInfo:responseInfo] buildRawData]);
}

- (void)nativeAdDidFailToLoad:(AdmobAdInfo *)adInfo error:(NSError *)error {
	os_log_error(admob_log, "NativeAdDelegate: nativeAdDidFailToLoad with error: %@", error.localizedDescription);

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_FAILED_TO_LOAD_SIGNAL, [adInfo buildRawData],
			[[[AdmobLoadAdError alloc] initWithNsError:error] buildRawData]);
}

- (void)nativeAdDidRecordImpression:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidRecordImpression");

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_IMPRESSION_SIGNAL, [adInfo buildRawData]);
}

- (void)nativeAdDidRecordClick:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidRecordClick");

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_CLICKED_SIGNAL, [adInfo buildRawData]);
}

- (void)nativeAdWillPresentScreen:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdWillPresentScreen");

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_OPENED_SIGNAL, [adInfo buildRawData]);
}

- (void)nativeAdDidDismissScreen:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidDismissScreen");

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_CLOSED_SIGNAL, [adInfo buildRawData]);
}

- (void)nativeAdDidSizeMeasured:(AdmobAdInfo *)adInfo {
	os_log_debug(admob_log, "NativeAdDelegate: nativeAdDidSizeMeasured");

	AdmobPlugin::get_singleton()->call_deferred("emit_signal", NATIVE_AD_SIZE_MEASURED_SIGNAL, [adInfo buildRawData]);
}

@end
