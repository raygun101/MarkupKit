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

- (void)appendMarkupElementView:(UIView *)view
{
    // No-op
}

@end
