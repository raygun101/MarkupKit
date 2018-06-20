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

#import "UIKit+Markup.h"
#import "Foundation+Markup.h"

#import <objc/message.h>

#import "LMViewBuilder.h"

@interface LMBinding : NSObject

@property (nonatomic, readonly) NSExpression *expression;

@property (weak, nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSString *keyPath;

- (instancetype)initWithExpression:(NSString *)expression view:(UIView *)view keyPath:(NSString *)keyPath;

- (void)bindTo:(id)owner;
- (void)unbindFrom:(id)owner;

@end

@implementation UIResponder (Markup)

- (NSBundle *)bundleForView
{
    return [NSBundle bundleForClass:[self class]];
}

- (NSBundle *)bundleForImages
{
    return [self bundleForView];
}

- (NSBundle *)bundleForStrings
{
    return [self bundleForView];
}

- (NSString *)tableForStrings
{
    return nil;
}

- (nullable NSFormatter *)formatterWithName:(NSString *)name arguments:(NSDictionary<NSString *, id> *)arguments
{
    NSFormatter *formatter;
    if ([name isEqual:@"number"]) {
        formatter = [NSNumberFormatter new];
    } else if ([name isEqual:@"date"]) {
        formatter = [NSDateFormatter new];
    } else if ([name isEqual:@"personNameComponents"]) {
        formatter = [NSPersonNameComponentsFormatter new];
    } else if ([name isEqual:@"byteCount"]) {
        formatter = [NSByteCountFormatter new];
    } else if ([name isEqual:@"measurement"]) {
        formatter = [NSMeasurementFormatter new];
    } else {
        formatter = nil;
    }

    for (NSString *key in arguments) {
        [formatter applyMarkupPropertyValue:[arguments objectForKey:key] forKeyPath:key];
    }

    return formatter;
}

- (void)bind:(NSString *)expression toView:(UIView *)view withKeyPath:(NSString *)keyPath
{
    LMBinding *binding = [[LMBinding alloc] initWithExpression:expression view:view keyPath:keyPath];

    [binding bindTo:self];

    [[self bindings] addObject:binding];
}

- (void)unbindAll
{
    NSMutableArray *bindings = [self bindings];

    for (LMBinding *binding in bindings) {
        [binding unbindFrom:self];
    }

    [bindings removeAllObjects];
}

- (NSMutableArray *)bindings
{
    NSMutableArray *bindings = objc_getAssociatedObject(self, @selector(bindings));

    if (bindings == nil) {
        bindings = [NSMutableArray new];

        objc_setAssociatedObject(self, @selector(bindings), bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return bindings;
}

@end

@implementation LMBinding
{
    NSString *_formatterName;
    NSDictionary *_formatterArguments;
}

- (instancetype)initWithExpression:(NSString *)expression view:(UIView *)view keyPath:(NSString *)keyPath
{
    self = [super init];

    if (self) {
        NSArray *expressionComponents = [expression componentsSeparatedByString:@"::"];

        _expression = [NSExpression expressionWithFormat:expressionComponents[0]];

        if ([expressionComponents count] > 1) {
            NSArray *formatComponents = [expressionComponents[1] componentsSeparatedByString:@";"];

            _formatterName = [formatComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            NSMutableDictionary *formatterArguments = [NSMutableDictionary new];

            for (NSUInteger i = 1, n = [formatComponents count]; i < n; i++) {
                NSArray *argumentComponents = [formatComponents[i] componentsSeparatedByString:@"="];

                if ([argumentComponents count] > 1) {
                    NSString *key = [argumentComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *value = [argumentComponents[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                    [formatterArguments setObject:value forKey:key];
                }
            }

            _formatterArguments = formatterArguments;
        }

        _view = view;
        _keyPath = keyPath;
    }

    return self;
}

- (void)bindTo:(id)owner
{
    [self bindTo:owner expression:_expression];
}

- (void)bindTo:(id)owner expression:(NSExpression *)expression
{
    switch ([expression expressionType]) {
    case NSKeyPathExpressionType:
        [owner addObserver:self forKeyPath:[expression keyPath] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];

        break;

    case NSFunctionExpressionType:
        for (NSExpression *argument in [expression arguments]) {
            [self bindTo:owner expression:argument];
        }

        break;

    default:
        break;
    }
}

- (void)unbindFrom:(id)owner
{
    [self unbindFrom:owner expression:_expression];
}

- (void)unbindFrom:(id)owner expression:(NSExpression *)expression
{
    switch ([expression expressionType]) {
    case NSKeyPathExpressionType:
        [owner removeObserver:self forKeyPath:[expression keyPath] context:nil];

        break;

    case NSFunctionExpressionType:
        for (NSExpression *argument in [expression arguments]) {
            [self unbindFrom:owner expression:argument];
        }

        break;

    default:
        break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id value = [_expression expressionValueWithObject:object context:nil];

    if (value != nil && value != [NSNull null]) {
        if (_formatterName != nil) {
            NSFormatter *formatter = [object formatterWithName:_formatterName arguments:_formatterArguments];

            if (formatter != nil) {
                value = [formatter stringForObjectValue:value];
            }
        }

        [_view setValue:value forKeyPath:_keyPath];
    }
}

@end

@implementation UIGestureRecognizer (Markup)

static NSDictionary *pressTypeValues;
static NSDictionary *touchTypeValues;

+ (void)initialize
{
    pressTypeValues = @{
        @"upArrow": @(UIPressTypeUpArrow),
        @"downArrow": @(UIPressTypeDownArrow),
        @"leftArrow": @(UIPressTypeLeftArrow),
        @"rightArrow": @(UIPressTypeRightArrow),
        @"select": @(UIPressTypeSelect),
        @"menu": @(UIPressTypeMenu),
        @"playPause": @(UIPressTypePlayPause)
    };

    touchTypeValues = @{
        @"direct": @(UITouchTypeDirect),
        @"indirect": @(UITouchTypeIndirect)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"allowedPressTypes"]) {
        NSArray *components = [value componentsSeparatedByString:@","];

        NSMutableArray *allowedPressTypes = [[NSMutableArray alloc] initWithCapacity:[components count]];

        for (NSString *component in components) {
            [allowedPressTypes addObject:[pressTypeValues objectForKey:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        }

        value = allowedPressTypes;
    } else if ([key isEqual:@"allowedTouchTypes"]) {
        NSArray *components = [value componentsSeparatedByString:@","];

        NSMutableArray *allowedTouchTypes = [[NSMutableArray alloc] initWithCapacity:[components count]];

        for (NSString *component in components) {
            [allowedTouchTypes addObject:[touchTypeValues objectForKey:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        }

        value = allowedTouchTypes;
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation UIView (Markup)

static NSDictionary *viewContentModeValues;
static NSDictionary *viewTintAdjustmentModeValues;
static NSDictionary *lineBreakModeValues;
static NSDictionary *textAlignmentValues;
static NSDictionary *textAutocapitalizationTypeValues;
static NSDictionary *textAutocorrectionTypeValues;
static NSDictionary *textSpellCheckingTypeValues;
static NSDictionary *textSmartQuotesTypeValues;
static NSDictionary *textSmartDashesTypeValues;
static NSDictionary *textSmartInsertDeleteTypeValues;
static NSDictionary *keyboardTypeValues;
static NSDictionary *keyboardAppearanceValues;
static NSDictionary *returnKeyTypeValues;
static NSDictionary *barStyleValues;

static NSDictionary *anchorValues;

+ (void)initialize
{
    viewContentModeValues = @{
        @"scaleToFill": @(UIViewContentModeScaleToFill),
        @"scaleAspectFit": @(UIViewContentModeScaleAspectFit),
        @"scaleAspectFill": @(UIViewContentModeScaleAspectFill),
        @"redraw": @(UIViewContentModeRedraw),
        @"center": @(UIViewContentModeCenter),
        @"top": @(UIViewContentModeTop),
        @"bottom": @(UIViewContentModeBottom),
        @"left": @(UIViewContentModeLeft),
        @"right": @(UIViewContentModeRight),
        @"topLeft": @(UIViewContentModeTopLeft),
        @"topRight": @(UIViewContentModeTopRight),
        @"bottomLeft": @(UIViewContentModeBottomLeft),
        @"bottomRight": @(UIViewContentModeBottomRight)
    };

    viewTintAdjustmentModeValues = @{
        @"automatic": @(UIViewTintAdjustmentModeAutomatic),
        @"normal": @(UIViewTintAdjustmentModeNormal),
        @"dimmed": @(UIViewTintAdjustmentModeDimmed)
    };

    lineBreakModeValues = @{
        @"byWordWrapping": @(NSLineBreakByWordWrapping),
        @"byCharWrapping": @(NSLineBreakByCharWrapping),
        @"byClipping": @(NSLineBreakByClipping),
        @"byTruncatingHead": @(NSLineBreakByTruncatingHead),
        @"byTruncatingTail": @(NSLineBreakByTruncatingTail),
        @"byTruncatingMiddle": @(NSLineBreakByTruncatingMiddle)
    };

    textAlignmentValues = @{
        @"left": @(NSTextAlignmentLeft),
        @"center": @(NSTextAlignmentCenter),
        @"right": @(NSTextAlignmentRight),
        @"justified": @(NSTextAlignmentJustified),
        @"natural": @(NSTextAlignmentNatural)
    };

    textAutocapitalizationTypeValues = @{
        @"none": @(UITextAutocapitalizationTypeNone),
        @"words": @(UITextAutocapitalizationTypeWords),
        @"sentences": @(UITextAutocapitalizationTypeSentences),
        @"allCharacters": @(UITextAutocapitalizationTypeAllCharacters)
    };

    textAutocorrectionTypeValues = @{
        @"default": @(UITextAutocorrectionTypeDefault),
        @"yes": @(UITextAutocorrectionTypeYes),
        @"no": @(UITextAutocorrectionTypeNo)
    };

    textSpellCheckingTypeValues = @{
        @"default": @(UITextSpellCheckingTypeDefault),
        @"yes": @(UITextSpellCheckingTypeYes),
        @"no": @(UITextSpellCheckingTypeNo)
    };

    if (@available(iOS 11, tvOS 11, *)) {
        textSmartQuotesTypeValues = @{
            @"default": @(UITextSmartQuotesTypeDefault),
            @"no": @(UITextSmartQuotesTypeNo),
            @"yes": @(UITextSmartQuotesTypeYes)
        };

        textSmartDashesTypeValues = @{
            @"default": @(UITextSmartDashesTypeDefault),
            @"no": @(UITextSmartDashesTypeNo),
            @"yes": @(UITextSmartDashesTypeYes)
        };

        textSmartInsertDeleteTypeValues = @{
            @"default": @(UITextSmartInsertDeleteTypeDefault),
            @"no": @(UITextSmartInsertDeleteTypeNo),
            @"yes": @(UITextSmartInsertDeleteTypeYes)
        };
    };

    keyboardTypeValues = @{
        @"default": @(UIKeyboardTypeDefault),
        @"ASCIICapable": @(UIKeyboardTypeASCIICapable),
        @"numbersAndPunctuation": @(UIKeyboardTypeNumbersAndPunctuation),
        @"URL": @(UIKeyboardTypeURL),
        @"numberPad": @(UIKeyboardTypeNumberPad),
        @"phonePad": @(UIKeyboardTypePhonePad),
        @"namePhonePad": @(UIKeyboardTypeNamePhonePad),
        @"emailAddress": @(UIKeyboardTypeEmailAddress),
        @"decimalPad": @(UIKeyboardTypeDecimalPad),
        @"twitter": @(UIKeyboardTypeTwitter),
        @"webSearch": @(UIKeyboardTypeWebSearch)
    };

    keyboardAppearanceValues = @{
        @"default": @(UIKeyboardAppearanceDefault),
        @"dark": @(UIKeyboardAppearanceDark),
        @"light": @(UIKeyboardAppearanceLight)
    };

    returnKeyTypeValues = @{
        @"default": @(UIReturnKeyDefault),
        @"go": @(UIReturnKeyGo),
        @"google": @(UIReturnKeyGoogle),
        @"join": @(UIReturnKeyJoin),
        @"next": @(UIReturnKeyNext),
        @"route": @(UIReturnKeyRoute),
        @"search": @(UIReturnKeySearch),
        @"send": @(UIReturnKeySend),
        @"yahoo": @(UIReturnKeyYahoo),
        @"done": @(UIReturnKeyDone),
        @"emergencyCall": @(UIReturnKeyEmergencyCall)
    };

    barStyleValues = @{
        #if TARGET_OS_IOS
        @"default": @(UIBarStyleDefault),
        @"black": @(UIBarStyleBlack)
        #endif
    };

    anchorValues = @{
        @"none": @(LMAnchorNone),
        @"top": @(LMAnchorTop),
        @"bottom": @(LMAnchorBottom),
        @"left": @(LMAnchorLeft),
        @"right": @(LMAnchorRight),
        @"leading": @(LMAnchorLeading),
        @"trailing": @(LMAnchorTrailing),
        @"all": @(LMAnchorAll)
    };
}

- (CGFloat)width
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(width));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setWidth:(CGFloat)width
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(width));

    [constraint setActive:NO];

    if (!isnan(width)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:width];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(width), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minimumWidth
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumWidth));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMinimumWidth:(CGFloat)minimumWidth
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumWidth));

    [constraint setActive:NO];

    if (!isnan(minimumWidth)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:minimumWidth];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(minimumWidth), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maximumWidth
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumWidth));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMaximumWidth:(CGFloat)maximumWidth
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumWidth));

    [constraint setActive:NO];

    if (!isnan(maximumWidth)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:maximumWidth];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(maximumWidth), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)height
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(height));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setHeight:(CGFloat)height
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(height));

    [constraint setActive:NO];

    if (!isnan(height)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:height];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(height), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minimumHeight
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumHeight));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMinimumHeight:(CGFloat)minimumHeight
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(minimumHeight));

    [constraint setActive:NO];

    if (!isnan(minimumHeight)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:minimumHeight];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(minimumHeight), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maximumHeight
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumHeight));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setMaximumHeight:(CGFloat)maximumHeight
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(maximumHeight));

    [constraint setActive:NO];

    if (!isnan(maximumHeight)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1 constant:maximumHeight];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(maximumHeight), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)aspectRatio
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(aspectRatio));

    return (constraint == nil) ? NAN : [constraint constant];
}

