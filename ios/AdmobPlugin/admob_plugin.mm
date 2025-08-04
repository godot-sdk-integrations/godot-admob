//
// © 2024-present https://github.com/cengiz-pz
//
// admob_plugin.mm
//

#import <Foundation/Foundation.h>

#import "admob_plugin.h"
#import "admob_plugin_implementation.h"
#import "admob_logger.h"

#import "core/config/engine.h"


AdmobPlugin *plugin;

void admob_plugin_init() {
	os_log_debug(admob_log, "init plugin");

	plugin = memnew(AdmobPlugin);
	Engine::get_singleton()->add_singleton(Engine::Singleton("AdmobPlugin", plugin));
}

void admob_plugin_deinit() {
	os_log_debug(admob_log, "deinit plugin");
	admob_log = NULL; // Prevent accidental reuse

	if (plugin) {
		memdelete(plugin);
	}
}
