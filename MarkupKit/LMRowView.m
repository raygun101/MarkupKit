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

#import "LMRowView.h"
#import "LMColumnView.h"
#import "UIView+Markup.h"

@implementation LMRowView

- (void)setAlignToBaseline:(BOOL)alignToBaseline
{
    _alignToBaseline = alignToBaseline;

    [self setNeedsUpdateConstraints];
}

- (CGSize)intrinsicContentSize
{
    CGSize size;
    if (_alignToBaseline) {
        size = CGSizeMake(0, 0);

        CGFloat spacing = [self spacing];

        NSUInteger i = 0;

        for (UIView *subview in _arrangedSubviews) {
            if ([subview isHidden]) {
                continue;
            }

            if (i > 0) {
                size.width += spacing;
            }

            CGFloat width = [subview width];

            CGSize subviewSize;
            if (isnan(width)) {
                subviewSize = [subview intrinsicContentSize];
            } else {
                subviewSize = [subview sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
            }

            if (subviewSize.width != UIViewNoIntrinsicMetric) {
                size.width += subviewSize.width;
            }

            CGFloat height = [subview height];

            if (isnan(height)) {
                height = subviewSize.height;
            }

            if (height != UIViewNoIntrinsicMetric) {
                size.height = MAX(size.height, height);
            }

            i++;
        }

        if ([self layoutMarginsRelativeArrangement]) {
            UIEdgeInsets layoutMargins = [self layoutMargins];

            size.width += layoutMargins.left + layoutMargins.right;
            size.height += layoutMargins.top + layoutMargins.bottom;
        }
    } else {
        size = [super intrinsicContentSize];
    }

    return size;
}

- (void)layoutSubviews
{
    // Ensure that subviews resize according to weight
    UIView *superview = [self superview];

    UILayoutPriority unweightedHorizontalContentHuggingPriority;
    if ([superview isKindOfClass:[LMColumnView self]] && [(LMColumnView *)superview alignToGrid]) {
        unweightedHorizontalContentHuggingPriority = UILayoutPriorityDefaultLow;
    } else {
        unweightedHorizontalContentHuggingPriority = UILayoutPriorityRequired;
    }

    for (UIView * subview in _arrangedSubviews) {
        [subview setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [subview setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

        UILayoutPriority horizontalCompressionResistancePriority, horizontalContentHuggingPriority;
        if (isnan([subview weight])) {
            horizontalCompressionResistancePriority = UILayoutPriorityRequired;
            horizontalContentHuggingPriority = unweightedHorizontalContentHuggingPriority;
        } else {
            horizontalCompressionResistancePriority = UILayoutPriorityDefaultLow;
            horizontalContentHuggingPriority = UILayoutPriorityDefaultLow;
        }

        [subview setContentCompressionResistancePriority:horizontalCompressionResistancePriority forAxis:UILayoutConstraintAxisHorizontal];
        [subview setContentHuggingPriority:horizontalContentHuggingPriority forAxis:UILayoutConstraintAxisHorizontal];
    }

    [super layoutSubviews];
}

- (NSArray *)createConstraints
{
    NSMutableArray *constraints = [NSMutableArray new];

    CGFloat spacing = [self spacing];

    NSLayoutAttribute topAttribute, bottomAttribute, leftAttribute, rightAttribute, leadingAttribute, trailingAttribute;
    if ([self layoutMarginsRelativeArrangement]) {
        topAttribute = NSLayoutAttributeTopMargin;
        bottomAttribute = NSLayoutAttributeBottomMargin;
        leftAttribute = NSLayoutAttributeLeftMargin;
        rightAttribute = NSLayoutAttributeRightMargin;
        leadingAttribute = NSLayoutAttributeLeadingMargin;
        trailingAttribute = NSLayoutAttributeTrailingMargin;
    } else {
        topAttribute = NSLayoutAttributeTop;
        bottomAttribute = NSLayoutAttributeBottom;
        leftAttribute = NSLayoutAttributeLeft;
        rightAttribute = NSLayoutAttributeRight;
        leadingAttribute = NSLayoutAttributeLeading;
        trailingAttribute = NSLayoutAttributeTrailing;
    }

    UIView *previousSubview = nil;
    UIView *previousWeightedSubview = nil;

    for (UIView *subview in _arrangedSubviews) {
        if ([subview isHidden]) {
            continue;
        }

        // Align to siblings
        if (previousSubview == nil) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading
                relatedBy:NSLayoutRelationEqual toItem:self attribute:leadingAttribute
                multiplier:1 constant:0]];
        } else {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading
                relatedBy:NSLayoutRelationEqual toItem:previousSubview attribute:NSLayoutAttributeTrailing
                multiplier:1 constant:spacing]];

            if (_alignToBaseline) {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBaseline
                    relatedBy:NSLayoutRelationEqual toItem:previousSubview attribute:NSLayoutAttributeBaseline
                    multiplier:1 constant:0]];
            }
        }

        CGFloat weight = [subview weight];

        if (!isnan(weight)) {
            if (previousWeightedSubview != nil) {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth
                    relatedBy:NSLayoutRelationEqual toItem:previousWeightedSubview attribute:NSLayoutAttributeWidth
                    multiplier:weight / [previousWeightedSubview weight] constant:0]];
            }

            previousWeightedSubview = subview;
        }

        // Align to parent
        if (_alignToBaseline) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:bottomAttribute
                multiplier:1 constant:0]];
        } else {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop
                relatedBy:NSLayoutRelationEqual toItem:self attribute:topAttribute
                multiplier:1 constant:0]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationEqual toItem:self attribute:bottomAttribute
                multiplier:1 constant:0]];
        }

        previousSubview = subview;
    }

    // Align final view to trailing edge
    if (previousSubview != nil) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:previousSubview attribute:NSLayoutAttributeTrailing
            relatedBy:NSLayoutRelationEqual toItem:self attribute:trailingAttribute
            multiplier:1 constant:0]];
    }

    return constraints;
}

@end
