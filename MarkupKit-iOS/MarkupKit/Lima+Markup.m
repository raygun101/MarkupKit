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

#import "Foundation+Markup.h"
#import "UIKit+Markup.h"
#import "Lima+Markup.h"

#import <objc/message.h>

@implementation LMLayoutView (Markup)

- (void)appendMarkupElementView:(UIView *)view
{
    [self addSubview:view];
}

@end

@implementation LMBoxView (Markup)

static NSDictionary *horizontalAlignmentValues;
static NSDictionary *verticalAlignmentValues;

+ (void)initialize
{
    horizontalAlignmentValues = @{
        @"fill": @(LMHorizontalAlignmentFill),
        @"leading": @(LMHorizontalAlignmentLeading),
        @"trailing": @(LMHorizontalAlignmentTrailing),
        @"center": @(LMHorizontalAlignmentCenter)
    };

    verticalAlignmentValues = @{
        @"fill": @(LMVerticalAlignmentFill),
        @"top": @(LMVerticalAlignmentTop),
        @"bottom": @(LMVerticalAlignmentBottom),
        @"center": @(LMVerticalAlignmentCenter)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"horizontalAlignment"]) {
        value = [horizontalAlignmentValues objectForKey:value];
    } else if ([key isEqual:@"verticalAlignment"]) {
        value = [verticalAlignmentValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation LMRowView (Markup)

static NSDictionary *baselineValues;

+ (void)initialize
{
    baselineValues = @{
        @"first": @(LMBaselineFirst),
        @"last": @(LMBaselineLast)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"baseline"]) {
        value = [baselineValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation LMScrollView (Markup)

- (UIView *)contentView
{
    return [self content];
}

- (void)setContentView:(UIView *)contentView
{
    [self setContent:contentView];
}

- (void)appendMarkupElementView:(UIView *)view
{
    [self setContent:view];
}

@end

static NSString * const kBackgroundViewTarget = @"backgroundView";
static NSString * const kSelectedBackgroundViewTarget = @"selectedBackgroundView";
static NSString * const kMultipleSelectionBackgroundViewTarget = @"multipleSelectionBackgroundView";

typedef enum {
    kTableViewCellElementDefault,
    kTableViewCellElementBackgroundView,
    kTableViewCellElementSelectedBackgroundView,
    kTableViewCellElementMultipleSelectionBackgroundView
} __LMTableViewCellElementDisposition;

@implementation LMTableViewCell (Markup)

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    __LMTableViewCellElementDisposition elementDisposition;
    if ([target isEqual:kBackgroundViewTarget]) {
        elementDisposition = kTableViewCellElementBackgroundView;
    } else if ([target isEqual:kSelectedBackgroundViewTarget]) {
        elementDisposition = kTableViewCellElementSelectedBackgroundView;
    } else if ([target isEqual:kMultipleSelectionBackgroundViewTarget]) {
        elementDisposition = kTableViewCellElementMultipleSelectionBackgroundView;
    } else {
        elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }

    objc_setAssociatedObject(self, @encode(__LMTableViewCellElementDisposition),
        [NSNumber numberWithInt:elementDisposition],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSNumber *elementDisposition = objc_getAssociatedObject(self, @encode(__LMTableViewCellElementDisposition));

    if (elementDisposition == nil) {
        elementDisposition = @(kTableViewCellElementDefault);
    }

    switch ([elementDisposition intValue]) {
        case kTableViewCellElementDefault: {
            [self setContent:view ignoreMargins:NO];

            break;
        }

        case kTableViewCellElementBackgroundView: {
            [self setBackgroundView:view];

            break;
        }

        case kTableViewCellElementSelectedBackgroundView: {
            [self setSelectedBackgroundView:view];

            break;
        }

        case kTableViewCellElementMultipleSelectionBackgroundView: {
            [self setMultipleSelectionBackgroundView:view];

            break;
        }

        default: {
            [super appendMarkupElementView:view];

            break;
        }
    }

    objc_setAssociatedObject(self, @encode(__LMTableViewCellElementDisposition),
        nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

typedef enum {
    kTableViewHeaderFooterViewElementDefault,
    kTableViewHeaderFooterViewElementBackgroundView
} __LMTableViewHeaderFooterViewElementDisposition;

@implementation LMTableViewHeaderFooterView (Markup)

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    __LMTableViewHeaderFooterViewElementDisposition elementDisposition;
    if ([target isEqual:kBackgroundViewTarget]) {
        elementDisposition = kTableViewHeaderFooterViewElementBackgroundView;
    } else {
        elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }

    objc_setAssociatedObject(self, @encode(__LMTableViewHeaderFooterViewElementDisposition),
        [NSNumber numberWithInt:elementDisposition],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSNumber *elementDisposition = objc_getAssociatedObject(self, @encode(__LMTableViewHeaderFooterViewElementDisposition));

    if (elementDisposition == nil) {
        elementDisposition = @(kTableViewHeaderFooterViewElementDefault);
    }

    switch ([elementDisposition intValue]) {
        case kTableViewHeaderFooterViewElementDefault: {
            [self setContent:view ignoreMargins:NO];

            break;
        }

        case kTableViewHeaderFooterViewElementBackgroundView: {
            [self setBackgroundView:view];

            break;
        }

        default: {
            [super appendMarkupElementView:view];

            break;
        }
    }

    objc_setAssociatedObject(self, @encode(__LMTableViewHeaderFooterViewElementDisposition),
        nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

typedef enum {
    kCollectionViewCellElementDefault,
    kCollectionViewCellElementBackgroundView,
    kCollectionViewCellElementSelectedBackgroundView
} __LMCollectionViewCellElementDisposition;

@implementation LMCollectionViewCell (Markup)

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    __LMCollectionViewCellElementDisposition elementDisposition;
    if ([target isEqual:kBackgroundViewTarget]) {
        elementDisposition = kCollectionViewCellElementBackgroundView;
    } else if ([target isEqual:kSelectedBackgroundViewTarget]) {
        elementDisposition = kCollectionViewCellElementSelectedBackgroundView;
    } else {
        elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }

    objc_setAssociatedObject(self, @encode(__LMCollectionViewCellElementDisposition),
        [NSNumber numberWithInt:elementDisposition],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSNumber *elementDisposition = objc_getAssociatedObject(self, @encode(__LMTableViewHeaderFooterViewElementDisposition));

    if (elementDisposition == nil) {
        elementDisposition = @(kCollectionViewCellElementDefault);
    }

    switch ([elementDisposition intValue]) {
        case kCollectionViewCellElementDefault: {
            [self setContent:view];

            break;
        }

        case kCollectionViewCellElementBackgroundView: {
            [self setBackgroundView:view];

            break;
        }

        case kCollectionViewCellElementSelectedBackgroundView: {
            [self setSelectedBackgroundView:view];

            break;
        }

        default: {
            [super appendMarkupElementView:view];

            break;
        }
    }

    objc_setAssociatedObject(self, @encode(__LMTableViewHeaderFooterViewElementDisposition),
        nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

