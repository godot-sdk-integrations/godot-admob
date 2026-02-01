//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef admob_ad_info_h
#define admob_ad_info_h

#import <Foundation/Foundation.h>


@interface AdmobAdInfo : NSObject

@property (nonatomic) NSInteger measuredWidth;
@property (nonatomic) NSInteger measuredHeight;
@property (nonatomic) BOOL isCollapsible;


- (NSString*) adUnitId;

@end

#endif /* admob_ad_info_h */