- (void)setAspectRatio:(CGFloat)aspectRatio
{
    NSLayoutConstraint *constraint = objc_getAssociatedObject(self, @selector(aspectRatio));

    [constraint setActive:NO];

    if (!isnan(aspectRatio)) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight
            multiplier:aspectRatio constant:0];
    } else {
        constraint = nil;
    }

    [constraint setActive:YES];

    objc_setAssociatedObject(self, @selector(aspectRatio), constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)weight
{
    NSNumber *weight = objc_getAssociatedObject(self, @selector(weight));

    return (weight == nil) ? NAN : [weight floatValue];
}

- (void)setWeight:(CGFloat)weight
{
    objc_setAssociatedObject(self, @selector(weight), isnan(weight) ? nil : [NSNumber numberWithFloat:weight],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
}

- (LMAnchor)anchor
{
    NSNumber *anchor = objc_getAssociatedObject(self, @selector(anchor));

    return (anchor == nil) ? 0 : [anchor unsignedIntegerValue];
}

- (void)setAnchor:(LMAnchor)anchor
{
    objc_setAssociatedObject(self, @selector(anchor), [NSNumber numberWithUnsignedInteger:anchor],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
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

- (CGFloat)layoutMarginLeading
{
    CGFloat leading;
    if (@available(iOS 11, tvOS 11, *)) {
        leading = [self directionalLayoutMargins].leading;
    } else {
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:[self semanticContentAttribute]] == UIUserInterfaceLayoutDirectionLeftToRight) {
            leading = [self layoutMargins].left;
        } else {
            leading = [self layoutMargins].right;
        }
    }

    return leading;
}

- (void)setLayoutMarginLeading:(CGFloat)leading
{
    if (@available(iOS 11, tvOS 11, *)) {
        NSDirectionalEdgeInsets directionalLayoutMargins = [self directionalLayoutMargins];

        directionalLayoutMargins.leading = leading;

        [self setDirectionalLayoutMargins:directionalLayoutMargins];
    } else {
        UIEdgeInsets layoutMargins = [self layoutMargins];

        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:[self semanticContentAttribute]] == UIUserInterfaceLayoutDirectionLeftToRight) {
            layoutMargins.left = leading;
        } else {
            layoutMargins.right = leading;
        }

        [self setLayoutMargins:layoutMargins];
    }
}

