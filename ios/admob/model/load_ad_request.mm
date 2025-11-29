//
// © 2024-present https://github.com/cengiz-pz
//

#import "load_ad_request.h"

#import <objc/message.h>

#import "mediation_network.h"
#import "mediation_network_factory.h"
#import "gap_converter.h"
#import "admob_logger.h"

const String AD_UNIT_ID_PROPERTY = "ad_unit_id";
const String REQUEST_AGENT_PROPERTY = "request_agent";
const String AD_SIZE_PROPERTY = "ad_size";
const String AD_POSITION_PROPERTY = "ad_position";
const String COLLAPSIBLE_POSITION_PROPERTY = "collapsible_position";
const String KEYWORDS_PROPERTY = "keywords";
const String USER_ID_PROPERTY = "user_id";
const String CUSTOM_DATA_PROPERTY = "custom_data";
const String NETWORK_EXTRAS_PROPERTY = "network_extras";
const String NETWORK_TAG_SUBPROPERTY = "network_tag";
const String EXTRAS_SUBPROPERTY = "extras";

static NSString *const COLLAPSIBLE_NETWORK_EXTRAS_KEY = @"collapsible";

static NSString *const METHOD_CALL_PREFIX = @"::";


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

- (BOOL) hasCollapsiblePosition {
	return self.rawData.has(COLLAPSIBLE_POSITION_PROPERTY);
}

- (NSString*) collapsiblePosition {
	return self.rawData.has(COLLAPSIBLE_POSITION_PROPERTY) ? [GAPConverter toNsString: (String) self.rawData[COLLAPSIBLE_POSITION_PROPERTY]] : @"";
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

	request.keywords = [self keywords];

	if ([self hasCollapsiblePosition]) {
		GADExtras *extras = [[GADExtras alloc] init];
		extras.additionalParameters = @{COLLAPSIBLE_NETWORK_EXTRAS_KEY : [self collapsiblePosition]};
		os_log_debug(admob_log, "Set collapsible position to: %@", [self collapsiblePosition]);
		[request registerAdNetworkExtras:extras];
	}

	// Mediation support: AdRequest extras for specific networks
	// Expects "network_extras" as Array of Dictionary: { "extras_class": String, "extras": Dictionary }
	Array networkExtrasArray = [self networkExtras];
	os_log_debug(admob_log, "Found %d extras to process", networkExtrasArray.size());
	for (int i = 0; i < networkExtrasArray.size(); ++i) {
		Dictionary entry = networkExtrasArray[i];
		if (entry.has(NETWORK_TAG_SUBPROPERTY) && entry.has(EXTRAS_SUBPROPERTY)) {
			NSString *networkTag = [GAPConverter toNsString:entry[NETWORK_TAG_SUBPROPERTY]];
			MediationNetwork *network = [MediationNetworkFactory createNetwork:networkTag];
			if (network) {
				Dictionary extrasDict = entry[EXTRAS_SUBPROPERTY];
				NSDictionary *extrasParams = [GAPConverter toNsDictionary:extrasDict];
				if (extrasParams && [extrasParams count] > 0) {
					NSString *adapterClassName = [network getAdapterClassName];
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
										int numAdded = 0;
										for (NSObject *keyObj in extrasParams) {
											if ([keyObj isKindOfClass:[NSString class]]) {
												id value = extrasParams[keyObj];
												NSString *key = (NSString *) keyObj;
												@try {
													if ([key hasPrefix:METHOD_CALL_PREFIX]) {
														os_log_debug(admob_log, "Processing method call '%@' for %@", key, adapterClassName);
														SEL methodSel = NSSelectorFromString([key substringFromIndex:[METHOD_CALL_PREFIX length]]);
														((void (*)(id, SEL, id))objc_msgSend)(extras, methodSel, value);
													} else {
														os_log_debug(admob_log, "Processing key-value coding '%@' for %@", key, adapterClassName);
														[extras setValue:value forKey:(NSString*) key];
													}
													numAdded++;
												}
												@catch (NSException *exception) {
													os_log_error(admob_log, "Unable to set key %@ due to %@ (%@)", key, [exception name], [exception reason]);
												}
											} else {
												os_log_error(admob_log, "Invalid extras key. Skipping.");
											}
										}
										if (numAdded > 0) {
											[request registerAdNetworkExtras:extras];
											os_log_debug(admob_log, "Added %d extras for adapter: %@", numAdded, adapterClassName);
										}
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
					os_log_error(admob_log, "No extras found for %@. Skipping.", networkTag);
				}
			} else {
				os_log_error(admob_log, "No network found for tag '%@'. Skipping.", networkTag);
			}
		} else {
			os_log_error(admob_log, "Invalid '%s' entry: Missing '%s' or '%s'. Skipping.", NETWORK_EXTRAS_PROPERTY.utf8().get_data(),
					NETWORK_TAG_SUBPROPERTY.utf8().get_data(), EXTRAS_SUBPROPERTY.utf8().get_data());
		}
	}

	return request;
}

@end
