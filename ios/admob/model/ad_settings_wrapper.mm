//
// © 2026-present https://github.com/cengiz-pz
//

#import "ad_settings_wrapper.h"

static String const kAdVolumeProperty = "ad_volume";
static String const kAdsAreMutedProperty = "ads_muted";
static String const kApplyAtStartupProperty = "apply_at_startup";

@interface AdSettingsWrapper ()

@property (nonatomic) Dictionary data;

@end

@implementation AdSettingsWrapper

- (instancetype)init {
	self = [super init];
	if (self) {
		_data = Dictionary();
	}
	return self;
}

- (instancetype)initWithData:(Dictionary)data {
	self = [super init];
	if (self) {
		_data = data;
	}
	return self;
}

- (instancetype)initWithAdSettings:(AdSettings *)adSettings {
	self = [super init];
	if (self) {
		_data = Dictionary();
		if (adSettings.adVolume != nil) {
			[self setAdVolume:adSettings.adVolume];
		}
		if (adSettings.areAdsMuted != nil) {
			[self setAdsMuted:[adSettings.areAdsMuted boolValue]];
		}
		if (adSettings.applyAtStartup != nil) {
			[self setApplyAtStartup:[adSettings.applyAtStartup boolValue]];
		}
	}
	return self;
}

- (NSNumber *)getAdVolume {
	NSNumber *volume = @(AdSettings.defaultAdVolume);

	if (self.data.has(kAdVolumeProperty)) {
		volume = @((float)self.data[kAdVolumeProperty]);
	}

	return volume;
}

- (void)setAdVolume:(NSNumber *)volume {
	self.data[kAdVolumeProperty] = [volume floatValue];
}

- (BOOL)areAdsMuted {
	BOOL muted = AdSettings.defaultAdsMuted;

	if (self.data.has(kAdsAreMutedProperty)) {
		muted = (BOOL)self.data[kAdsAreMutedProperty];
	}

	return muted;
}

- (void)setAdsMuted:(BOOL)muted {
	self.data[kAdsAreMutedProperty] = (BOOL)muted;
}

- (BOOL)getApplyAtStartup {
	BOOL apply = AdSettings.defaultApplyAtStartup;

	if (self.data.has(kApplyAtStartupProperty)) {
		apply = (BOOL)self.data[kApplyAtStartupProperty];
	}

	return apply;
}

- (void)setApplyAtStartup:(BOOL)apply {
	self.data[kApplyAtStartupProperty] = (BOOL)apply;
}

- (AdSettings *)createAdSettings {
	NSNumber *volume = nil;
	NSNumber *muted = nil;
	NSNumber *applyAtStartup = nil;
	
	if (self.data.has(kAdVolumeProperty)) {
		volume = @((float)self.data[kAdVolumeProperty]);
	}
	
	if (self.data.has(kAdsAreMutedProperty)) {
		muted = @((BOOL)self.data[kAdsAreMutedProperty]);
	}
	
	if (self.data.has(kApplyAtStartupProperty)) {
		applyAtStartup = @((BOOL)self.data[kApplyAtStartupProperty]);
	}
	
	return [[AdSettings alloc] initWithAdVolume:volume areAdsMuted:muted applyAtStartup:applyAtStartup];
}

- (Dictionary)getRawData {
	return _data;
}

@end