- (CGFloat)layoutMarginTrailing
{
    CGFloat trailing;
    if (@available(iOS 11, tvOS 11, *)) {
        trailing = [self directionalLayoutMargins].trailing;
    } else {
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:[self semanticContentAttribute]] == UIUserInterfaceLayoutDirectionLeftToRight) {
            trailing = [self layoutMargins].right;
        } else {
            trailing = [self layoutMargins].left;
        }
    }

    return trailing;
}

- (void)setLayoutMarginTrailing:(CGFloat)trailing
{
    if (@available(iOS 11, tvOS 11, *)) {
        NSDirectionalEdgeInsets directionalLayoutMargins = [self directionalLayoutMargins];

        directionalLayoutMargins.trailing = trailing;

        [self setDirectionalLayoutMargins:directionalLayoutMargins];
    } else {
        UIEdgeInsets layoutMargins = [self layoutMargins];

        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:[self semanticContentAttribute]] == UIUserInterfaceLayoutDirectionLeftToRight) {
            layoutMargins.right = trailing;
        } else {
            layoutMargins.left = trailing;
        }

        [self setLayoutMargins:layoutMargins];
    }
}

- (CGFloat)topSpacing
{
    NSNumber *topSpacing = objc_getAssociatedObject(self, @selector(topSpacing));

    return (topSpacing == nil) ? 0 : [topSpacing floatValue];
}

