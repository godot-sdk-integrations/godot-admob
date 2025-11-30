//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_adapter_response.h"

#import "admob_ad_error.h"
#import "mediation_network_factory.h"


static String const kAdErrorProperty = "ad_error";
static String const kAdSourceIdProperty = "ad_source_id";
static String const kAdSourceInstanceIdProperty = "ad_source_instance_id";
static String const kAdSourceInstanceNameProperty = "ad_source_instance_name";
static String const kAdSourceNameProperty = "ad_source_name";
static String const kAdapterClassNameProperty = "adapter_class_name";
static String const kNetworkTagProperty = "network_tag";
static String const kLatencyProperty = "latency";

@interface AdmobAdapterResponse ()

@property (nonatomic, strong) GADAdNetworkResponseInfo *info;

@end

@implementation AdmobAdapterResponse

- (instancetype)initWithAdapterResponseInfo:(GADAdNetworkResponseInfo *)info {
	self = [super init];
	if (self) {
		_info = info;
		_adapterClassName = info.adNetworkClassName;
		_networkTag = [MediationNetworkFactory getTagForAdapterClass:_adapterClassName];
	}
	return self;
}

- (Dictionary)buildRawData {
	Dictionary dict = Dictionary();

	NSError *adError = self.info.error;
	if (adError) {
		dict[kAdErrorProperty] = [[[AdmobAdError alloc] initWithNsError:adError] buildRawData];
	}

	dict[kAdSourceIdProperty] = [self.info.adSourceID UTF8String];
	dict[kAdSourceInstanceIdProperty] = [self.info.adSourceInstanceID UTF8String];
	dict[kAdSourceInstanceNameProperty] = [self.info.adSourceInstanceName UTF8String];
	dict[kAdSourceNameProperty] = [self.info.adSourceName UTF8String];
	dict[kAdapterClassNameProperty] = [self.adapterClassName UTF8String];
	
	if (self.networkTag) {
		dict[kNetworkTagProperty] = [self.networkTag UTF8String];
	}
	
	dict[kLatencyProperty] = self.info.latency;

	return dict;
}

@end
