//
// © 2024-present https://github.com/cengiz-pz
//

#import "mediation_network_factory.h"

#import "google_mediation_network.h"
#import "applovin_mediation_network.h"
#import "chartboost_mediation_network.h"
#import "dtexchange_mediation_network.h"
#import "imobile_mediation_network.h"
#import "inmobi_mediation_network.h"
#import "ironsource_mediation_network.h"
#import "liftoff_mediation_network.h"
#import "line_mediation_network.h"
#import "maio_mediation_network.h"
#import "meta_mediation_network.h"
#import "mintegral_mediation_network.h"
#import "moloco_mediation_network.h"
#import "mytarget_mediation_network.h"
#import "pangle_mediation_network.h"
#import "unity_mediation_network.h"

static NSString *const CLASS_NAME = @"MediationNetworkFactory";
static NSString *const LOG_TAG = @"godot::AdmobPlugin::MediationNetworkFactory";

@implementation MediationNetworkFactory

+ (MediationNetwork *)createNetwork:(NSString *)networkTag {
	NSString *tag = [[networkTag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
	
	static NSDictionary<NSString *, MediationNetwork* (^)(void)> *networkFactoryMap = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		networkFactoryMap = @{
			GoogleMediationNetwork.TAG: ^{ return [[GoogleMediationNetwork alloc] init]; },
			ApplovinMediationNetwork.TAG: ^{ return [[ApplovinMediationNetwork alloc] init]; },
			ChartboostMediationNetwork.TAG: ^{ return [[ChartboostMediationNetwork alloc] init]; },
			DtexchangeMediationNetwork.TAG: ^{ return [[DtexchangeMediationNetwork alloc] init]; },
			ImobileMediationNetwork.TAG: ^{ return [[ImobileMediationNetwork alloc] init]; },
			InmobiMediationNetwork.TAG: ^{ return [[InmobiMediationNetwork alloc] init]; },
			IronsourceMediationNetwork.TAG: ^{ return [[IronsourceMediationNetwork alloc] init]; },
			LiftoffMediationNetwork.TAG: ^{ return [[LiftoffMediationNetwork alloc] init]; },
			LineMediationNetwork.TAG: ^{ return [[LineMediationNetwork alloc] init]; },
			MaioMediationNetwork.TAG: ^{ return [[MaioMediationNetwork alloc] init]; },
			MetaMediationNetwork.TAG: ^{ return [[MetaMediationNetwork alloc] init]; },
			MintegralMediationNetwork.TAG: ^{ return [[MintegralMediationNetwork alloc] init]; },
			MolocoMediationNetwork.TAG: ^{ return [[MolocoMediationNetwork alloc] init]; },
			MytargetMediationNetwork.TAG: ^{ return [[MytargetMediationNetwork alloc] init]; },
			PangleMediationNetwork.TAG: ^{ return [[PangleMediationNetwork alloc] init]; },
			UnityMediationNetwork.TAG: ^{ return [[UnityMediationNetwork alloc] init]; }
		};
	});
	
	MediationNetwork* (^supplier)(void) = networkFactoryMap[tag];
	if (!supplier) {
		NSLog(@"%@:: Invalid or unsupported network tag '%@'. Unable to create network object.", LOG_TAG, networkTag);
		return nil;
	}
	
	return supplier();
}

+ (NSString *)getTagForAdapterClass:(NSString *)adapterClass {
	NSString *className = [adapterClass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	static NSDictionary<NSString *, NSString *> *adapterMap = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		adapterMap = @{
			GoogleMediationNetwork.ADAPTER_CLASS: GoogleMediationNetwork.TAG,
			ApplovinMediationNetwork.ADAPTER_CLASS: ApplovinMediationNetwork.TAG,
			ChartboostMediationNetwork.ADAPTER_CLASS: ChartboostMediationNetwork.TAG,
			DtexchangeMediationNetwork.ADAPTER_CLASS: DtexchangeMediationNetwork.TAG,
			ImobileMediationNetwork.ADAPTER_CLASS: ImobileMediationNetwork.TAG,
			InmobiMediationNetwork.ADAPTER_CLASS: InmobiMediationNetwork.TAG,
			IronsourceMediationNetwork.ADAPTER_CLASS: IronsourceMediationNetwork.TAG,
			LiftoffMediationNetwork.ADAPTER_CLASS: LiftoffMediationNetwork.TAG,
			LineMediationNetwork.ADAPTER_CLASS: LineMediationNetwork.TAG,
			MaioMediationNetwork.ADAPTER_CLASS: MaioMediationNetwork.TAG,
			MetaMediationNetwork.ADAPTER_CLASS: MetaMediationNetwork.TAG,
			MintegralMediationNetwork.ADAPTER_CLASS: MintegralMediationNetwork.TAG,
			MolocoMediationNetwork.ADAPTER_CLASS: MolocoMediationNetwork.TAG,
			MytargetMediationNetwork.ADAPTER_CLASS: MytargetMediationNetwork.TAG,
			PangleMediationNetwork.ADAPTER_CLASS: PangleMediationNetwork.TAG,
			UnityMediationNetwork.ADAPTER_CLASS: UnityMediationNetwork.TAG
		};
	});
	
	return adapterMap[className];
}

@end
