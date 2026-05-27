//
// © 2024-present https://github.com/cengiz-pz
//

#import "load_ad_request.h"

#import <objc/message.h>

#import "admob_logger.h"
#import "gap_converter.h"
#import "mediation_network.h"
#import "mediation_network_factory.h"

// -- General request property keys --------------------------------------------

const String AD_UNIT_ID_PROPERTY = "ad_unit_id";
const String REQUEST_AGENT_PROPERTY = "request_agent";
const String AD_SIZE_PROPERTY = "ad_size";
const String ADAPTIVE_WIDTH_PROPERTY = "adaptive_width";
const String ADAPTIVE_MAX_HEIGHT_PROPERTY = "adaptive_max_height";
const String AD_POSITION_PROPERTY = "ad_position";
const String COLLAPSIBLE_POSITION_PROPERTY = "collapsible_position";
const String ANCHOR_TO_SAFE_AREA_PROPERTY = "anchor_to_safe_area";
const String KEYWORDS_PROPERTY = "keywords";
const String USER_ID_PROPERTY = "user_id";
const String CUSTOM_DATA_PROPERTY = "custom_data";
const String NETWORK_EXTRAS_PROPERTY = "network_extras";
const String NETWORK_TAG_SUBPROPERTY = "network_tag";
const String EXTRAS_SUBPROPERTY = "extras";

// -- Native ad option property keys -------------------------------------------
// These mirror the DATA_KEY_NATIVE_* constants in LoadAdRequest.gd.

const String NATIVE_MEDIA_ASPECT_RATIO_PROPERTY = "native_media_aspect_ratio";
const String NATIVE_RETURN_URLS_FOR_IMAGE_ASSETS_PROPERTY = "native_return_urls_for_image_assets";
const String NATIVE_REQUEST_MULTIPLE_IMAGES_PROPERTY = "native_request_multiple_images";
const String NATIVE_AD_CHOICES_PLACEMENT_PROPERTY = "native_ad_choices_placement";
const String NATIVE_IMAGE_SCALE_TYPE_PROPERTY = "native_image_scale_type";
const String NATIVE_DISABLE_VALIDATOR_PROPERTY = "native_disable_validator";

static NSString *const COLLAPSIBLE_NETWORK_EXTRAS_KEY = @"collapsible";
static NSString *const METHOD_CALL_PREFIX = @"::";

// -- Private interface --------------------------------------------------------

@interface LoadAdRequest ()

/**
 * Maps a GDScript @c NativeMediaAspectRatio enum key to the matching
 * @c GADMediaAspectRatio constant.  Falls back to @c GADMediaAspectRatioUnknown
 * for unrecognised strings.
 */
- (GADMediaAspectRatio)parseMediaAspectRatio:(NSString *)value;

/**
 * Maps a GDScript @c NativeAdChoicesPlacement enum key to the matching
 * @c GADAdChoicesPosition constant.  Falls back to
 * @c GADAdChoicesPositionTopRightCorner (SDK default) for unrecognised strings.
 */
- (GADAdChoicesPosition)parseAdChoicesPlacement:(NSString *)value;

/**
 * Maps a GDScript @c NativeImageScaleType enum key to the matching
 * @c UIViewContentMode.  Falls back to @c UIViewContentModeScaleAspectFit
 * for unrecognised strings.
 */
- (UIViewContentMode)parseImageContentMode:(NSString *)value;

@end

// -- Implementation -----------------------------------------------------------

@implementation LoadAdRequest

- (instancetype)initWithDictionary:(Dictionary)adData {
	if ((self = [super init])) {
		self.rawData = adData;
	}
	return self;
}

- (NSString *)adUnitId {
	return self.rawData.has(AD_UNIT_ID_PROPERTY) ? [GAPConverter toNsString:(String)self.rawData[AD_UNIT_ID_PROPERTY]]
												 : @"";
}

- (NSString *)requestAgent {
	return self.rawData.has(REQUEST_AGENT_PROPERTY)
			? [GAPConverter toNsString:(String)self.rawData[REQUEST_AGENT_PROPERTY]]
			: @"";
}

- (NSString *)adSize {
	return self.rawData.has(AD_SIZE_PROPERTY) ? [GAPConverter toNsString:(String)self.rawData[AD_SIZE_PROPERTY]] : @"";
}

- (BOOL)hasAdaptiveWidth {
	return self.rawData.has(ADAPTIVE_WIDTH_PROPERTY);
}

