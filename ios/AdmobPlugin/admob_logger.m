//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_logger.h"

// Define and initialize the shared os_log_t instance
os_log_t admob_log;

__attribute__((constructor)) // Automatically runs at program startup
static void initialize_admob_log() {
	admob_log = os_log_create("org.godotengine.plugin.ios.admob", "AdmobPlugin");
}
