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

#import "LMViewBuilder.h"
#import "UIView+Markup.h"

#import <objc/message.h>

static NSString * const kNormalSizeClass = @"normal";
static NSString * const kHorizontalSizeClass = @"horizontal";
static NSString * const kVerticalSizeClass = @"vertical";
static NSString * const kMinimalSizeClass = @"minimal";

static NSString * const kSizeClassFormat = @"%@~%@";
static NSString * const kFileExtension = @"xml";

static NSString * const kPropertiesTarget = @"properties";

static NSString * const kRootTag = @"root";
static NSString * const kFactoryKey = @"style";
static NSString * const kTemplateKey = @"class";

static NSString * const kOutletKey = @"id";
static NSString * const kActionPrefix = @"on";

static NSString * const kLocalizedStringPrefix = @"@";

static NSDictionary *fontTextStyles;

static NSDictionary *viewContentModeValues;
static NSDictionary *tintAdjustmentModeValues;
static NSDictionary *controlContentHorizontalAlignmentValues;
static NSDictionary *controlContentVerticalAlignmentValues;
static NSDictionary *lineBreakModeValues;
static NSDictionary *textAlignmentValues;
static NSDictionary *textBorderStyleValues;
static NSDictionary *textFieldViewModeValues;
static NSDictionary *textAutocapitalizationTypeValues;
static NSDictionary *textAutocorrectionTypeValues;
static NSDictionary *textSpellCheckingTypeValues;
static NSDictionary *keyboardAppearanceValues;
static NSDictionary *keyboardTypeValues;
static NSDictionary *returnKeyTypeValues;
static NSDictionary *datePickerModeValues;
static NSDictionary *activityIndicatorViewStyleValues;
static NSDictionary *tableViewCellSeparatorStyleValues;
static NSDictionary *tableViewCellAccessoryTypeValues;
static NSDictionary *tableViewCellSelectionStyleValues;

// TODO
/*
webPaginationBreakingMode
webPaginationMode
barStyle
searchBarStyle
layoutConstraintAxis
stackViewAlignment
stackViewDistribution
*/

static NSDictionary *layoutPriorities;

@interface LMViewBuilder () <NSXMLParserDelegate>

@end

@implementation LMViewBuilder
{
    id _owner;
    UIView *_root;

    NSMutableDictionary *_properties;

    NSMutableArray *_views;
}

