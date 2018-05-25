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
#import "UIKit+Markup.h"

static NSString * const kIgnoreLayoutMarginsTarget = @"ignoreLayoutMargins";
static NSString * const kBackgroundViewTarget = @"backgroundView";
static NSString * const kSelectedBackgroundViewTarget = @"selectedBackgroundView";
static NSString * const kMultipleSelectionBackgroundViewTarget = @"multipleSelectionBackgroundView";

typedef enum {
    kElementDefault,
    kElementBackgroundView,
    kElementSelectedBackgroundView,
    kElementMultipleSelectionBackgroundView
} __ElementDisposition;

@implementation LMTableViewCell
{
    BOOL _ignoreLayoutMargins;

    __ElementDisposition _elementDisposition;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == [self contentView] && [self selectionStyle] == UITableViewCellSelectionStyleNone) {
        view = nil;
    }

    return view;
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    if ([target isEqual:kIgnoreLayoutMarginsTarget]) {
        _ignoreLayoutMargins = YES;
    } else if ([target isEqual:kBackgroundViewTarget]) {
        _elementDisposition = kElementBackgroundView;
    } else if ([target isEqual:kSelectedBackgroundViewTarget]) {
        _elementDisposition = kElementSelectedBackgroundView;
    } else if ([target isEqual:kMultipleSelectionBackgroundViewTarget]) {
        _elementDisposition = kElementMultipleSelectionBackgroundView;
    } else {
        _elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }
}

- (void)appendMarkupElementView:(UIView *)view
{
    switch (_elementDisposition) {
        case kElementDefault: {
            [view setTranslatesAutoresizingMaskIntoConstraints:NO];

            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [view setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

            [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

            UIView *contentView = [self contentView];

            [contentView addSubview:view];

            // Pin content to cell edges
            NSLayoutAttribute topAttribute, bottomAttribute, leftAttribute, rightAttribute;
            if (_ignoreLayoutMargins) {
                topAttribute = NSLayoutAttributeTop;
                bottomAttribute = NSLayoutAttributeBottom;
                leftAttribute = NSLayoutAttributeLeft;
                rightAttribute = NSLayoutAttributeRight;
            } else {
                topAttribute = NSLayoutAttributeTopMargin;
                bottomAttribute = NSLayoutAttributeBottomMargin;
                leftAttribute = NSLayoutAttributeLeftMargin;
                rightAttribute = NSLayoutAttributeRightMargin;
            }

            NSMutableArray *constraints = [NSMutableArray new];

            [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:topAttribute
                multiplier:1 constant:0]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:bottomAttribute
                multiplier:1 constant:0]];

            [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:leftAttribute
                multiplier:1 constant:0]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight
                relatedBy:NSLayoutRelationEqual toItem:contentView attribute:rightAttribute
                multiplier:1 constant:0]];

            [NSLayoutConstraint activateConstraints:constraints];

            break;
        }

        case kElementBackgroundView: {
            [self setBackgroundView:view];
            
            break;
        }

        case kElementSelectedBackgroundView: {
            [self setSelectedBackgroundView:view];

            break;
        }

        case kElementMultipleSelectionBackgroundView: {
            [self setMultipleSelectionBackgroundView:view];

            break;
        }

        default: {
            [super appendMarkupElementView:view];

            break;
        }
    }

    _elementDisposition = kElementDefault;
}

@end
