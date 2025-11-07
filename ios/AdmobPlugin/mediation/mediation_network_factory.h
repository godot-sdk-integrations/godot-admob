//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef mediation_network_factory_h
#define mediation_network_factory_h

#import <Foundation/Foundation.h>

@class MediationNetwork;
@class PrivacySettings;

@interface MediationNetworkFactory : NSObject

+ (MediationNetwork *)createNetwork:(NSString *)networkTag;

@end

#endif /* mediation_network_factory_h */