- (void)setTopSpacing:(CGFloat)topSpacing
{
    objc_setAssociatedObject(self, @selector(topSpacing), isnan(topSpacing) ? nil : [NSNumber numberWithFloat:topSpacing],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
}

- (CGFloat)bottomSpacing
{
    NSNumber *bottomSpacing = objc_getAssociatedObject(self, @selector(bottomSpacing));

    return (bottomSpacing == nil) ? 0 : [bottomSpacing floatValue];
}

- (void)setBottomSpacing:(CGFloat)bottomSpacing
{
    objc_setAssociatedObject(self, @selector(bottomSpacing), isnan(bottomSpacing) ? nil : [NSNumber numberWithFloat:bottomSpacing],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
}

- (CGFloat)leadingSpacing
{
    NSNumber *leadingSpacing = objc_getAssociatedObject(self, @selector(leadingSpacing));

    return (leadingSpacing == nil) ? 0 : [leadingSpacing floatValue];
}

- (void)setLeadingSpacing:(CGFloat)leadingSpacing
{
    objc_setAssociatedObject(self, @selector(leadingSpacing), isnan(leadingSpacing) ? nil : [NSNumber numberWithFloat:leadingSpacing],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
}

- (CGFloat)trailingSpacing
{
    NSNumber *trailingSpacing = objc_getAssociatedObject(self, @selector(trailingSpacing));

    return (trailingSpacing == nil) ? 0 : [trailingSpacing floatValue];
}

- (void)setTrailingSpacing:(CGFloat)trailingSpacing
{
    objc_setAssociatedObject(self, @selector(trailingSpacing), isnan(trailingSpacing) ? nil : [NSNumber numberWithFloat:trailingSpacing],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[self superview] setNeedsUpdateConstraints];
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"contentMode"]) {
        value = [viewContentModeValues objectForKey:value];
    } else if ([key isEqual:@"tintAdjustmentMode"]) {
        value = [viewTintAdjustmentModeValues objectForKey:value];
    } else if ([key isEqual:@"lineBreakMode"]) {
        value = [lineBreakModeValues objectForKey:value];
    } else if ([key isEqual:@"textAlignment"]) {
        value = [textAlignmentValues objectForKey:value];
    } else if ([key isEqual:@"autocapitalizationType"]) {
        value = [textAutocapitalizationTypeValues objectForKey:value];

        if (value != nil) {
            [(UIView<UITextInputTraits> *)self setAutocapitalizationType:[value integerValue]];
        }

        return;
    } else if ([key isEqual:@"autocorrectionType"]) {
        value = [textAutocorrectionTypeValues objectForKey:value];

        if (value != nil) {
            [(UIView<UITextInputTraits> *)self setAutocorrectionType:[value integerValue]];
        }

        return;
    } else if ([key isEqual:@"spellCheckingType"]) {
        value = [textSpellCheckingTypeValues objectForKey:value];

        if (value != nil) {
            [(UIView<UITextInputTraits> *)self setSpellCheckingType:[value integerValue]];
        }

        return;
    } else if ([key isEqual:@"smartQuotesType"]) {
        value = [textSmartQuotesTypeValues objectForKey:value];

        if (value != nil) {
            if (@available(iOS 11, tvOS 11, *)) {
                [(UIView<UITextInputTraits> *)self setSmartQuotesType:[value integerValue]];
            }
        }

        return;
    } else if ([key isEqual:@"smartDashesType"]) {
        value = [textSmartDashesTypeValues objectForKey:value];

        if (value != nil) {
            if (@available(iOS 11, tvOS 11, *)) {
                [(UIView<UITextInputTraits> *)self setSmartDashesType:[value integerValue]];
            }
        }

        return;
    } else if ([key isEqual:@"smartInsertDeleteType"]) {
        value = [textSmartInsertDeleteTypeValues objectForKey:value];

        if (value != nil) {
            if (@available(iOS 11, tvOS 11, *)) {
                [(UIView<UITextInputTraits> *)self setSmartInsertDeleteType:[value integerValue]];
            }
        }

        return;
    } else if ([key isEqual:@"keyboardType"]) {
        value = [keyboardTypeValues objectForKey:value];

        if (value != nil) {
            [(UIView<UITextInputTraits> *)self setKeyboardType:[value integerValue]];
        }

        return;
    } else if ([key isEqual:@"keyboardAppearance"]) {
        value = [keyboardAppearanceValues objectForKey:value];

        if (value != nil) {
            [(UIView<UITextInputTraits> *)self setKeyboardAppearance:[value integerValue]];
        }

        return;
    } else if ([key isEqual:@"returnKeyType"]) {
        value = [returnKeyTypeValues objectForKey:value];

        if (value != nil) {
            [(UIView<UITextInputTraits> *)self setReturnKeyType:[value integerValue]];
        }

        return;
    } else if ([key isEqual:@"barStyle"]) {
        value = [barStyleValues objectForKey:value];
    } else if ([key isEqual:@"layoutMargins"] || [key rangeOfString:@"^.*Insets?$"
        options:NSRegularExpressionSearch].location != NSNotFound) {
        CGFloat inset = [value floatValue];

        value = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
    } else if ([key isEqual:@"anchor"]) {
        NSArray *components = [value componentsSeparatedByString:@","];

        LMAnchor anchor = LMAnchorNone;

        for (NSString *component in components) {
            NSString *name = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            anchor |= [[anchorValues objectForKey:name] unsignedIntegerValue];
        }

        value = @(anchor);
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    [NSException raise:NSGenericException format:@"Unexpected instruction in <%@> (\"%@\").",
        NSStringFromClass([self class]), target];
}

- (void)processMarkupElement:(NSString *)tag properties:(NSDictionary *)properties
{
    [NSException raise:NSGenericException format:@"Unexpected element in <%@> (\"%@\").",
        NSStringFromClass([self class]), tag];
}

- (void)appendMarkupElementView:(UIView *)view
{
    [NSException raise:NSGenericException format:@"Unexpected element view in <%@> (<%@>).",
        NSStringFromClass([self class]), NSStringFromClass([view class])];
}

- (void)preview:(NSString *)viewName owner:(nullable id)owner
{
    @try {
        [LMViewBuilder viewWithName:viewName owner:owner root:self];
    }
    @catch (NSException *exception) {
        UILabel *label = [UILabel new];

        [label setText:[exception reason]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setNumberOfLines:0];

        [label setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75]];

        [self addSubview:label];

        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop
                multiplier:1 constant:0],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom
                multiplier:1 constant:0],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading
                multiplier:1 constant:0],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing
                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing
                multiplier:1 constant:0]
        ]];
    }
}

@end

@implementation UIControl (Markup)

static NSDictionary *controlContentHorizontalAlignmentValues;
static NSDictionary *controlContentVerticalAlignmentValues;

