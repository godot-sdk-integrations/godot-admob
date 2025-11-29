//
// © 2024-present https://github.com/cengiz-pz
//

#import "ump_orientation_wrapper.h"

@implementation UMPOrientationWrapper

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.wrappedForm) {
		[self.wrappedForm presentFromViewController:self completionHandler:^(NSError * _Nullable error) {
			if (self.presentationCompletion) {
				self.presentationCompletion(error);
			}
			[self dismissViewControllerAnimated:NO completion:nil]; // dismiss wrapper after form
		}];
		self.wrappedForm = nil; // avoid presenting again
	}
	}

@end