+ (void)initialize
{
    fontTextStyles = @{
        @"title1": UIFontTextStyleTitle1,
        @"title2": UIFontTextStyleTitle2,
        @"title3": UIFontTextStyleTitle3,
        @"headline": UIFontTextStyleHeadline,
        @"subheadline": UIFontTextStyleSubheadline,
        @"body": UIFontTextStyleBody,
        @"footnote": UIFontTextStyleFootnote,
        @"caption1": UIFontTextStyleCaption1,
        @"caption2": UIFontTextStyleCaption2
    };

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

    tintAdjustmentModeValues = @{
        @"automatic": @(UIViewTintAdjustmentModeAutomatic),
        @"normal": @(UIViewTintAdjustmentModeNormal),
        @"dimmed": @(UIViewTintAdjustmentModeDimmed)
    };

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

    keyboardAppearanceValues = @{
        @"default": @(UIKeyboardAppearanceDefault),
        @"dark": @(UIKeyboardAppearanceDark),
        @"light": @(UIKeyboardAppearanceLight)
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

    datePickerModeValues = @{
        @"time": @(UIDatePickerModeTime),
        @"date": @(UIDatePickerModeDate),
        @"dateAndTime": @(UIDatePickerModeDateAndTime),
        @"countDownTimer": @(UIDatePickerModeCountDownTimer)
    };

    activityIndicatorViewStyleValues = @{
        @"whiteLarge": @(UIActivityIndicatorViewStyleWhiteLarge),
        @"white": @(UIActivityIndicatorViewStyleWhite),
        @"gray": @(UIActivityIndicatorViewStyleGray)
    };

    tableViewCellSeparatorStyleValues = @{
        @"none": @(UITableViewCellSeparatorStyleNone),
        @"singleLine": @(UITableViewCellSeparatorStyleSingleLine),
        @"singleLineEtched": @(UITableViewCellSeparatorStyleSingleLineEtched)
    };

    tableViewCellAccessoryTypeValues = @{
        @"none": @(UITableViewCellAccessoryNone),
        @"disclosureIndicator": @(UITableViewCellAccessoryDisclosureIndicator),
        @"detailDisclosureButton": @(UITableViewCellAccessoryDetailDisclosureButton),
        @"checkmark": @(UITableViewCellAccessoryCheckmark),
        @"detailButton": @(UITableViewCellAccessoryDetailButton)
    };

    tableViewCellSelectionStyleValues = @{
        @"none": @(UITableViewCellSelectionStyleNone),
        @"blue": @(UITableViewCellSelectionStyleBlue),
        @"gray": @(UITableViewCellSelectionStyleGray),
        @"default": @(UITableViewCellSelectionStyleDefault)
    };

    layoutPriorities = @{
        @"required": @(UILayoutPriorityRequired),
        @"defaultHigh": @(UILayoutPriorityDefaultHigh),
        @"defaultLow": @(UILayoutPriorityDefaultLow),
        @"fittingSizeLevel": @(UILayoutPriorityFittingSizeLevel)
    };
}

+ (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root
{
    NSBundle *mainBundle = [NSBundle mainBundle];

    NSURL *url = nil;

    if ([owner conformsToProtocol:@protocol(UITraitEnvironment)]) {
        UITraitCollection *traitCollection = [owner traitCollection];

        UIUserInterfaceSizeClass horizontalSizeClass = [traitCollection horizontalSizeClass];
        UIUserInterfaceSizeClass verticalSizeClass = [traitCollection verticalSizeClass];

        NSString *sizeClass;
        if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            sizeClass = kNormalSizeClass;
        } else if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            sizeClass = kHorizontalSizeClass;
        } else if (horizontalSizeClass == UIUserInterfaceSizeClassCompact && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            sizeClass = kVerticalSizeClass;
        } else {
            sizeClass = kMinimalSizeClass;
        }

        url = [mainBundle URLForResource:[NSString stringWithFormat:kSizeClassFormat, name, sizeClass] withExtension:kFileExtension];
    }

    if (url == nil) {
        url = [mainBundle URLForResource:name withExtension:kFileExtension];
    }

    UIView *view = nil;

    if (url != nil) {
        LMViewBuilder *viewBuilder = [[LMViewBuilder alloc] initWithOwner:owner root:root];

        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];

        [parser setDelegate:viewBuilder];
        [parser parse];

        view = [viewBuilder root];
    }

    return view;
}

+ (UIColor *)colorValue:(NSString *)value
{
    UIColor *color = nil;

    if ([value hasPrefix:@"#"]) {
        if ([value length] < 9) {
            value = [NSString stringWithFormat:@"%@ff", value];
        }

        if ([value length] == 9) {
            int red, green, blue, alpha;
            sscanf([value UTF8String], "#%02X%02X%02X%02X", &red, &green, &blue, &alpha);

            color = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
        }
    }

    return color;
}

+ (UIFont *)fontValue:(NSString *)value
{
    UIFont *font = nil;

    NSString *fontTextStyle = [fontTextStyles objectForKey:value];

    if (fontTextStyle != nil) {
        font = [UIFont preferredFontForTextStyle:fontTextStyle];
    } else {
        NSArray *components = [value componentsSeparatedByString:@" "];

        if ([components count] == 2) {
            NSString *fontName = [components objectAtIndex:0];
            CGFloat fontSize = [[components objectAtIndex:1] floatValue];

            if ([fontName isEqual:@"System"]) {
                font = [UIFont systemFontOfSize:fontSize];
            } else if ([fontName isEqual:@"System-Bold"]) {
                font = [UIFont boldSystemFontOfSize:fontSize];
            } else if ([fontName isEqual:@"System-Italic"]) {
                font = [UIFont italicSystemFontOfSize:fontSize];
            } else {
                font = [UIFont fontWithName:fontName size:fontSize];
            }
        }
    }

    return font;
}

