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

#import "LMScrollView.h"

#define DEFAULT_STYLE LMScrollViewStyleDefault

@implementation LMScrollView
{
    NSArray *_layoutConstraints;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;

    if (_contentView != nil) {
        [self addSubview:_contentView];

        [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setFitToWidth:(BOOL)fitToWidth
{
    _fitToWidth = fitToWidth;

    [self setNeedsUpdateConstraints];
}

- (void)setFitToHeight:(BOOL)fitToHeight
{
    _fitToHeight = fitToHeight;

    [self setNeedsUpdateConstraints];
}

- (void)willRemoveSubview:(UIView *)subview
{
    if (subview == _contentView) {
        _contentView = nil;

        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }

    [super willRemoveSubview:subview];
}

- (CGSize)intrinsicContentSize
{
    return (_contentView == nil) ? CGSizeMake(0, 0): [_contentView intrinsicContentSize];
}

- (void)setNeedsUpdateConstraints
{
    if (_layoutConstraints != nil) {
        [self removeConstraints:_layoutConstraints];

        _layoutConstraints = nil;
    }

    [super setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    if (_layoutConstraints == nil) {
        NSMutableArray *layoutConstraints = nil;

        if (_contentView != nil) {
            layoutConstraints = [NSMutableArray new];

            // Align content view edges to scroll view edges
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop
                multiplier:1 constant:0]];
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom
                multiplier:1 constant:0]];

            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft
                multiplier:1 constant:0]];
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight
                multiplier:1 constant:0]];

            // Match content view width/height to scroll view width/height
            if (_fitToWidth) {
                [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeWidth
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth
                    multiplier:1 constant:0]];
            }

            if (_fitToHeight) {
                [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeHeight
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight
                    multiplier:1 constant:0]];
            }

            // Add constraints
            [self addConstraints:layoutConstraints];
        }

        _layoutConstraints = layoutConstraints;
    }

    [super updateConstraints];
}

- (void)appendMarkupElementView:(UIView *)view
{
    [self setContentView:view];
}

@end
