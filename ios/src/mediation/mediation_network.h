//
// © 2024-present https://github.com/cengiz-pz
//

#ifndef mediation_network_h
#define mediation_network_h

#import <Foundation/Foundation.h>

#import <objc/message.h>

/**
 * Returns the Objective-C Class corresponding to the given string name.
 * Throws an NSInvalidArgumentException if the Class is not found.
 */
static inline Class ClassOrThrow(NSString *className) {
	Class c = NSClassFromString(className);
	if (!c) {
		NSString *reason = [NSString stringWithFormat:@"Required Class '%@' not found.", className];
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
	}
	return c;
}

/**
 * Returns the Objective-C SEL (selector) corresponding to the given string name.
 * Throws an NSInvalidArgumentException if the SEL is not found (i.e., is NULL).
 */
static inline SEL SelectorOrThrow(NSString *selectorName) {
	// NSSelectorFromString returns NULL (0) if the selector is not found/registered.
	SEL s = NSSelectorFromString(selectorName);
	if (!s) {
		NSString *reason = [NSString stringWithFormat:@"Required Selector '%@' not found/registered.", selectorName];
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
	}
	return s;
}

/**
 * Retrieves the Objective-C SEL (selector) corresponding to the given string name
 * AND ensures that the provided object (or Class) responds to that selector.
 * @param selectorName The string representation of the selector (e.g., @"myMethod:").
 * @param target A Class object or an instance object to check for the selector.
 * @return The valid SEL.
 * Throws an NSInvalidArgumentException if the SEL is invalid or the target does not respond to it.
 */
static inline SEL SelectorForClassOrThrow(NSString *selectorName, id target) {
	// 1. Check if the selector string corresponds to a registered SEL.
	// NSSelectorFromString returns NULL (0) if the selector is not found/registered.
	SEL s = NSSelectorFromString(selectorName);
	if (!s) {
		NSString *reason = [NSString stringWithFormat:
			@"Required Selector string '%@' could not be resolved to a valid SEL.",
			selectorName
		];
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
	}

	// 2. Check if the target object/class responds to the selector.
	// This handles both class methods (if 'target' is a Class) and instance methods (if 'target' is an instance).
	if (![target respondsToSelector:s]) {
		NSString *targetDescription = [target class] == target ?
									 NSStringFromClass((Class)target) :
									 NSStringFromClass([target class]);

		NSString *reason = [NSString stringWithFormat:
			@"Target '%@' does not respond to the required Selector: '%@'.",
			targetDescription,
			selectorName
		];
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
	}

	return s;
}

/**
 * Retrieves a value from a Class using Key-Value Coding (KVC) and throws
 * an NSInvalidArgumentException if the resulting value is nil.
 * * @param targetClass The Class object to query (e.g., [SomeClass class]).
 * @param key The property name string (e.g., @"PAGPAConsentTypeConsent").
 * @return The retrieved non-nil id value.
 */
static inline id ClassValueOrThrow(Class targetClass, NSString *key) {
	// We are calling valueForKey: on the Class object itself to get a class property.
	id value = [targetClass valueForKey:key];

	if (value == nil) {
		NSString *reason = [NSString stringWithFormat:
			@"Required value for key '%@' on Class '%@' was nil.",
			key,
			NSStringFromClass(targetClass)
		];
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
	}
	return value;
}


@class PrivacySettings;

@interface MediationNetwork : NSObject

@property (nonatomic, strong) NSString *tag;

- (instancetype)initWithTag:(NSString *)tag;

- (NSString *)getAdapterClassName;

- (void)applyGDPRSettings:(BOOL)hasGdprConsent;

- (void)applyAgeRestrictedUserSettings:(BOOL)isAgeRestrictedUser;

- (void)applyCCPASettings:(BOOL)hasCcpaConsent;

- (void)applyPrivacySettings:(PrivacySettings *)settings;

@end

#endif /* mediation_network_h */