+ (void)applyPropertyValues:(NSDictionary *)properties toView:(UIView *)view
{
    for (NSString *path in properties) {
        id value = [properties objectForKey:path];

        // TODO Continue if value is nil?

        // TODO Trim string values?

        NSRange keyDelimiterRange = [path rangeOfString:@"." options:NSBackwardsSearch];

        NSString *key = (keyDelimiterRange.location == NSNotFound) ? path : [path substringFromIndex:keyDelimiterRange.location + 1];

        if ([key isEqual:@"contentMode"]) {
            // Translate to view content mode
            value = [viewContentModeValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"tintAdjustmentMode"]) {
            // Translate to tint adjustment mode
            value = [tintAdjustmentModeValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"contentHorizontalAlignment"]) {
            // Translate to control content horizontal alignment
            value = [controlContentHorizontalAlignmentValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"contentVerticalAlignment"]) {
            // Translate to control content vertical alignment
            value = [controlContentVerticalAlignmentValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"lineBreakMode"]) {
            // Translate to line break mode
            value = [lineBreakModeValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"textAlignment"]) {
            // Translate value to text alignment
            value = [textAlignmentValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"borderStyle"]) {
            // Translate to text border style
            value = [textBorderStyleValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"clearButtonMode"] || [key isEqual:@"leftViewMode"] || [key isEqual:@"rightViewMode"]) {
            // Translate to text field view mode
            value = [textFieldViewModeValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"autocapitalizationType"]) {
            // Translate to auto-capitalization type
            value = [textAutocapitalizationTypeValues objectForKey:value];

            // Property is not KVC-compliant
            if (value != nil) {
                [(UIView<UITextInputTraits> *)view setAutocapitalizationType:[value integerValue]];
            }

            continue;
        } else if ([key isEqual:@"autocorrectionType"]) {
            // Translate to auto-correction type
            value = [textAutocorrectionTypeValues objectForKey:value];

            // Property is not KVC-compliant
            if (value != nil) {
                [(UIView<UITextInputTraits> *)view setAutocorrectionType:[value integerValue]];
            }

            continue;
        } else if ([key isEqual:@"spellCheckingType"]) {
            // Translate to spell checking type
            value = [textSpellCheckingTypeValues objectForKey:value];

            // Property is not KVC-compliant
            if (value != nil) {
                [(UIView<UITextInputTraits> *)view setSpellCheckingType:[value integerValue]];
            }

            continue;
        } else if ([key isEqual:@"keyboardAppearance"]) {
            // Translate to keyboard appearance
            value = [keyboardAppearanceValues objectForKey:value];

            // Property is not KVC-compliant
            if (value != nil) {
                [(UIView<UITextInputTraits> *)view setKeyboardAppearance:[value integerValue]];
            }

            continue;
        } else if ([key isEqual:@"keyboardType"]) {
            // Translate to keyboard type
            value = [keyboardTypeValues objectForKey:value];

            // Property is not KVC-compliant
            if (value != nil) {
                [(UIView<UITextInputTraits> *)view setKeyboardType:[value integerValue]];
            }

            continue;
        } else if ([key isEqual:@"returnKeyType"]) {
            // Translate to return key type
            value = [returnKeyTypeValues objectForKey:value];

            // Property is not KVC-compliant
            if (value != nil) {
                [(UIView<UITextInputTraits> *)view setReturnKeyType:[value integerValue]];
            }

            continue;
        } else if ([key isEqual:@"datePickerMode"]) {
            // Translate to date picker mode
            value = [datePickerModeValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"activityIndicatorViewStyle"]) {
            // Translate to activity indicator view style
            value = [activityIndicatorViewStyleValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"separatorStyle"]) {
            // Translate to table view cell separator style
            value = [tableViewCellSeparatorStyleValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"accessoryType"]) {
            // Translate to table view cell accessory type
            value = [tableViewCellAccessoryTypeValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"selectionStyle"]) {
            // Translate to table view cell selection style
            value = [tableViewCellSelectionStyleValues objectForKey:value];

            if (value == nil) {
                continue;
            }
        } else if ([key isEqual:@"dataDetectorTypes"]) {
            // Translate to data detector types
            UIDataDetectorTypes dataDetectorTypes;
            if ([value isEqual:@"none"]) {
                dataDetectorTypes = UIDataDetectorTypeNone;
            } else if ([value isEqual:@"all"]) {
                dataDetectorTypes = UIDataDetectorTypeAll;
            } else {
                NSArray *components = [value componentsSeparatedByString:@"|"];

                dataDetectorTypes = 0;

                for (NSString *component in components) {
                    NSString *name = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                    if ([name isEqual:@"phoneNumber"]) {
                        dataDetectorTypes |= UIDataDetectorTypePhoneNumber;
                    } else if ([name isEqual:@"link"]) {
                        dataDetectorTypes |= UIDataDetectorTypeLink;
                    } else if ([name isEqual:@"address"]) {
                        dataDetectorTypes |= UIDataDetectorTypeAddress;
                    } else if ([name isEqual:@"calendarEvent"]) {
                        dataDetectorTypes |= UIDataDetectorTypeCalendarEvent;
                    } else {
                        continue;
                    }
                }
            }

            value = [NSNumber numberWithUnsignedInteger:dataDetectorTypes];
        } else if ([key isEqual:@"paginationBreakingMode"]) {
            // Translate to web pagination breaking mode
            UIWebPaginationBreakingMode webPaginationBreakingMode;
            if ([value isEqual:@"page"]) {
                webPaginationBreakingMode = UIWebPaginationBreakingModePage;
            } else if ([value isEqual:@"column"]) {
                webPaginationBreakingMode = UIWebPaginationBreakingModeColumn;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:webPaginationBreakingMode];
        } else if ([key isEqual:@"paginationMode"]) {
            // Translate to web pagination mode
            UIWebPaginationMode webPaginationMode;
            if ([value isEqual:@"unpaginated"]) {
                webPaginationMode = UIWebPaginationModeUnpaginated;
            } else if ([value isEqual:@"leftToRight"]) {
                webPaginationMode = UIWebPaginationModeLeftToRight;
            } else if ([value isEqual:@"topToBottom"]) {
                webPaginationMode = UIWebPaginationModeTopToBottom;
            } else if ([value isEqual:@"bottomToTop"]) {
                webPaginationMode = UIWebPaginationModeBottomToTop;
            } else if ([value isEqual:@"rightToLeft"]) {
                webPaginationMode = UIWebPaginationModeRightToLeft;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:webPaginationMode];
        } else if ([key isEqual:@"barStyle"]) {
            // Translate to bar style
            UIBarStyle barStyle;
            if ([value isEqual:@"default"]) {
                barStyle = UIBarStyleDefault;
            } else if ([value isEqual:@"black"]) {
                barStyle = UIBarStyleBlack;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:barStyle];
        } else if ([key isEqual:@"searchBarStyle"]) {
            // Translate to search bar style
            UISearchBarStyle searchBarStyle;
            if ([value isEqual:@"default"]) {
                searchBarStyle = UISearchBarStyleDefault;
            } else if ([value isEqual:@"prominent"]) {
                searchBarStyle = UISearchBarStyleProminent;
            } else if ([value isEqual:@"minimal"]) {
                searchBarStyle = UISearchBarStyleMinimal;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:searchBarStyle];
        } else if ([key isEqual:@"axis"]) {
            // Translate to layout constraint axis
            UILayoutConstraintAxis layoutConstraintAxis;
            if ([value isEqual:@"horizontal"]) {
                layoutConstraintAxis = UILayoutConstraintAxisHorizontal;
            } else if ([value isEqual:@"vertical"]) {
                layoutConstraintAxis = UILayoutConstraintAxisVertical;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:layoutConstraintAxis];
        } else if ([key isEqual:@"alignment"]) {
            // Translate to stack view alignment
            UIStackViewAlignment stackViewAlignment;
            if ([value isEqual:@"fill"]) {
                stackViewAlignment = UIStackViewAlignmentFill;
            } else if ([value isEqual:@"leading"]) {
                stackViewAlignment = UIStackViewAlignmentLeading;
            } else if ([value isEqual:@"top"]) {
                stackViewAlignment = UIStackViewAlignmentTop;
            } else if ([value isEqual:@"firstBaseline"]) {
                stackViewAlignment = UIStackViewAlignmentFirstBaseline;
            } else if ([value isEqual:@"center"]) {
                stackViewAlignment = UIStackViewAlignmentCenter;
            } else if ([value isEqual:@"trailing"]) {
                stackViewAlignment = UIStackViewAlignmentTrailing;
            } else if ([value isEqual:@"bottom"]) {
                stackViewAlignment = UIStackViewAlignmentBottom;
            } else if ([value isEqual:@"lastBaseline"]) {
                stackViewAlignment = UIStackViewAlignmentLastBaseline;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:stackViewAlignment];
        } else if ([key isEqual:@"distribution"]) {
            // Translate to stack view distribution
            UIStackViewDistribution stackViewDistribution;
            if ([value isEqual:@"fill"]) {
                stackViewDistribution = UIStackViewDistributionFill;
            } else if ([value isEqual:@"fillEqually"]) {
                stackViewDistribution = UIStackViewDistributionFillEqually;
            } else if ([value isEqual:@"fillProportionally"]) {
                stackViewDistribution = UIStackViewDistributionFillProportionally;
            } else if ([value isEqual:@"equalSpacing"]) {
                stackViewDistribution = UIStackViewDistributionEqualSpacing;
            } else if ([value isEqual:@"equalCentering"]) {
                stackViewDistribution = UIStackViewDistributionEqualSpacing;
            } else {
                continue;
            }

            value = [NSNumber numberWithInt:stackViewDistribution];
        } else if ([key rangeOfString:@"[Cc]olor$" options:NSRegularExpressionSearch].location != NSNotFound) {
            // Parse color specification
            UIColor *color;
            if ([value isKindOfClass:[NSString self]]) {
                color = [LMViewBuilder colorValue:value];
            } else {
                color = nil;
            }

            if (color == nil) {
                continue;
            }

            if ([path hasPrefix:@"layer"]) {
                value = (id)[color CGColor];
            } else {
                value = color;
            }
        } else if ([key rangeOfString:@"[Ff]ont$" options:NSRegularExpressionSearch].location != NSNotFound) {
            // Parse font specification
            UIFont *font;
            if ([value isKindOfClass:[NSString self]]) {
                font = [LMViewBuilder fontValue:value];
            } else {
                font = nil;
            }

            if (font == nil) {
                continue;
            }

            value = font;
        } else if ([key rangeOfString:@"[Ii]mage$" options:NSRegularExpressionSearch].location != NSNotFound) {
            // Load named image
            UIImage *image;
            if ([value isKindOfClass:[NSString self]]) {
                image = [UIImage imageNamed:value];
            } else {
                image = nil;
            }

            if (image == nil) {
                continue;
            }

            value = image;
        } else if ([key rangeOfString:@"^(?:horizontal|vertical)Content(?:CompressionResistance|Hugging)Priority$"
            options:NSRegularExpressionSearch].location != NSNotFound) {
            // Translate to layout priority
            NSNumber *layoutPriority = [layoutPriorities objectForKey:value];

            if (layoutPriority != nil) {
                value = layoutPriority;
            }
        } else if ([key isEqual:@"layoutMargins"] || [key rangeOfString:@"^*Insets?$"
            options:NSRegularExpressionSearch].location != NSNotFound) {
            // Create edge insets from value
            CGFloat inset = [value floatValue];

            value = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        }

        [view setValue:value forKeyPath:path];
    }
}