- (CGFloat)adaptiveWidth {
	CGFloat adaptiveWidth = 0;
	Variant v = self.rawData[ADAPTIVE_WIDTH_PROPERTY];
	if (v.get_type() == Variant::FLOAT || v.get_type() == Variant::INT) {
		adaptiveWidth = (CGFloat)v.operator double();
	}
	return adaptiveWidth;
}

- (BOOL)hasAdaptiveMaxHeight {
	return self.rawData.has(ADAPTIVE_MAX_HEIGHT_PROPERTY);
}

- (CGFloat)adaptiveMaxHeight {
	CGFloat adaptiveMaxHeight = 0;
	Variant v = self.rawData[ADAPTIVE_MAX_HEIGHT_PROPERTY];
	if (v.get_type() == Variant::FLOAT || v.get_type() == Variant::INT) {
		double val = v.operator double();
		if (val > 0) {
			adaptiveMaxHeight = (CGFloat)val;
		}
	}
	return adaptiveMaxHeight;
}

- (NSString *)adPosition {
	return self.rawData.has(AD_POSITION_PROPERTY) ? [GAPConverter toNsString:(String)self.rawData[AD_POSITION_PROPERTY]]
												  : @"";
}

- (BOOL)hasCollapsiblePosition {
	return self.rawData.has(COLLAPSIBLE_POSITION_PROPERTY);
}

- (NSString *)collapsiblePosition {
	return self.rawData.has(COLLAPSIBLE_POSITION_PROPERTY)
			? [GAPConverter toNsString:(String)self.rawData[COLLAPSIBLE_POSITION_PROPERTY]]
			: @"";
}

- (BOOL)anchorToSafeArea {
	return self.rawData.has(ANCHOR_TO_SAFE_AREA_PROPERTY) ? (BOOL)self.rawData[ANCHOR_TO_SAFE_AREA_PROPERTY] : NO;
}

- (NSArray *)keywords {
	return self.rawData.has(KEYWORDS_PROPERTY) ? [GAPConverter toNsStringArray:(Array)self.rawData[KEYWORDS_PROPERTY]]
											   : @[];
}

- (BOOL)hasUserId {
	return self.rawData.has(USER_ID_PROPERTY);
}

- (NSString *)userId {
	return self.rawData.has(USER_ID_PROPERTY) ? [GAPConverter toNsString:(String)self.rawData[USER_ID_PROPERTY]] : @"";
}

- (BOOL)hasCustomData {
	return self.rawData.has(CUSTOM_DATA_PROPERTY);
}

- (NSString *)customData {
	return self.rawData.has(CUSTOM_DATA_PROPERTY) ? [GAPConverter toNsString:(String)self.rawData[CUSTOM_DATA_PROPERTY]]
												  : @"";
}

- (Array)networkExtras {
	return self.rawData.has(NETWORK_EXTRAS_PROPERTY) ? (Array)self.rawData[NETWORK_EXTRAS_PROPERTY] : Array();
}

- (GADAdSize)getGADAdSize {
	GADAdSize gadAdSize = GADAdSizeBanner; // default

	NSString *adSizeStr = [self adSize];
	if ([adSizeStr isEqualToString:@"BANNER"]) {
		gadAdSize = GADAdSizeBanner;
	} else if ([adSizeStr isEqualToString:@"LARGE_BANNER"]) {
		gadAdSize = GADAdSizeLargeBanner;
	} else if ([adSizeStr isEqualToString:@"MEDIUM_RECTANGLE"]) {
		gadAdSize = GADAdSizeMediumRectangle;
	} else if ([adSizeStr isEqualToString:@"FULL_BANNER"]) {
		gadAdSize = GADAdSizeFullBanner;
	} else if ([adSizeStr isEqualToString:@"LEADERBOARD"]) {
		gadAdSize = GADAdSizeLeaderboard;
	} else if ([adSizeStr isEqualToString:@"SKYSCRAPER"]) {
		gadAdSize = GADAdSizeSkyscraper;
	} else if ([adSizeStr isEqualToString:@"FLUID"]) {
		gadAdSize = GADAdSizeFluid;
	} else if ([adSizeStr isEqualToString:@"ADAPTIVE"]) {
		CGFloat width = [[UIScreen mainScreen] bounds].size.width;
		if ([self hasAdaptiveWidth]) {
			width = [self adaptiveWidth];
		}
		gadAdSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width);
	} else if ([adSizeStr isEqualToString:@"INLINE_ADAPTIVE"]) {
		CGFloat width = [[UIScreen mainScreen] bounds].size.width;
		if ([self hasAdaptiveWidth]) {
			width = [self adaptiveWidth];
		}

		CGFloat maxHeight = 0;
		if ([self hasAdaptiveMaxHeight]) {
			maxHeight = [self adaptiveMaxHeight];
		}

		os_log_debug(admob_log, "INLINE_ADAPTIVE: width: %.0f maxHeight:%.0f", width, maxHeight);

		if (maxHeight > 0) {
			gadAdSize = GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(width, maxHeight);
		} else {
			gadAdSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width);
		}
	}

	return gadAdSize;
}

