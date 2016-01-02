//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UIView+Markup.h"

#import <objc/message.h>

@implementation UIView (Markup)

- (CGFloat)width
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(width));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setWidth:(CGFloat)width
{
    NSAssert(isnan(width) || width >= 0, @"Invalid width.");

    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(width));

    [constraint setActive:NO];

    if (!isnan(width)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:width];
    }

    [constraint setPriority:UILayoutPriorityRequired];
    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(width), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minimumWidth
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumWidth));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMinimumWidth:(CGFloat)minimumWidth
{
    NSAssert(isnan(minimumWidth) || minimumWidth >= 0, @"Invalid minimum width.");

    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumWidth));

    [constraint setActive:NO];

    if (!isnan(minimumWidth)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:minimumWidth];
    }

    [constraint setPriority:UILayoutPriorityRequired];
    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(minimumWidth), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maximumWidth
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumWidth));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMaximumWidth:(CGFloat)maximumWidth
{
    NSAssert(isnan(maximumWidth) || maximumWidth >= 0, @"Invalid maximum width.");

    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumWidth));

    [constraint setActive:NO];

    if (!isnan(maximumWidth)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:maximumWidth];
    }

    [constraint setPriority:UILayoutPriorityRequired];
    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(maximumWidth), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)height
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(height));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setHeight:(CGFloat)height
{
    NSAssert(isnan(height) || height >= 0, @"Invalid height.");

    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(height));

    [constraint setActive:NO];

    if (!isnan(height)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:height];
    }

    [constraint setPriority:UILayoutPriorityRequired];
    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(height), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minimumHeight
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumHeight));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMinimumHeight:(CGFloat)minimumHeight
{
    NSAssert(isnan(minimumHeight) || minimumHeight >= 0, @"Invalid minimum height.");

    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumHeight));

    [constraint setActive:NO];

    if (!isnan(minimumHeight)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:minimumHeight];
    }

    [constraint setPriority:UILayoutPriorityRequired];
    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(minimumHeight), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maximumHeight
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumHeight));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMaximumHeight:(CGFloat)maximumHeight
{
    NSAssert(isnan(maximumHeight) || maximumHeight >= 0, @"Invalid maximum height.");

    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumHeight));

    [constraint setActive:NO];

    if (!isnan(maximumHeight)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:maximumHeight];
    }

    [constraint setPriority:UILayoutPriorityRequired];
    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(maximumHeight), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)weight
{
    NSNumber *weight = objc_getAssociatedObject(self, @selector(weight));

    return (weight == nil) ? NAN : [weight floatValue];
}

- (void)setWeight:(CGFloat)weight
{
    NSAssert(isnan(weight) || weight > 0, @"Invalid weight.");
    
    objc_setAssociatedObject(self, @selector(weight), isnan(weight) ? nil : [NSNumber numberWithFloat:weight],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
}

- (CGFloat)horizontalContentCompressionResistancePriority
{
    return [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setHorizontalContentCompressionResistancePriority:(CGFloat)priority
{
    [self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisHorizontal];
}

- (CGFloat)horizontalContentHuggingPriority
{
    return [self contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setHorizontalContentHuggingPriority:(CGFloat)priority
{
    [self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisHorizontal];
}

- (CGFloat)verticalContentCompressionResistancePriority
{
    return [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical];
}

- (void)setVerticalContentCompressionResistancePriority:(CGFloat)priority
{
    [self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisVertical];
}

- (CGFloat)verticalContentHuggingPriority
{
    return [self contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];
}

- (void)setVerticalContentHuggingPriority:(CGFloat)priority
{
    [self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisVertical];
}

- (CGFloat)layoutMarginTop
{
    return [self layoutMargins].top;
}

- (void)setLayoutMarginTop:(CGFloat)top
{
    UIEdgeInsets layoutMargins = [self layoutMargins];

    layoutMargins.top = top;

    [self setLayoutMargins:layoutMargins];
}

- (CGFloat)layoutMarginLeft
{
    return [self layoutMargins].left;
}

- (void)setLayoutMarginLeft:(CGFloat)left
{
    UIEdgeInsets layoutMargins = [self layoutMargins];

    layoutMargins.left = left;

    [self setLayoutMargins:layoutMargins];
}

- (CGFloat)layoutMarginBottom
{
    return [self layoutMargins].bottom;
}

- (void)setLayoutMarginBottom:(CGFloat)bottom
{
    UIEdgeInsets layoutMargins = [self layoutMargins];

    layoutMargins.bottom = bottom;

    [self setLayoutMargins:layoutMargins];
}

- (CGFloat)layoutMarginRight
{
    return [self layoutMargins].right;
}

- (void)setLayoutMarginRight:(CGFloat)right
{
    UIEdgeInsets layoutMargins = [self layoutMargins];

    layoutMargins.right = right;

    [self setLayoutMargins:layoutMargins];
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    // No-op
}

- (void)processMarkupElement:(NSString *)tag properties:(NSDictionary *)properties
{
    // No-op
}

- (void)appendMarkupElementView:(UIView *)view
{
    // No-op
}

@end