- (instancetype)init
{
    return nil;
}

- (instancetype)initWithOwner:(id)owner root:(UIView *)root
{
    self = [super init];

    if (self) {
        _owner = owner;
        _root = root;

        _properties = [NSMutableDictionary new];

        _views = [NSMutableArray new];
    }

    return self;
}

- (UIView *)root
{
    return _root;
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    if ([_views count] == 0) {
        if ([target isEqual:kPropertiesTarget]) {
            // Load properties
            NSDictionary *properties = nil;

            NSError *error = nil;

            if ([data hasPrefix:@"{"]) {
                properties = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                    options:0 error:&error];
            } else {
                NSString *path = [[NSBundle mainBundle] pathForResource:data ofType:@"json"];

                if (path != nil) {
                    properties = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                        options:0 error:&error];
                }
            }

            if (error != nil) {
                NSDictionary *userInfo = [error userInfo];

                [NSException raise:NSGenericException format:@"Error reading properties: \"%@\"",
                    [userInfo objectForKey:@"NSDebugDescription"]];
            }

            for (NSString *key in properties) {
                NSMutableDictionary *template = (NSMutableDictionary *)[_properties objectForKey:key];

                if (template == nil) {
                    template = [NSMutableDictionary new];

                    [_properties setObject:template forKey:key];
                }

                [template addEntriesFromDictionary:(NSDictionary *)[properties objectForKey:key]];
            }
        }
    } else {
        // Notify view
        id view = [_views lastObject];

        if ([view isKindOfClass:[UIView self]]) {
            [view processMarkupInstruction:target data:data];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributes
{
    NSString *factory = nil;
    NSString *template = nil;
    NSString *outlet = nil;
    NSMutableDictionary *actions = [NSMutableDictionary new];
    NSMutableDictionary *properties = [NSMutableDictionary new];

    for (NSString *key in attributes) {
        NSString *value = [attributes objectForKey:key];

        if ([key isEqual:kFactoryKey]) {
            factory = value;
        } else if ([key isEqual:kTemplateKey]) {
            template = value;
        } else if ([key isEqual:kOutletKey]) {
            outlet = value;
        } else if ([key hasPrefix:kActionPrefix] && [key length] > [kActionPrefix length]
            && ![key isEqual:@"onTintColor"]) {
            [actions setObject:value forKey:key];
        } else {
            if ([value hasPrefix:kLocalizedStringPrefix]) {
                value = [[NSBundle mainBundle] localizedStringForKey:[value substringFromIndex:[kLocalizedStringPrefix length]]
                    value:nil table:nil];
            }

            [properties setObject:value forKey:key];
        }
    }

    // Determine element type
    Class type;
    if ([_views count] == 0 && [elementName isEqual:kRootTag]) {
        if (_root == nil) {
            [NSException raise:NSGenericException format:@"Root view is not defined."];
        }

        type = [_root class];
    } else {
        type = NSClassFromString(elementName);
    }

    if (type == nil) {
        // Notify view
        if ([_views count] > 0) {
            id view = [_views lastObject];

            if ([view isKindOfClass:[UIView self]]) {
                [view processMarkupElement:elementName properties:properties];
            }
        }

        [_views addObject:[NSNull null]];
    } else {
        // Create view
        UIView *view;
        if ([_views count] == 0 && _root != nil) {
            view = _root;
        } else {
            if (![type isSubclassOfClass:[UIView self]]) {
                [NSException raise:NSGenericException format:@"<%@> is not a valid element type.", elementName];
            }

            if (factory != nil) {
                SEL selector = NSSelectorFromString(factory);
                IMP method = [type methodForSelector:selector];
                id (*function)(id, SEL) = (void *)method;

                view = function(type, selector);
            } else {
                view = [type new];
            }

            if (view == nil) {
                [NSException raise:NSGenericException format:@"Unable to instantiate element <%@>.", elementName];
            }
        }

        // Set outlet value
        if (outlet != nil) {
            [_owner setValue:view forKey:outlet];
        }

        // Apply template properties
        if (template != nil) {
            NSArray *components = [template componentsSeparatedByString:@","];

            for (NSString *component in components) {
                NSString *key = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                [LMViewBuilder applyPropertyValues:[_properties objectForKey:key] toView:view];
            }
        }

        // Apply instance properties
        [LMViewBuilder applyPropertyValues:properties toView:view];

        // Add action handlers
        for (NSString *key in actions) {
            NSString *name = [key substringFromIndex:[kActionPrefix length]];

            UIControlEvents controlEvents;
            if ([name isEqual:@"TouchDown"]) {
                controlEvents = UIControlEventTouchDown;
            } else if ([name isEqual:@"TouchDownRepeat"]) {
                controlEvents = UIControlEventTouchDownRepeat;
            } else if ([name isEqual:@"TouchDragInside"]) {
                controlEvents = UIControlEventTouchDragInside;
            } else if ([name isEqual:@"TouchDragOutside"]) {
                controlEvents = UIControlEventTouchDragOutside;
            } else if ([name isEqual:@"TouchDragEnter"]) {
                controlEvents = UIControlEventTouchDragEnter;
            } else if ([name isEqual:@"TouchDragExit"]) {
                controlEvents = UIControlEventTouchDragExit;
            } else if ([name isEqual:@"TouchUpInside"]) {
                controlEvents = UIControlEventTouchUpInside;
            } else if ([name isEqual:@"TouchUpOutside"]) {
                controlEvents = UIControlEventTouchUpOutside;
            } else if ([name isEqual:@"TouchCancel"]) {
                controlEvents = UIControlEventTouchCancel;
            } else if ([name isEqual:@"ValueChanged"]) {
                controlEvents = UIControlEventValueChanged;
            } else if ([name isEqual:@"EditingDidBegin"]) {
                controlEvents = UIControlEventEditingDidBegin;
            } else if ([name isEqual:@"EditingChanged"]) {
                controlEvents = UIControlEventEditingChanged;
            } else if ([name isEqual:@"EditingDidEnd"]) {
                controlEvents = UIControlEventEditingDidEnd;
            } else if ([name isEqual:@"EditingDidEndOnExit"]) {
                controlEvents = UIControlEventEditingDidEndOnExit;
            } else if ([name isEqual:@"AllTouchEvents"]) {
                controlEvents = UIControlEventAllTouchEvents;
            } else if ([name isEqual:@"AllEditingEvents"]) {
                controlEvents = UIControlEventAllEditingEvents;
            } else if ([name isEqual:@"AllEvents"]) {
                controlEvents = UIControlEventAllEvents;
            } else {
                continue;
            }

            SEL action = NSSelectorFromString([actions objectForKey:key]);
            
            [(UIControl *)view addTarget:_owner action:action forControlEvents:controlEvents];
        }

        // Push onto view stack
        [_views addObject:view];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Pop from view stack
    id view = [_views lastObject];

    [_views removeLastObject];

    if ([_views count] > 0) {
        // Add to superview
        if ([view isKindOfClass:[UIView self]]) {
            id superview = [_views lastObject];
            
            if ([superview isKindOfClass:[UIView self]]) {
                [superview appendMarkupElementView:view];
            }
        }
    } else {
        // Set root view
        if ([view isKindOfClass:[UIView self]]) {
            _root = view;
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error
{
    NSDictionary *userInfo = [error userInfo];

    [NSException raise:NSGenericException format:@"A parse error occurred at line %d, column %d.",
        [[userInfo objectForKey:@"NSXMLParserErrorLineNumber"] intValue],
        [[userInfo objectForKey:@"NSXMLParserErrorColumn"] intValue]];
}

@end
