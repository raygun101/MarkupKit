//
//  UIViewController+Markup.h
//  MarkupKit
//
//  Created by Greg Brown on 10/30/15.
//  Copyright © 2015 Greg Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Markup)

/**
 * Notifies a presenting controller that a presented controller can be dismissed.
 *
 * @param viewController The presented view controller.
 * @param cancelled A flag indicating that the controller was cancelled.
 */
- (void)presentationComplete:(UIViewController *)viewController cancelled:BOOL;

@end