- (AdPosition)getAdPosition {
	AdPosition adPosition;

	NSString *adPositionStr = [self adPosition];
	if ([adPositionStr isEqualToString:@"TOP"]) {
		adPosition = AdPositionTop;
	} else if ([adPositionStr isEqualToString:@"BOTTOM"]) {
		adPosition = AdPositionBottom;
	} else if ([adPositionStr isEqualToString:@"LEFT"]) {
		adPosition = AdPositionLeft;
	} else if ([adPositionStr isEqualToString:@"RIGHT"]) {
		adPosition = AdPositionLeft;
	} else if ([adPositionStr isEqualToString:@"TOP_LEFT"]) {
		adPosition = AdPositionTopLeft;
	} else if ([adPositionStr isEqualToString:@"TOP_RIGHT"]) {
		adPosition = AdPositionTopRight;
	} else if ([adPositionStr isEqualToString:@"BOTTOM_LEFT"]) {
		adPosition = AdPositionBottomLeft;
	} else if ([adPositionStr isEqualToString:@"BOTTOM_RIGHT"]) {
		adPosition = AdPositionBottomRight;
	} else if ([adPositionStr isEqualToString:@"CENTER"]) {
		adPosition = AdPositionCenter;
	} else if ([adPositionStr isEqualToString:@"CUSTOM"]) {
		adPosition = AdPositionCustom;
	} else {
		os_log_error(admob_log, "AdmobPlugin banner load: ERROR: invalid ad position '%@'", adPositionStr);
		adPosition = AdPositionTop;
	}

	return adPosition;
}

- (GADRequest *)createGADRequest {
	GADRequest *request = [GADRequest request];

	if (![[self requestAgent] isEqualToString:@""]) {
		request.requestAgent = [self requestAgent];
		os_log_debug(admob_log, "Set request agent to: %@", [self requestAgent]);
	}

	request.keywords = [self keywords];

	if ([self hasCollapsiblePosition]) {
		GADExtras *extras = [[GADExtras alloc] init];
		extras.additionalParameters = @{ COLLAPSIBLE_NETWORK_EXTRAS_KEY : [self collapsiblePosition] };
		os_log_debug(admob_log, "Set collapsible position to: %@", [self collapsiblePosition]);
		[request registerAdNetworkExtras:extras];
	}

	// Mediation support: AdRequest extras for specific networks
	// Expects "network_extras" as Array of Dictionary: { "network_tag": String,
	// "extras": Dictionary }
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
							Class<GADAdNetworkExtras> extrasClass =
									msgSendFunc(adapterClass, @selector(networkExtrasClass));

							if (extrasClass) {
								if ([extrasClass conformsToProtocol:@protocol(GADAdNetworkExtras)]) {
									id extras = [[(Class)extrasClass alloc] init];
									if (extras) {
										int numAdded = 0;
										for (NSObject *keyObj in extrasParams) {
											if ([keyObj isKindOfClass:[NSString class]]) {
												id value = extrasParams[keyObj];
												NSString *key = (NSString *)keyObj;
												@try {
													if ([key hasPrefix:METHOD_CALL_PREFIX]) {
														os_log_debug(admob_log, "Processing method call '%@' for %@",
																key, adapterClassName);
														SEL methodSel = NSSelectorFromString(
																[key substringFromIndex:[METHOD_CALL_PREFIX length]]);
														((void (*)(id, SEL, id))objc_msgSend)(extras, methodSel, value);
													} else {
														os_log_debug(admob_log,
																"Processing key-value coding '%@' for %@", key,
																adapterClassName);
														[extras setValue:value forKey:(NSString *)key];
													}
													numAdded++;
												} @catch (NSException *exception) {
													os_log_error(admob_log, "Unable to set key %@ due to %@ (%@)", key,
															[exception name], [exception reason]);
												}
											} else {
												os_log_error(admob_log, "Invalid extras key. Skipping.");
											}
										}
										if (numAdded > 0) {
											[request registerAdNetworkExtras:extras];
											os_log_debug(admob_log, "Added %d extras for adapter: %@", numAdded,
													adapterClassName);
										}
									} else {
										os_log_error(admob_log, "Failed to init extras class: %@",
												NSStringFromClass(extrasClass));
									}
								} else {
									os_log_error(admob_log,
											"Class %@ does not conform to "
											"GADAdNetworkExtras. Skipping.",
											NSStringFromClass(extrasClass));
								}
							} else {
								os_log_error(
										admob_log, "Class %@ has no extras class defined. Skipping.", adapterClassName);
							}
						} else {
							os_log_error(admob_log, "Class %@ has no networkExtrasClass method. Skipping.",
									adapterClassName);
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
			os_log_error(admob_log, "Invalid '%s' entry: Missing '%s' or '%s'. Skipping.",
					NETWORK_EXTRAS_PROPERTY.utf8().get_data(), NETWORK_TAG_SUBPROPERTY.utf8().get_data(),
					EXTRAS_SUBPROPERTY.utf8().get_data());
		}
	}

	return request;
}