+ (void)initialize
{
    controlContentHorizontalAlignmentValues = @{
        @"center": @(UIControlContentHorizontalAlignmentCenter),
        @"left": @(UIControlContentHorizontalAlignmentLeft),
        @"right": @(UIControlContentHorizontalAlignmentRight),
        @"fill": @(UIControlContentHorizontalAlignmentFill)
    };

    controlContentVerticalAlignmentValues = @{
        @"center": @(UIControlContentVerticalAlignmentCenter),
        @"top": @(UIControlContentVerticalAlignmentTop),
        @"bottom": @(UIControlContentVerticalAlignmentBottom),
        @"fill": @(UIControlContentVerticalAlignmentFill)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"contentHorizontalAlignment"]) {
        value = [controlContentHorizontalAlignmentValues objectForKey:value];
    } else if ([key isEqual:@"contentVerticalAlignment"]) {
        value = [controlContentVerticalAlignmentValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation UIButton (Markup)

+ (UIButton *)systemButton
{
    return [UIButton buttonWithType:UIButtonTypeSystem];
}

+ (UIButton *)detailDisclosureButton
{
    return [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
}

+ (UIButton *)infoLightButton
{
    return [UIButton buttonWithType:UIButtonTypeInfoLight];
}

+ (UIButton *)infoDarkButton
{
    return [UIButton buttonWithType:UIButtonTypeInfoDark];
}

+ (UIButton *)contactAddButton
{
    return [UIButton buttonWithType:UIButtonTypeContactAdd];
}

+ (UIButton *)plainButton
{
    return [UIButton buttonWithType:UIButtonTypePlain];
}

- (NSString *)title
{
    return [self titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

- (UIColor *)titleColor
{
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    [self setTitleColor:titleColor forState:UIControlStateNormal];
}

- (UIColor *)titleShadowColor
{
    return [self titleShadowColorForState:UIControlStateNormal];
}

- (void)setTitleShadowColor:(UIColor *)titleShadowColor
{
    [self setTitleShadowColor:titleShadowColor forState:UIControlStateNormal];
}

- (NSAttributedString *)attributedTitle
{
    return [self attributedTitleForState:UIControlStateNormal];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    [self setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

- (UIImage *)image
{
    return [self imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

- (UIImage *)backgroundImage
{
    return [self backgroundImageForState:UIControlStateNormal];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (CGFloat)contentEdgeInsetTop
{
    return [self contentEdgeInsets].top;
}

- (void)setContentEdgeInsetTop:(CGFloat)top
{
    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsets];

    contentEdgeInsets.top = top;

    [self setContentEdgeInsets:contentEdgeInsets];
}

- (CGFloat)contentEdgeInsetLeft
{
    return [self contentEdgeInsets].left;
}

- (void)setContentEdgeInsetLeft:(CGFloat)left
{
    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsets];

    contentEdgeInsets.left = left;

    [self setContentEdgeInsets:contentEdgeInsets];
}

- (CGFloat)contentEdgeInsetBottom
{
    return [self contentEdgeInsets].bottom;
}

- (void)setContentEdgeInsetBottom:(CGFloat)bottom
{
    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsets];

    contentEdgeInsets.bottom = bottom;

    [self setContentEdgeInsets:contentEdgeInsets];
}

- (CGFloat)contentEdgeInsetRight
{
    return [self contentEdgeInsets].right;
}

- (void)setContentEdgeInsetRight:(CGFloat)right
{
    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsets];

    contentEdgeInsets.right = right;

    [self setContentEdgeInsets:contentEdgeInsets];
}

- (CGFloat)titleEdgeInsetTop
{
    return [self titleEdgeInsets].top;
}

- (void)setTitleEdgeInsetTop:(CGFloat)top
{
    UIEdgeInsets titleEdgeInsets = [self titleEdgeInsets];

    titleEdgeInsets.top = top;

    [self setTitleEdgeInsets:titleEdgeInsets];
}

- (CGFloat)titleEdgeInsetLeft
{
    return [self titleEdgeInsets].left;
}

- (void)setTitleEdgeInsetLeft:(CGFloat)left
{
    UIEdgeInsets titleEdgeInsets = [self titleEdgeInsets];

    titleEdgeInsets.left = left;

    [self setTitleEdgeInsets:titleEdgeInsets];
}

- (CGFloat)titleEdgeInsetBottom
{
    return [self titleEdgeInsets].bottom;
}

- (void)setTitleEdgeInsetBottom:(CGFloat)bottom
{
    UIEdgeInsets titleEdgeInsets = [self titleEdgeInsets];

    titleEdgeInsets.bottom = bottom;

    [self setTitleEdgeInsets:titleEdgeInsets];
}

- (CGFloat)titleEdgeInsetRight
{
    return [self titleEdgeInsets].right;
}

- (void)setTitleEdgeInsetRight:(CGFloat)right
{
    UIEdgeInsets titleEdgeInsets = [self titleEdgeInsets];

    titleEdgeInsets.right = right;

    [self setTitleEdgeInsets:titleEdgeInsets];
}

- (CGFloat)imageEdgeInsetTop
{
    return [self imageEdgeInsets].top;
}

- (void)setImageEdgeInsetTop:(CGFloat)top
{
    UIEdgeInsets imageEdgeInsets = [self imageEdgeInsets];

    imageEdgeInsets.top = top;

    [self setImageEdgeInsets:imageEdgeInsets];
}

- (CGFloat)imageEdgeInsetLeft
{
    return [self imageEdgeInsets].left;
}

- (void)setImageEdgeInsetLeft:(CGFloat)left
{
    UIEdgeInsets imageEdgeInsets = [self imageEdgeInsets];

    imageEdgeInsets.left = left;

    [self setImageEdgeInsets:imageEdgeInsets];
}

- (CGFloat)imageEdgeInsetBottom
{
    return [self imageEdgeInsets].bottom;
}

- (void)setImageEdgeInsetBottom:(CGFloat)bottom
{
    UIEdgeInsets imageEdgeInsets = [self imageEdgeInsets];

    imageEdgeInsets.bottom = bottom;

    [self setImageEdgeInsets:imageEdgeInsets];
}

- (CGFloat)imageEdgeInsetRight
{
    return [self imageEdgeInsets].right;
}

- (void)setImageEdgeInsetRight:(CGFloat)right
{
    UIEdgeInsets imageEdgeInsets = [self imageEdgeInsets];

    imageEdgeInsets.right = right;

    [self setImageEdgeInsets:imageEdgeInsets];
}

- (void)appendMarkupElementView:(UIView *)view
{
    if ([self buttonType] == UIButtonTypeCustom) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];

        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        [self addSubview:view];

        // Pin content to button edges
        NSMutableArray *constraints = [NSMutableArray new];

        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTopMargin
            multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottomMargin
            multiplier:1 constant:0]];

        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeftMargin
            multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight
            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRightMargin
            multiplier:1 constant:0]];

        [NSLayoutConstraint activateConstraints:constraints];
    } else {
        [super appendMarkupElementView: view];
    }
}

@end

@implementation UIDatePicker (Markup)

static NSDictionary *datePickerModeValues;

