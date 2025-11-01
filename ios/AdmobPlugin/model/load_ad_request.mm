//
// © 2024-present https://github.com/cengiz-pz
//

#import "load_ad_request.h"

#import <objc/message.h>

#import "gap_converter.h"
#import "admob_logger.h"

const String AD_UNIT_ID_PROPERTY = "ad_unit_id";
const String REQUEST_AGENT_PROPERTY = "request_agent";
const String AD_SIZE_PROPERTY = "ad_size";
const String AD_POSITION_PROPERTY = "ad_position";
const String KEYWORDS_PROPERTY = "keywords";
const String USER_ID_PROPERTY = "user_id";
const String CUSTOM_DATA_PROPERTY = "custom_data";
const String NETWORK_EXTRAS_PROPERTY = "network_extras";
const String ADAPTER_CLASS_SUBPROPERTY = "adapter_class";
const String EXTRAS_SUBPROPERTY = "extras";


@implementation LoadAdRequest

- (instancetype) initWithDictionary:(Dictionary) adData {
	if ((self = [super init])) {
		self.rawData = adData;
	}
	return self;
}

- (NSString*) adUnitId {
	return self.rawData.has(AD_UNIT_ID_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[AD_UNIT_ID_PROPERTY]] : @"";
}

- (NSString*) requestAgent {
	return self.rawData.has(REQUEST_AGENT_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[REQUEST_AGENT_PROPERTY]] : @"";
}

- (NSString*) adSize {
	return self.rawData.has(AD_SIZE_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[AD_SIZE_PROPERTY]] : @"";
}

- (NSString*) adPosition {
	return self.rawData.has(AD_POSITION_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[AD_POSITION_PROPERTY]] : @"";
}

- (NSArray*) keywords {
	return self.rawData.has(KEYWORDS_PROPERTY) ? [GAPConverter toNsStringArray: (Array) self.rawData[KEYWORDS_PROPERTY]] : @[];
}

- (NSString*) userId {
	return self.rawData.has(USER_ID_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[USER_ID_PROPERTY]] : @"";
}

- (NSString*) customData {
	return self.rawData.has(CUSTOM_DATA_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[CUSTOM_DATA_PROPERTY]] : @"";
}

- (Array) networkExtras {
	return self.rawData.has(NETWORK_EXTRAS_PROPERTY) ? (Array) self.rawData[NETWORK_EXTRAS_PROPERTY] : Array();
}

- (GADRequest *) createGADRequest {
	GADRequest *request = [GADRequest request];

	if (![[self requestAgent] isEqualToString:@""]) {
		request.requestAgent = [self requestAgent];
		os_log_debug(admob_log, "Set request agent to: %@", [self requestAgent]);
	}

	// Mediation support: AdRequest extras for specific networks
	// Expects "network_extras" as Array of Dictionary: { "extras_class": String, "extras": Dictionary }
	Array networkExtrasArray = [self networkExtras];
	os_log_debug(admob_log, "Found %d extras to process", networkExtrasArray.size());
	for (int i = 0; i < networkExtrasArray.size(); ++i) {
		Dictionary entry = networkExtrasArray[i];
		if (entry.has(ADAPTER_CLASS_SUBPROPERTY) && entry.has(EXTRAS_SUBPROPERTY)) {
			String adapterClassStr = entry[ADAPTER_CLASS_SUBPROPERTY];
			NSString *adapterClassName = [GAPConverter toNsString:adapterClassStr];
			Dictionary extrasDict = entry[EXTRAS_SUBPROPERTY];
			NSDictionary *extrasParams = [GAPConverter toNsDictionary:extrasDict];

			if (adapterClassName && ![adapterClassName isEqualToString:@""] && extrasParams) {
				Class adapterClass = NSClassFromString(adapterClassName);
				if (adapterClass) {
					if ([adapterClass respondsToSelector:@selector(networkExtrasClass)]) {

						// Declare the objc_msgSend signature for this selector:
						using NetworkExtrasClassFn = Class<GADAdNetworkExtras> (*)(Class, SEL);
						NetworkExtrasClassFn msgSendFunc = reinterpret_cast<NetworkExtrasClassFn>(objc_msgSend);

						// Safely call the +networkExtrasClass method
						Class<GADAdNetworkExtras> extrasClass = msgSendFunc(adapterClass, @selector(networkExtrasClass));

						if (extrasClass) {
							if ([extrasClass conformsToProtocol:@protocol(GADAdNetworkExtras)]) {
								id extras = [[(Class)extrasClass alloc] init];
								if (extras) {
									for (NSObject *key in extrasParams) {
										if ([key isKindOfClass:[NSString class]]) {
											id value = extrasParams[key];
											@try {
												[extras setValue:value forKey:(NSString*) key];
											}
											@catch (NSException *exception) {
												os_log_error(admob_log, "Unable to set key %@ due to %@ (%@)", key, [exception name], [exception reason]);
											}
										} else {
											os_log_error(admob_log, "Invalid extras key. Skipping.");
										}
									}
									[request registerAdNetworkExtras:extras];
									os_log_debug(admob_log, "Added extras for adapter: %@", adapterClassName);
								} else {
									os_log_error(admob_log, "Failed to init extras class: %@", NSStringFromClass(extrasClass));
								}
							} else {
								os_log_error(admob_log, "Class %@ does not conform to GADAdNetworkExtras. Skipping.", NSStringFromClass(extrasClass));
							}
						} else {
							os_log_error(admob_log, "Class %@ has no extras class defined. Skipping.", adapterClassName);
						}
					} else {
						os_log_error(admob_log, "Class %@ has no networkExtrasClass method. Skipping.", adapterClassName);
					}
				} else {
					os_log_error(admob_log, "Class %@ not found. Skipping.", adapterClassName);
				}
			} else {
				os_log_error(admob_log, "Class name or extras entry not found. Skipping.");
			}
		} else {
			os_log_error(admob_log, "Invalid '%s' entry: Missing '%s' or '%s'. Skipping.", NETWORK_EXTRAS_PROPERTY.utf8().get_data(),
					ADAPTER_CLASS_SUBPROPERTY.utf8().get_data(), EXTRAS_SUBPROPERTY.utf8().get_data());
		}
	}

	request.keywords = [self keywords];

	return request;
}

@end
