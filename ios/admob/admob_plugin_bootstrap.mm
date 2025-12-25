//
// © 2024-present https://github.com/cengiz-pz
//

#import <Foundation/Foundation.h>

#import "admob_plugin_bootstrap.h"
#import "admob_plugin.h"
#import "admob_logger.h"

#import "core/config/engine.h"


AdmobPlugin *admob_plugin;

void admob_plugin_init() {
	os_log_debug(admob_log, "AdmobPlugin: Initializing plugin at timestamp: %f", [[NSDate date] timeIntervalSince1970]);

	admob_plugin = memnew(AdmobPlugin);
	Engine::get_singleton()->add_singleton(Engine::Singleton("AdmobPlugin", admob_plugin));
	os_log_debug(admob_log, "AdmobPlugin: Singleton registered");
}

void admob_plugin_deinit() {
	os_log_debug(admob_log, "AdmobPlugin: Deinitializing plugin");
	admob_log = NULL; // Prevent accidental reuse

	if (admob_plugin) {
		memdelete(admob_plugin);
		admob_plugin = nullptr;
	}
}
