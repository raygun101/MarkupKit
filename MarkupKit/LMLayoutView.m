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

#import "LMLayoutView.h"
#import "UIView+Markup.h"

#define DEFAULT_LAYOUT_MARGINS UIEdgeInsetsZero

@implementation LMLayoutView
{
    NSMutableArray *_arrangedSubviews;

    NSArray *_constraints;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

#define INIT {\
    _arrangedSubviews = [NSMutableArray new];\
    _layoutMarginsRelativeArrangement = YES;\
    [self setLayoutMargins:DEFAULT_LAYOUT_MARGINS];\
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) INIT

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) INIT

    return self;
}

- (void)addArrangedSubview:(UIView *)view
{
    [self insertArrangedSubview:view atIndex:[_arrangedSubviews count]];
}

- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)index
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:view];
    
    [_arrangedSubviews insertObject:view atIndex:index];

    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)removeArrangedSubview:(UIView *)view
{
    [_arrangedSubviews removeObject:view];

    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)setLayoutMarginsRelativeArrangement:(BOOL)layoutMarginsRelativeArrangement
{
    _layoutMarginsRelativeArrangement = layoutMarginsRelativeArrangement;

    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)willRemoveSubview:(UIView *)subview
{
    NSUInteger index = [_arrangedSubviews indexOfObject:subview];

    if (index != NSNotFound) {
        [_arrangedSubviews removeObjectAtIndex:index];

        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }

    [super willRemoveSubview:subview];
}

- (UIView *)viewForBaselineLayout
{
    return ([_arrangedSubviews count] == 0) ? [super viewForBaselineLayout] : [[_arrangedSubviews objectAtIndex:0] viewForBaselineLayout];
}

- (void)setNeedsUpdateConstraints
{
    if (_constraints != nil) {
        [[self constraintRoot] removeConstraints:_constraints];

        _constraints = nil;
    }

    [super setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    if (_constraints == nil) {
        UIView *constraintRoot = [self constraintRoot];

        _constraints = [self createConstraints];

        if (_constraints != nil) {
            [constraintRoot addConstraints:_constraints];
        }
    }

    [super updateConstraints];
}

- (UIView *)constraintRoot
{
    UITableViewCell *tableViewCell = [self tableViewCell];

    return (tableViewCell == nil) ? self : [tableViewCell contentView];
}

- (NSArray *)createConstraints
{
    return nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];

    if (view == self) {
        view = nil;
    }

    return view;
}

- (void)appendMarkupElementView:(UIView *)view
{
    [self addArrangedSubview:view];
}

@end
