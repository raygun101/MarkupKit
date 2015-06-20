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

#import "LMLayerView.h"

@implementation LMLayerView

- (CGSize)intrinsicContentSize
{
    CGSize size = {0, 0};

    for (UIView * subview in [self arrangedSubviews]) {
        CGSize subviewSize = [subview intrinsicContentSize];

        if (subviewSize.width != UIViewNoIntrinsicMetric) {
            size.width = MAX(size.width, subviewSize.width);
        }

        if (subviewSize.height != UIViewNoIntrinsicMetric) {
            size.height = MAX(size.height, subviewSize.height);
        }
    }

    UIEdgeInsets layoutMargins = [self layoutMargins];

    size.width += layoutMargins.left + layoutMargins.right;
    size.height += layoutMargins.top + layoutMargins.bottom;

    return size;
}

- (void)layoutSubviews
{
    for (UIView * subview in [self arrangedSubviews]) {
        [subview setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [subview setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        [subview setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [subview setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }

    [super layoutSubviews];
}

- (NSArray *)createConstraints
{
    NSMutableArray *constraints = [NSMutableArray new];

    // Align subview edges to layer view edges
    for (UIView *subview in [self arrangedSubviews]) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTopMargin
            multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottomMargin
            multiplier:1 constant:0]];

        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeft
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeftMargin
            multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeRight
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRightMargin
            multiplier:1 constant:0]];
    }

    return constraints;
}

@end
