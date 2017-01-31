//
//  UIResponder+Markup.h
//  MarkupKit-iOS
//
//  Created by Greg Brown on 1/31/17.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (Markup)

/**
 * Establishes a two-way binding between this object and an associated view instance.
 *
 * @param property The key path of a property in this object.
 * @param view The associated view instance.
 * @param keyPath The key path of a property in the view.
 */
- (void)bind:(NSString *)property toView:(UIView *)view withKeyPath:(NSString *)keyPath;

/**
 * Releases all bindings.
 */
- (void)unbindAll;

@end

NS_ASSUME_NONNULL_END