- (BOOL)hasServerSideVerificationOptions {
	return ([self hasUserId] || [self hasCustomData]);
}

- (GADServerSideVerificationOptions *)createGADServerSideVerificationOptions {
	GADServerSideVerificationOptions *gadOptions = [[GADServerSideVerificationOptions alloc] init];

	if ([self hasUserId]) {
		gadOptions.userIdentifier = [self userId];
	}

	if ([self hasCustomData]) {
		gadOptions.customRewardString = [self customData];
	}

	return gadOptions;
}

// -- Native ad options --------------------------------------------------------

- (NSArray<GADAdLoaderOptions *> *)createNativeAdLoaderOptions {
	NSMutableArray<GADAdLoaderOptions *> *options = [NSMutableArray array];

	// GADNativeAdImageAdLoaderOptions — image loading behaviour.
	// Only instantiated when at least one image-related key is present so that
	// the SDK default (load images, one per slot) is preserved when neither key
	// is set.
	BOOL hasReturnUrls = self.rawData.has(NATIVE_RETURN_URLS_FOR_IMAGE_ASSETS_PROPERTY);
	BOOL hasMultipleImages = self.rawData.has(NATIVE_REQUEST_MULTIPLE_IMAGES_PROPERTY);
	if (hasReturnUrls || hasMultipleImages) {
		GADNativeAdImageAdLoaderOptions *imageOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];

		if (hasReturnUrls) {
			// When true, the SDK skips image loading and provides URLs instead —
			// the iOS equivalent of Android's setReturnUrlsForImageAssets(true).
			imageOptions.disableImageLoading = (BOOL)self.rawData[NATIVE_RETURN_URLS_FOR_IMAGE_ASSETS_PROPERTY];
			os_log_debug(admob_log, "LoadAdRequest: disableImageLoading = %d", imageOptions.disableImageLoading);
		}

		if (hasMultipleImages) {
			imageOptions.shouldRequestMultipleImages = (BOOL)self.rawData[NATIVE_REQUEST_MULTIPLE_IMAGES_PROPERTY];
			os_log_debug(admob_log, "LoadAdRequest: shouldRequestMultipleImages = %d",
					imageOptions.shouldRequestMultipleImages);
		}

		[options addObject:imageOptions];
	}

	// GADNativeAdMediaAdLoaderOptions — preferred media aspect ratio.
	if (self.rawData.has(NATIVE_MEDIA_ASPECT_RATIO_PROPERTY)) {
		GADNativeAdMediaAdLoaderOptions *mediaOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
		NSString *ratioStr = [GAPConverter toNsString:(String)self.rawData[NATIVE_MEDIA_ASPECT_RATIO_PROPERTY]];
		mediaOptions.mediaAspectRatio = [self parseMediaAspectRatio:ratioStr];
		os_log_debug(admob_log, "LoadAdRequest: mediaAspectRatio = %ld (from '%@')",
				(long)mediaOptions.mediaAspectRatio, ratioStr);
		[options addObject:mediaOptions];
	}

	// GADNativeAdViewAdOptions — AdChoices icon placement.
	if (self.rawData.has(NATIVE_AD_CHOICES_PLACEMENT_PROPERTY)) {
		GADNativeAdViewAdOptions *viewAdOptions = [[GADNativeAdViewAdOptions alloc] init];
		NSString *placementStr = [GAPConverter toNsString:(String)self.rawData[NATIVE_AD_CHOICES_PLACEMENT_PROPERTY]];
		viewAdOptions.preferredAdChoicesPosition = [self parseAdChoicesPlacement:placementStr];
		os_log_debug(admob_log, "LoadAdRequest: preferredAdChoicesPosition = %ld (from '%@')",
				(long)viewAdOptions.preferredAdChoicesPosition, placementStr);
		[options addObject:viewAdOptions];
	}

	return [options copy];
}

