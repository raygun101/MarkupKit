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
{
    UIView *_contentElementView;

    NSArray *_layoutConstraints;
}

- (void)updateConstraints
{
    if (_layoutConstraints == nil) {
        NSMutableArray *layoutConstraints = nil;

        if (_contentElementView != nil) {
            layoutConstraints = [NSMutableArray new];

            UIView *contentView = [self contentView];

            // Align content element view edges to content view edges
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentElementView attribute:NSLayoutAttributeTop
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTopMargin
                multiplier:1 constant:0]];
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentElementView attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottomMargin
                multiplier:1 constant:0]];

            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentElementView attribute:NSLayoutAttributeLeft
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeftMargin
                multiplier:1 constant:0]];
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentElementView attribute:NSLayoutAttributeRight
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRightMargin
                multiplier:1 constant:0]];

            // Add constraints
            [contentView addConstraints:layoutConstraints];
        }

        _layoutConstraints = layoutConstraints;
    }

    [super updateConstraints];
}

- (void)appendMarkupElementView:(UIView *)view
{
    [[self contentView] addSubview:view];

    [view setTranslatesAutoresizingMaskIntoConstraints:NO];

    _contentElementView = view;

    [self setNeedsUpdateConstraints];
}

@end
