//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_status.h"
#import <Foundation/Foundation.h>

#import "mediation_network_factory.h"
#import "admob_logger.h"


@implementation AdmobStatus

// Define the external constants declared in the header file
String const kAdmobAdapterClassProperty = "adapter_class";
String const kAdmobLatencyProperty = "latency";
String const kAdmobInitializationStateProperty = "initialization_state";
String const kAdmobDescriptionProperty = "description";


static NSString *const kLogTag = @"AdmobPlugin::AdmobStatus::";


- (instancetype)initWithStatus:(GADInitializationStatus *) status {
	self = [super init];
	if (self) {
		_status = status; // Retain the status object
	}
	return self;
}

- (Dictionary)buildRawData {
	Dictionary dict = Dictionary();

	NSDictionary<NSString *, GADAdapterStatus *> *adapterMap = _status.adapterStatusesByClassName;
	for (NSString *adapterClass in adapterMap) {
		Dictionary adapterStatusDict = Dictionary();

		GADAdapterStatus *adapterStatus = adapterMap[adapterClass];

		adapterStatusDict[kAdmobAdapterClassProperty] = [adapterClass UTF8String];
		adapterStatusDict[kAdmobLatencyProperty] = adapterStatus.latency;
		NSString *adapterStatusStr = [AdmobStatus adapterStatusToString:adapterStatus.state];
		adapterStatusDict[kAdmobInitializationStateProperty] = [adapterStatusStr UTF8String];
		adapterStatusDict[kAdmobDescriptionProperty] = [adapterStatus.description UTF8String];

		NSString* networkTag = [MediationNetworkFactory getTagForAdapterClass:adapterClass];
		if (networkTag) {
			dict[[networkTag UTF8String]] = adapterStatusDict;
			os_log_debug(admob_log, "%@ Initialization status %@ for network tag '%@'", kLogTag, adapterStatusStr, networkTag);
		} else {
			dict[[adapterClass UTF8String]] = adapterStatusDict;
			os_log_error(admob_log, "%@ Initialization status %@ for an invalid or unsupported adapter class '%@'", kLogTag, adapterStatusStr, adapterClass);
		}
	}

	return dict;
}

+ (NSString *)adapterStatusToString:(GADAdapterInitializationState)adapterInitializationState {
	switch (adapterInitializationState) {
		case GADAdapterInitializationStateNotReady:
			return @"NOT_READY";
		case GADAdapterInitializationStateReady:
			return @"READY";
		default:
			return @"INVALID";
	}
}

@end
