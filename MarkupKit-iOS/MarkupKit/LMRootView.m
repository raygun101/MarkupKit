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

#import "LMRootView.h"

@implementation LMRootView

- (void)setTopSpacing:(CGFloat)topSpacing
{
    _topSpacing = topSpacing;

    [self setNeedsUpdateConstraints];
}

- (void)setBottomSpacing:(CGFloat)bottomSpacing
{
    _bottomSpacing = bottomSpacing;

    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews
{
    // Ensure that subviews resize
    for (UIView * subview in [self subviews]) {
        if ([subview isHidden]) {
            continue;
        }

        [subview setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [subview setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        [subview setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        [subview setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }

    [super layoutSubviews];
}

- (NSArray *)createConstraints
{
    NSMutableArray *constraints = [NSMutableArray new];

    // Align subview edges to layer view edges
    CGFloat topSpacing = [self topSpacing];
    CGFloat bottomSpacing = [self bottomSpacing];

    for (UIView *subview in [self subviews]) {
        if ([subview isHidden]) {
            continue;
        }

        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop
            multiplier:1 constant:topSpacing]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom
            multiplier:1 constant:-bottomSpacing]];

        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading
            multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTrailing
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing
            multiplier:1 constant:0]];
    }

    return constraints;
}

@end
