//
// © 2024-present https://github.com/cengiz-pz
//

#import <UIKit/UIKit.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>

@interface UMPOrientationWrapper : UIViewController

@property (nonatomic, strong) UMPConsentForm * _Nullable wrappedForm;
@property (nonatomic, copy) void (^ _Nullable presentationCompletion)(NSError * _Nullable error);

@end
