//
// © 2024-present https://github.com/cengiz-pz
//

#import "admob_response.h"

#import "admob_adapter_response.h"


static String const kAdapterResponsesProperty = "adapter_responses";
static String const kLoadedAdapterResponseProperty = "loaded_adapter_response";
static String const kAdapterClassNameProperty = "adapter_class_name";
static String const kNetworkTagProperty = "network_tag";
static String const kResponseIdProperty = "response_id";

@interface AdmobResponse ()

@property (nonatomic, strong) GADResponseInfo *info;

@end

@implementation AdmobResponse

- (instancetype)initWithResponseInfo:(GADResponseInfo *)info {
	if (self = [super init]) {
		_info = info;
	}
	return self;
}

- (Dictionary)buildRawData {
	Dictionary dict = Dictionary();

	NSArray<GADAdNetworkResponseInfo *> *adapterResponses = self.info.adNetworkInfoArray;
	Array responseDicts = Array();
	int count = (int)adapterResponses.count;
	responseDicts.resize(count);
	for (int i = 0; i < count; i++) {
		GADAdNetworkResponseInfo *adapterInfo = adapterResponses[i];
		AdmobAdapterResponse *adapterResponse = [[AdmobAdapterResponse alloc] initWithAdapterResponseInfo:adapterInfo];
		responseDicts[i] = [adapterResponse buildRawData];
	}
	dict[kAdapterResponsesProperty] = responseDicts;

	GADAdNetworkResponseInfo *loadedAdapterResponseInfo = self.info.loadedAdNetworkResponseInfo;
	if (loadedAdapterResponseInfo) {
		AdmobAdapterResponse *adapterResponse = [[AdmobAdapterResponse alloc] initWithAdapterResponseInfo:loadedAdapterResponseInfo];
		dict[kLoadedAdapterResponseProperty] = [adapterResponse buildRawData];

		dict[kAdapterClassNameProperty] = [adapterResponse.adapterClassName UTF8String];

		if (adapterResponse.networkTag.length > 0) {
			dict[kNetworkTagProperty] = [[adapterResponse networkTag] UTF8String];
		}
	}

	NSString *responseId = self.info.responseIdentifier;
	if (responseId.length > 0) {
		dict[kResponseIdProperty] = [responseId UTF8String];
	}

	return dict;
}

@end
