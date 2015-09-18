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

#import "LMTableViewCell.h"

@implementation LMTableViewCell

- (void)appendMarkupElementView:(UIView *)view
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];

    [view setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    UIView *contentView = [self contentView];

    [contentView addSubview:view];

    // Pin text field to cell edges
    NSMutableArray *layoutConstraints = [NSMutableArray new];

    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTopMargin
        multiplier:1 constant:0]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottomMargin
        multiplier:1 constant:0]];

    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft
        relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeftMargin
        multiplier:1 constant:0]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight
        relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRightMargin
        multiplier:1 constant:0]];

    [contentView addConstraints:layoutConstraints];
}

@end