- (BOOL)hasNativeImageScaleType {
	return self.rawData.has(NATIVE_IMAGE_SCALE_TYPE_PROPERTY);
}

- (UIViewContentMode)nativeImageContentMode {
	if (![self hasNativeImageScaleType]) {
		return UIViewContentModeScaleAspectFit;
	}
	NSString *value = [GAPConverter toNsString:(String)self.rawData[NATIVE_IMAGE_SCALE_TYPE_PROPERTY]];
	return [self parseImageContentMode:value];
}

- (BOOL)isNativeValidatorDisabled {
	return self.rawData.has(NATIVE_DISABLE_VALIDATOR_PROPERTY) && (BOOL)self.rawData[NATIVE_DISABLE_VALIDATOR_PROPERTY];
}

- (Dictionary)getRawData {
	return self.rawData;
}

// -- Private helpers ----------------------------------------------------------

- (GADMediaAspectRatio)parseMediaAspectRatio:(NSString *)value {
	if ([value isEqualToString:@"ANY"]) {
		return GADMediaAspectRatioAny;
	} else if ([value isEqualToString:@"LANDSCAPE"]) {
		return GADMediaAspectRatioLandscape;
	} else if ([value isEqualToString:@"PORTRAIT"]) {
		return GADMediaAspectRatioPortrait;
	} else if ([value isEqualToString:@"SQUARE"]) {
		return GADMediaAspectRatioSquare;
	} else {
		if (![value isEqualToString:@"UNKNOWN"]) {
			os_log_error(admob_log, "LoadAdRequest parseMediaAspectRatio: unknown value '%@', using UNKNOWN", value);
		}
		return GADMediaAspectRatioUnknown;
	}
}

- (GADAdChoicesPosition)parseAdChoicesPlacement:(NSString *)value {
	if ([value isEqualToString:@"TOP_LEFT"]) {
		return GADAdChoicesPositionTopLeftCorner;
	} else if ([value isEqualToString:@"BOTTOM_RIGHT"]) {
		return GADAdChoicesPositionBottomRightCorner;
	} else if ([value isEqualToString:@"BOTTOM_LEFT"]) {
		return GADAdChoicesPositionBottomLeftCorner;
	} else {
		// TOP_RIGHT is the SDK default; emit a warning only for genuinely unknown strings.
		if (![value isEqualToString:@"TOP_RIGHT"]) {
			os_log_error(
					admob_log, "LoadAdRequest parseAdChoicesPlacement: unknown value '%@', using TOP_RIGHT", value);
		}
		return GADAdChoicesPositionTopRightCorner;
	}
}

- (UIViewContentMode)parseImageContentMode:(NSString *)value {
	// Mapping from Android ImageView.ScaleType names to the closest UIViewContentMode.
	// FIT_CENTER and CENTER_INSIDE both map to ScaleAspectFit since iOS has a
	// single "fit-within-bounds" content mode.  MATRIX and FIT_START have no
	// direct iOS equivalent; TopLeft is the closest available option.
	if ([value isEqualToString:@"FIT_XY"]) {
		return UIViewContentModeScaleToFill;
	} else if ([value isEqualToString:@"CENTER_CROP"]) {
		return UIViewContentModeScaleAspectFill;
	} else if ([value isEqualToString:@"CENTER_INSIDE"]) {
		return UIViewContentModeScaleAspectFit;
	} else if ([value isEqualToString:@"CENTER"]) {
		return UIViewContentModeCenter;
	} else if ([value isEqualToString:@"FIT_END"]) {
		return UIViewContentModeBottomRight;
	} else if ([value isEqualToString:@"FIT_START"] || [value isEqualToString:@"MATRIX"]) {
		return UIViewContentModeTopLeft;
	} else {
		// FIT_CENTER is the default; warn only for genuinely unknown strings.
		if (![value isEqualToString:@"FIT_CENTER"]) {
			os_log_error(
					admob_log, "LoadAdRequest parseImageContentMode: unknown value '%@', using ScaleAspectFit", value);
		}
		return UIViewContentModeScaleAspectFit;
	}
}

@end