+ (void)initialize
{
    datePickerModeValues = @{
        @"time": @(UIDatePickerModeTime),
        @"date": @(UIDatePickerModeDate),
        @"dateAndTime": @(UIDatePickerModeDateAndTime),
        @"countDownTimer": @(UIDatePickerModeCountDownTimer)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"datePickerMode"]) {
        value = [datePickerModeValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation UISegmentedControl (Markup)

static NSString * const kSegmentTag = @"segment";
static NSString * const kSegmentTitleKey = @"title";
static NSString * const kSegmentImageKey = @"image";
static NSString * const kSegmentValueKey = @"value";

- (id)valueForSegmentAtIndex:(NSUInteger)segment
{
    return nil;
}

- (void)setValue:(id)value forSegmentAtIndex:(NSUInteger)segment
{
    [NSException raise:NSGenericException format:@"Method not implemented."];
}

- (id)value
{
    NSInteger index = [self selectedSegmentIndex];

    return (index == -1) ? nil : [self valueForSegmentAtIndex:index];
}

- (void)setValue:(id)value
{
    NSInteger index = -1;

    if (value != nil) {
        for (NSUInteger i = 0, n = [self numberOfSegments]; i < n; i++) {
            if ([[self valueForSegmentAtIndex:i] isEqual:value]) {
                index = i;

                break;
            }
        }
    }

    [self setSelectedSegmentIndex:index];
}

- (void)processMarkupElement:(NSString *)tag properties:(NSDictionary *)properties
{
    if ([tag isEqual:kSegmentTag]) {
        NSUInteger index = [self numberOfSegments];

        NSString *title = [properties objectForKey:kSegmentTitleKey];

        if (title != nil) {
            [self insertSegmentWithTitle:title atIndex:index animated:NO];
        } else {
            NSString *image = [properties objectForKey:kSegmentImageKey];

            if (image != nil) {
                [self insertSegmentWithImage:[UIImage imageNamed:image] atIndex:index animated:NO];
            }
        }

        if (index < [self numberOfSegments]) {
            id value = [properties objectForKey:kSegmentValueKey];

            if (value != nil) {
                [self setValue:value forSegmentAtIndex:index];
            }
        }
    } else {
        [super processMarkupElement:tag properties:properties];
    }
}

@end

typedef enum {
    kElementLeftView,
    kElementRightView
} __UITextFieldElementDisposition;

@implementation UITextField (Markup)

static NSString * const kLeftViewTarget = @"leftView";
static NSString * const kRightViewTarget = @"rightView";

static NSDictionary *textBorderStyleValues;
static NSDictionary *textFieldViewModeValues;

+ (void)initialize
{
    textBorderStyleValues = @{
        @"none": @(UITextBorderStyleNone),
        @"line": @(UITextBorderStyleLine),
        @"bezel": @(UITextBorderStyleBezel),
        @"roundedRect": @(UITextBorderStyleRoundedRect)
    };

    textFieldViewModeValues = @{
        @"never": @(UITextFieldViewModeNever),
        @"whileEditing": @(UITextFieldViewModeWhileEditing),
        @"unlessEditing": @(UITextFieldViewModeUnlessEditing),
        @"always": @(UITextFieldViewModeAlways)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"borderStyle"]) {
        value = [textBorderStyleValues objectForKey:value];
    } else if ([key isEqual:@"clearButtonMode"] || [key isEqual:@"leftViewMode"] || [key isEqual:@"rightViewMode"]) {
        value = [textFieldViewModeValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    __UITextFieldElementDisposition elementDisposition;
    if ([target isEqual:kLeftViewTarget]) {
        elementDisposition = kElementLeftView;
    } else if ([target isEqual:kRightViewTarget]) {
        elementDisposition = kElementRightView;
    } else {
        elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }

    objc_setAssociatedObject(self, @encode(__UITextFieldElementDisposition), [NSNumber numberWithInt:elementDisposition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSNumber *elementDisposition = objc_getAssociatedObject(self, @encode(__UITextFieldElementDisposition));

    if (elementDisposition != nil) {
        switch ([elementDisposition intValue]) {
            case kElementLeftView: {
                [view sizeToFit];

                [self setLeftView:view];

                break;
            }

            case kElementRightView: {
                [view sizeToFit];

                [self setRightView:view];

                break;
            }

            default: {
                [super appendMarkupElementView:view];

                break;
            }
        }
    }

    objc_setAssociatedObject(self, @encode(__UITextFieldElementDisposition), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIActivityIndicatorView (Markup)

static NSDictionary *activityIndicatorViewStyleValues;

+ (void)initialize
{
    activityIndicatorViewStyleValues = @{
        @"whiteLarge": @(UIActivityIndicatorViewStyleWhiteLarge),
        @"white": @(UIActivityIndicatorViewStyleWhite),
        #if TARGET_OS_IOS
        @"gray": @(UIActivityIndicatorViewStyleGray)
        #endif
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"activityIndicatorViewStyle"]) {
        value = [activityIndicatorViewStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation UILabel (Markup)

- (CGFloat)shadowOffsetWidth
{
    return self.shadowOffset.width;
}

- (void)setShadowOffsetWidth:(CGFloat)width
{
    self.shadowOffset = CGSizeMake(width, self.shadowOffset.height);
}

- (CGFloat)shadowOffsetHeight
{
    return self.shadowOffset.height;
}

- (void)setShadowOffsetHeight:(CGFloat)height
{
    self.shadowOffset = CGSizeMake(self.shadowOffset.width, height);
}

@end

typedef enum {
    kOverlayContent
} __UIImageViewElementDisposition;

@implementation UIImageView (Markup)

static NSString * const kOverlayContentTarget = @"overlayContent";

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    __UIImageViewElementDisposition elementDisposition;
    if ([target isEqual:kOverlayContentTarget]) {
        elementDisposition = kOverlayContent;
    } else {
        elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }

    objc_setAssociatedObject(self, @encode(__UIImageViewElementDisposition), [NSNumber numberWithInt:elementDisposition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSNumber *elementDisposition = objc_getAssociatedObject(self, @encode(__UIImageViewElementDisposition));

    if (elementDisposition != nil) {
        switch ([elementDisposition intValue]) {
            case kOverlayContent: {
                #if TARGET_OS_TV
                if (@available(tvOS 11, *)) {
                    [view setTranslatesAutoresizingMaskIntoConstraints:NO];

                    [view setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
                    [view setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

                    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
                    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

                    UIView *overlayContentView = [self overlayContentView];

                    [overlayContentView addSubview:view];

                    // Pin overlay content to image view edges
                    NSMutableArray *constraints = [NSMutableArray new];

                    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop
                        relatedBy:NSLayoutRelationEqual toItem:overlayContentView attribute:NSLayoutAttributeTopMargin
                        multiplier:1 constant:0]];
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom
                        relatedBy:NSLayoutRelationEqual toItem:overlayContentView attribute:NSLayoutAttributeBottomMargin
                        multiplier:1 constant:0]];

                    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft
                        relatedBy:NSLayoutRelationEqual toItem:overlayContentView attribute:NSLayoutAttributeLeftMargin
                        multiplier:1 constant:0]];
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight
                        relatedBy:NSLayoutRelationEqual toItem:overlayContentView attribute:NSLayoutAttributeRightMargin
                        multiplier:1 constant:0]];

                    [NSLayoutConstraint activateConstraints:constraints];
                }
                #endif

                break;
            }

            default: {
                [super appendMarkupElementView:view];

                break;
            }
        }
    }

    objc_setAssociatedObject(self, @encode(__UIImageViewElementDisposition), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIPickerView (Markup)

- (NSString *)nameForComponent:(NSInteger)component
{
    return nil;
}

- (NSInteger)componentWithName:(NSString *)name
{
    NSInteger component = 0, n = [self numberOfComponents];

    while (component < n) {
        if ([[self nameForComponent:component] isEqual:name]) {
            break;
        }

        component++;
    }

    return (component < n) ? component : NSNotFound;
}

- (id)valueForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (void)setValue:(id)value forRow:(NSInteger)row forComponent:(NSInteger)component
{
    [NSException raise:NSGenericException format:@"Method not implemented."];
}

- (nullable id)valueForComponent:(NSInteger)component
{
    NSInteger row = [self selectedRowInComponent:component];

    return (row == -1) ? nil : [self valueForRow:row forComponent:component];
}

- (void)setValue:(nullable id)value forComponent:(NSInteger)component animated:(BOOL)animated
{
    NSInteger row = -1;

    if (value != nil) {
        for (NSUInteger i = 0, n = [self numberOfRowsInComponent:component]; i < n; i++) {
            if ([[self valueForRow:i forComponent:component] isEqual:value]) {
                row = i;

                break;
            }
        }
    }

    [self selectRow:row inComponent:component animated:animated];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

@end

@implementation UIProgressView (Markup)

+ (UIProgressView *)defaultProgressView
{
    return [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
}

+ (UIProgressView *)barProgressView
{
    return [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
}

@end

@implementation UISearchBar (Markup)

static NSDictionary *searchBarStyleValues;

+ (void)initialize
{
    searchBarStyleValues = @{
        @"default": @(UISearchBarStyleDefault),
        @"prominent": @(UISearchBarStyleProminent),
        @"minimal": @(UISearchBarStyleMinimal)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"searchBarStyle"]) {
        value = [searchBarStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

typedef enum {
    kElementRefreshControl
} __UIScrollViewElementDisposition;

@implementation UIScrollView (Markup)

static NSString * const kRefreshControlTarget = @"refreshControl";

static NSDictionary *scrollViewIndicatorStyleValues;
static NSDictionary *scrollViewKeyboardDismissModeValues;
static NSDictionary *scrollViewContentInsetAdjustmentBehaviorValues;

+ (void)initialize
{
    scrollViewIndicatorStyleValues = @{
        @"default": @(UIScrollViewIndicatorStyleDefault),
        @"black": @(UIScrollViewIndicatorStyleBlack),
        @"white": @(UIScrollViewIndicatorStyleWhite)
    };

    scrollViewKeyboardDismissModeValues = @{
        @"none": @(UIScrollViewKeyboardDismissModeNone),
        @"onDrag": @(UIScrollViewKeyboardDismissModeOnDrag),
        @"interactive": @(UIScrollViewKeyboardDismissModeInteractive)
    };

    if (@available(iOS 11, tvOS 11, *)) {
        scrollViewContentInsetAdjustmentBehaviorValues = @{
            @"automatic": @(UIScrollViewContentInsetAdjustmentAutomatic),
            @"scrollableAxes": @(UIScrollViewContentInsetAdjustmentScrollableAxes),
            @"never": @(UIScrollViewContentInsetAdjustmentNever),
            @"always": @(UIScrollViewContentInsetAdjustmentAlways)
        };
    }
}

- (CGFloat)contentInsetTop
{
    return [self contentInset].top;
}

- (void)setContentInsetTop:(CGFloat)top
{
    UIEdgeInsets contentInset = [self contentInset];

    contentInset.top = top;

    [self setContentInset:contentInset];
}

- (CGFloat)contentInsetLeft
{
    return [self contentInset].left;
}

- (void)setContentInsetLeft:(CGFloat)left
{
    UIEdgeInsets contentInset = [self contentInset];

    contentInset.left = left;

    [self setContentInset:contentInset];
}

- (CGFloat)contentInsetBottom
{
    return [self contentInset].bottom;
}

- (void)setContentInsetBottom:(CGFloat)bottom
{
    UIEdgeInsets contentInset = [self contentInset];

    contentInset.bottom = bottom;

    [self setContentInset:contentInset];
}

- (CGFloat)contentInsetRight
{
    return [self contentInset].right;
}

- (void)setContentInsetRight:(CGFloat)right
{
    UIEdgeInsets contentInset = [self contentInset];

    contentInset.right = right;

    [self setContentInset:contentInset];
}

- (NSInteger)currentPage
{
    return (NSInteger)([self contentOffset].x / [self bounds].size.width);
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated
{
    [self setContentOffset:CGPointMake([self bounds].size.width * currentPage, 0) animated:animated];
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"indicatorStyle"]) {
        value = [scrollViewIndicatorStyleValues objectForKey:value];
    } else if ([key isEqual:@"keyboardDismissMode"]) {
        value = [scrollViewKeyboardDismissModeValues objectForKey:value];
    } else if ([key isEqual:@"contentInsetAdjustmentBehavior"]) {
        value = [scrollViewContentInsetAdjustmentBehaviorValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    __UIScrollViewElementDisposition elementDisposition;
    if ([target isEqual:kRefreshControlTarget]) {
        elementDisposition = kElementRefreshControl;
    } else {
        elementDisposition = INT_MAX;

        [super processMarkupInstruction:target data:data];
    }

    objc_setAssociatedObject(self, @encode(__UIScrollViewElementDisposition), [NSNumber numberWithInt:elementDisposition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSNumber *elementDisposition = objc_getAssociatedObject(self, @encode(__UIScrollViewElementDisposition));

    if (elementDisposition != nil) {
        switch ([elementDisposition intValue]) {
            case kElementRefreshControl: {
                #if TARGET_OS_IOS
                [self setRefreshControl:(UIRefreshControl *)view];
                #endif

                break;
            }

            default: {
                [super appendMarkupElementView:view];

                break;
            }
        }
    }

    objc_setAssociatedObject(self, @encode(__UIScrollViewElementDisposition), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITableView (Markup)

static NSDictionary *tableViewCellSeparatorStyleValues;
static NSDictionary *tableViewSeparatorInsetReferenceValues;

+ (void)initialize
{
    tableViewCellSeparatorStyleValues = @{
        #if TARGET_OS_IOS
        @"none": @(UITableViewCellSeparatorStyleNone),
        @"singleLine": @(UITableViewCellSeparatorStyleSingleLine),
        @"singleLineEtched": @(UITableViewCellSeparatorStyleSingleLineEtched)
        #endif
    };

    if (@available(iOS 11, tvOS 11, *)) {
        tableViewSeparatorInsetReferenceValues = @{
            @"fromCellEdges": @(UITableViewSeparatorInsetFromCellEdges),
            @"fromAutomaticInsets": @(UITableViewSeparatorInsetFromAutomaticInsets)
        };
    }
}

- (NSString *)nameForSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)sectionWithName:(NSString *)name
{
    NSInteger section = 0, n = [self numberOfSections];

    while (section < n) {
        if ([[self nameForSection:section] isEqual:name]) {
            break;
        }

        section++;
    }

    return (section < n) ? section : NSNotFound;
}

- (nullable id)valueForSection:(NSInteger)section
{
    return nil;
}

- (void)setValue:(nullable id)value forSection:(NSInteger)section
{
    [NSException raise:NSGenericException format:@"Method not implemented."];
}

- (NSArray *)valuesForSection:(NSInteger)section
{
    return nil;
}

- (void)setValues:(NSArray *)values forSection:(NSInteger)section
{
    [NSException raise:NSGenericException format:@"Method not implemented."];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"separatorStyle"]) {
        value = [tableViewCellSeparatorStyleValues objectForKey:value];
    } else if ([key isEqual:@"separatorInsetReference"]) {
        value = [tableViewSeparatorInsetReferenceValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation UITableViewCell (Markup)

static NSDictionary *tableViewCellAccessoryTypeValues;
static NSDictionary *tableViewCellSelectionStyleValues;

+ (void)initialize
{
    tableViewCellAccessoryTypeValues = @{
        @"none": @(UITableViewCellAccessoryNone),
        @"disclosureIndicator": @(UITableViewCellAccessoryDisclosureIndicator),
        #if TARGET_OS_IOS
        @"detailDisclosureButton": @(UITableViewCellAccessoryDetailDisclosureButton),
        #endif
        @"checkmark": @(UITableViewCellAccessoryCheckmark),
        #if TARGET_OS_IOS
        @"detailButton": @(UITableViewCellAccessoryDetailButton)
        #endif
    };

    tableViewCellSelectionStyleValues = @{
        @"none": @(UITableViewCellSelectionStyleNone),
        @"default": @(UITableViewCellSelectionStyleDefault)
    };
}

+ (UITableViewCell *)defaultTableViewCell
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

+ (UITableViewCell *)value1TableViewCell
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
}

+ (UITableViewCell *)value2TableViewCell
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
}

+ (UITableViewCell *)subtitleTableViewCell
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
}

- (id)value
{
    return objc_getAssociatedObject(self, @selector(value));
}

- (void)setValue:(id)value
{
    objc_setAssociatedObject(self, @selector(value), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)checked
{
    return ([self accessoryType] == UITableViewCellAccessoryCheckmark);
}

- (void)setChecked:(BOOL)checked
{
    [self setAccessoryType:checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"accessoryType"]) {
        value = [tableViewCellAccessoryTypeValues objectForKey:value];
    } else if ([key isEqual:@"selectionStyle"]) {
        value = [tableViewCellSelectionStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

- (void)appendMarkupElementView:(UIView *)view
{
    [self setAccessoryView:view];

    [view sizeToFit];
}

@end

@implementation UICollectionViewFlowLayout (Markup)

static NSDictionary *collectionViewScrollDirectionValues;
static NSDictionary *collectionViewFlowLayoutSectionInsetReferenceValues;

+ (void)initialize
{
    collectionViewScrollDirectionValues = @{
        @"vertical": @(UICollectionViewScrollDirectionVertical),
        @"horizontal": @(UICollectionViewScrollDirectionHorizontal)
    };

    if (@available(iOS 11, tvOS 11, *)) {
        collectionViewFlowLayoutSectionInsetReferenceValues = @{
            @"fromContentInset": @(UICollectionViewFlowLayoutSectionInsetFromContentInset),
            @"fromSafeArea": @(UICollectionViewFlowLayoutSectionInsetFromSafeArea),
            @"fromLayoutMargins": @(UICollectionViewFlowLayoutSectionInsetFromLayoutMargins)
        };
    }
}

- (CGFloat)itemWidth
{
    return [self itemSize].width;
}

- (void)setItemWidth:(CGFloat)itemWidth
{
    [self setItemSize:CGSizeMake(itemWidth, [self itemSize].height)];
}

- (CGFloat)itemHeight
{
    return [self itemSize].height;
}

- (void)setItemHeight:(CGFloat)itemHeight
{
    [self setItemSize:CGSizeMake([self itemSize].width, itemHeight)];
}

- (CGFloat)estimatedItemWidth
{
    return [self estimatedItemSize].width;
}

- (void)setEstimatedItemWidth:(CGFloat)estimatedItemWidth
{
    [self setEstimatedItemSize:CGSizeMake(estimatedItemWidth, [self estimatedItemSize].height)];
}

- (CGFloat)estimatedItemHeight
{
    return [self estimatedItemSize].height;
}

- (void)setEstimatedItemHeight:(CGFloat)estimatedItemHeight
{
    [self setEstimatedItemSize:CGSizeMake([self estimatedItemSize].width, estimatedItemHeight)];
}

- (CGFloat)sectionInsetTop
{
    return [self sectionInset].top;
}

- (void)setSectionInsetTop:(CGFloat)top
{
    UIEdgeInsets sectionInset = [self sectionInset];

    sectionInset.top = top;

    [self setSectionInset:sectionInset];
}

- (CGFloat)sectionInsetLeft
{
    return [self sectionInset].left;
}

- (void)setSectionInsetLeft:(CGFloat)left
{
    UIEdgeInsets sectionInset = [self sectionInset];

    sectionInset.left = left;

    [self setSectionInset:sectionInset];
}

- (CGFloat)sectionInsetBottom
{
    return [self sectionInset].bottom;
}

- (void)setSectionInsetBottom:(CGFloat)bottom
{
    UIEdgeInsets sectionInset = [self sectionInset];

    sectionInset.bottom = bottom;

    [self setSectionInset:sectionInset];
}

- (CGFloat)sectionInsetRight
{
    return [self sectionInset].right;
}

- (void)setSectionInsetRight:(CGFloat)right
{
    UIEdgeInsets sectionInset = [self sectionInset];

    sectionInset.right = right;

    [self setSectionInset:sectionInset];
}

- (CGFloat)headerReferenceWidth
{
    return [self headerReferenceSize].width;
}

- (void)setHeaderReferenceWidth:(CGFloat)headerReferenceWidth
{
    [self setHeaderReferenceSize:CGSizeMake(headerReferenceWidth, [self headerReferenceSize].height)];
}

- (CGFloat)headerReferenceHeight
{
    return [self headerReferenceSize].height;
}

- (void)setHeaderReferenceHeight:(CGFloat)headerReferenceHeight
{
    [self setHeaderReferenceSize:CGSizeMake([self headerReferenceSize].width, headerReferenceHeight)];
}

- (CGFloat)footerReferenceWidth
{
    return [self footerReferenceSize].width;
}

- (void)setFooterReferenceWidth:(CGFloat)footerReferenceWidth
{
    [self setFooterReferenceSize:CGSizeMake(footerReferenceWidth, [self footerReferenceSize].height)];
}

- (CGFloat)footerReferenceHeight
{
    return [self footerReferenceSize].height;
}

- (void)setFooterReferenceHeight:(CGFloat)footerReferenceHeight
{
    [self setFooterReferenceSize:CGSizeMake([self footerReferenceSize].width, footerReferenceHeight)];
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"scrollDirection"]) {
        value = [collectionViewScrollDirectionValues objectForKey:value];
    } else if ([key isEqual:@"sectionInset"]) {
        CGFloat inset = [value floatValue];

        value = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
    } else if ([key isEqual:@"sectionInsetReference"]) {
        value = [collectionViewFlowLayoutSectionInsetReferenceValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation UIVisualEffectView (Markup)

+ (UIVisualEffectView *)extraLightBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
}

+ (UIVisualEffectView *)lightBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}

+ (UIVisualEffectView *)darkBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
}

+ (UIVisualEffectView *)extraDarkBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraDark]];
}

+ (UIVisualEffectView *)regularBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
}

+ (UIVisualEffectView *)prominentBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
}

@end
