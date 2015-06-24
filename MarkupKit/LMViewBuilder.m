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
#import "LMBoxView.h"
#import "UIView+Markup.h"

static NSString * const LMViewBuilderPropertiesTarget = @"properties";
static NSString * const LMViewBuilderStringsTarget = @"strings";

static NSString * const LMViewBuilderRootTag = @"root";
static NSString * const LMViewBuilderFactoryKey = @"style";
static NSString * const LMViewBuilderTemplateKey = @"class";

static NSString * const LMViewBuilderOutletKey = @"id";
static NSString * const LMViewBuilderActionPrefix = @"on";

static NSString * const LMViewBuilderHexValuePrefix = @"#";

@interface LMViewBuilder () <NSXMLParserDelegate>

@end

@implementation LMViewBuilder
{
    id _owner;
    UIView *_root;

    NSMutableDictionary *_properties;
    NSMutableDictionary *_strings;

    NSMutableArray *_views;
    UIView *_view;
}

+ (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root
{
    LMViewBuilder *viewBuilder = [[LMViewBuilder alloc] initWithOwner:owner root:root];

    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"xml"];

    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
    [parser setDelegate:viewBuilder];
    [parser parse];

    return [viewBuilder view];
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
        _strings = [NSMutableDictionary new];

        _views = [NSMutableArray new];
        _view = nil;
    }

    return self;
}

- (UIView *)view
{
    return _view;
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    if ([_views count] == 0) {
        if ([target isEqual:LMViewBuilderPropertiesTarget]) {
            [self loadProperties:data];
        } else if ([target isEqual:LMViewBuilderStringsTarget]) {
            [self loadStrings:data];
        }
    } else {
        [[_views lastObject] processMarkupInstruction:target data:data];
    }
}

- (void)loadProperties:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];

    if (path != nil) {
        NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:path];

        for (NSString *key in properties) {
            NSMutableDictionary *template = (NSMutableDictionary *)[_properties objectForKey:key];

            if (template == nil) {
                template = [NSMutableDictionary new];

                [_properties setObject:template forKey:key];
            }

            [template addEntriesFromDictionary:(NSDictionary *)[properties objectForKey:key]];
        }
    }
}

- (void)loadStrings:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"strings" inDirectory:nil];

    if (path != nil) {
        NSDictionary *strings = [NSDictionary dictionaryWithContentsOfFile:path];

        [_strings addEntriesFromDictionary:strings];
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

        if ([key isEqual:LMViewBuilderFactoryKey]) {
            factory = value;
        } else if ([key isEqual:LMViewBuilderTemplateKey]) {
            template = value;
        } else if ([key isEqual:LMViewBuilderOutletKey]) {
            outlet = value;
        } else if ([key hasPrefix:LMViewBuilderActionPrefix] && [key length] > [LMViewBuilderActionPrefix length]
            && ![key isEqual:@"onTintColor"]) {
            [actions setObject:value forKey:key];
        } else {
            [properties setObject:value forKey:key];
        }
    }

    // Create view
    if ([elementName isEqual:LMViewBuilderRootTag] && _view == nil) {
        _view = _root;
    } else {
        Class type = NSClassFromString(elementName);

        if (factory != nil) {
            SEL selector = NSSelectorFromString(factory);
            IMP method = [type methodForSelector:selector];
            id (*function)(id, SEL) = (void *)method;

            _view = function(type, selector);
        } else {
            _view = [type new];
        }
    }

    if (_view == nil) {
        [NSException raise:NSGenericException format:@"Unable to instantiate element <%@>.", elementName];
    }

    // Set outlet value
    if (outlet != nil) {
        [_owner setValue:_view forKey:outlet];
    }

    // Apply template properties
    if (template != nil) {
        [self setPropertyValues:[_properties objectForKey:template]];
    }

    // Add action handlers and set property values
    [self addActionHandlers:actions];
    [self setPropertyValues:properties];

    // Push onto view stack
    [_views addObject:_view];
}

- (void)addActionHandlers:(NSDictionary *)actions
{
    for (NSString *key in actions) {
        id value = [actions objectForKey:key];

        NSString *event = [key substringFromIndex:[LMViewBuilderActionPrefix length]];

        UIControlEvents controlEvent;
        if ([event isEqual:@"TouchDown"]) {
            controlEvent = UIControlEventTouchDown;
        } else if ([event isEqual:@"TouchDownRepeat"]) {
            controlEvent = UIControlEventTouchDownRepeat;
        } else if ([event isEqual:@"TouchDragInside"]) {
            controlEvent = UIControlEventTouchDragInside;
        } else if ([event isEqual:@"TouchDragOutside"]) {
            controlEvent = UIControlEventTouchDragOutside;
        } else if ([event isEqual:@"TouchDragEnter"]) {
            controlEvent = UIControlEventTouchDragEnter;
        } else if ([event isEqual:@"TouchDragExit"]) {
            controlEvent = UIControlEventTouchDragExit;
        } else if ([event isEqual:@"TouchUpInside"]) {
            controlEvent = UIControlEventTouchUpInside;
        } else if ([event isEqual:@"TouchUpOutside"]) {
            controlEvent = UIControlEventTouchUpOutside;
        } else if ([event isEqual:@"TouchCancel"]) {
            controlEvent = UIControlEventTouchCancel;
        } else if ([event isEqual:@"ValueChanged"]) {
            controlEvent = UIControlEventValueChanged;
        } else if ([event isEqual:@"EditingDidBegin"]) {
            controlEvent = UIControlEventEditingDidBegin;
        } else if ([event isEqual:@"EditingChanged"]) {
            controlEvent = UIControlEventEditingChanged;
        } else if ([event isEqual:@"EditingDidEnd"]) {
            controlEvent = UIControlEventEditingDidEnd;
        } else if ([event isEqual:@"EditingDidEndOnExit"]) {
            controlEvent = UIControlEventEditingDidEndOnExit;
        } else if ([event isEqual:@"AllTouchEvents"]) {
            controlEvent = UIControlEventAllTouchEvents;
        } else if ([event isEqual:@"AllEditingEvents"]) {
            controlEvent = UIControlEventAllEditingEvents;
        } else if ([event isEqual:@"AllEvents"]) {
            controlEvent = UIControlEventAllEvents;
        } else {
            controlEvent = 0;
        }

        [(UIControl *)_view addTarget:_owner action:NSSelectorFromString(value) forControlEvents:controlEvent];
    }
}

- (void)setPropertyValues:(NSDictionary *)properties
{
    for (NSString *key in properties) {
        id value = [properties objectForKey:key];

        if ([value isKindOfClass:[NSString class]]) {
            if ([key isEqual:@"contentMode"]) {
                // Translate to content mode
                UIViewContentMode contentMode;
                if ([value isEqual:@"scaleToFill"]) {
                    contentMode = UIViewContentModeScaleToFill;
                } else if ([value isEqual:@"scaleAspectFit"]) {
                    contentMode = UIViewContentModeScaleAspectFit;
                } else if ([value isEqual:@"scaleAspectFill"]) {
                    contentMode = UIViewContentModeScaleAspectFill;
                } else if ([value isEqual:@"redraw"]) {
                    contentMode = UIViewContentModeRedraw;
                } else if ([value isEqual:@"center"]) {
                    contentMode = UIViewContentModeCenter;
                } else if ([value isEqual:@"top"]) {
                    contentMode = UIViewContentModeTop;
                } else if ([value isEqual:@"bottom"]) {
                    contentMode = UIViewContentModeBottom;
                } else if ([value isEqual:@"left"]) {
                    contentMode = UIViewContentModeLeft;
                } else if ([value isEqual:@"right"]) {
                    contentMode = UIViewContentModeRight;
                } else if ([value isEqual:@"topLeft"]) {
                    contentMode = UIViewContentModeTopLeft;
                } else if ([value isEqual:@"topRight"]) {
                    contentMode = UIViewContentModeTopRight;
                } else if ([value isEqual:@"bottomLeft"]) {
                    contentMode = UIViewContentModeBottomLeft;
                } else if ([value isEqual:@"bottomRight"]) {
                    contentMode = UIViewContentModeBottomRight;
                } else {
                    contentMode = -1;
                }

                value = [NSNumber numberWithInt:contentMode];
            } else if ([key isEqual:@"tintAdjustmentMode"]) {
                // Translate to tint adjustment mode
                UIViewTintAdjustmentMode tintAdjustmentMode;
                if ([value isEqual:@"automatic"]) {
                    tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
                } else if ([value isEqual:@"normal"]) {
                    tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
                } else if ([value isEqual:@"dimmed"]) {
                    tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                } else {
                    tintAdjustmentMode = -1;
                }

                value = [NSNumber numberWithInt:tintAdjustmentMode];
            } else if ([key isEqual:@"contentHorizontalAlignment"]) {
                // Translate to control content horizontal alignment
                UIControlContentHorizontalAlignment controlContentHorizontalAlignment;
                if ([value isEqual:@"center"]) {
                    controlContentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                } else if ([value isEqual:@"left"]) {
                    controlContentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                } else if ([value isEqual:@"right"]) {
                    controlContentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                } else if ([value isEqual:@"fill"]) {
                    controlContentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
                } else {
                    controlContentHorizontalAlignment = -1;
                }

                value = [NSNumber numberWithInt:controlContentHorizontalAlignment];
            } else if ([key isEqual:@"contentVerticalAlignment"]) {
                // Translate to control content vertical alignment
                UIControlContentVerticalAlignment controlContentVerticalAlignment;
                if ([value isEqual:@"center"]) {
                    controlContentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                } else if ([value isEqual:@"top"]) {
                    controlContentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                } else if ([value isEqual:@"bottom"]) {
                    controlContentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
                } else if ([value isEqual:@"fill"]) {
                    controlContentVerticalAlignment = UIControlContentVerticalAlignmentFill;
                } else {
                    controlContentVerticalAlignment = -1;
                }

                value = [NSNumber numberWithInt:controlContentVerticalAlignment];
            } else if ([key isEqual:@"lineBreakMode"]) {
                // Translate to line break mode
                NSLineBreakMode lineBreakMode;
                if ([value isEqual:@"byWordWrapping"]) {
                    lineBreakMode = NSLineBreakByWordWrapping;
                } else if ([value isEqual:@"byCharWrapping"]) {
                    lineBreakMode = NSLineBreakByCharWrapping;
                } else if ([value isEqual:@"byClipping"]) {
                    lineBreakMode = NSLineBreakByClipping;
                } else if ([value isEqual:@"byTruncatingHead"]) {
                    lineBreakMode = NSLineBreakByTruncatingHead;
                } else if ([value isEqual:@"byTruncatingTail"]) {
                    lineBreakMode = NSLineBreakByTruncatingTail;
                } else if ([value isEqual:@"byTruncatingMiddle"]) {
                    lineBreakMode = NSLineBreakByTruncatingMiddle;
                } else {
                    lineBreakMode = -1;
                }

                value = [NSNumber numberWithInt:lineBreakMode];
            } else if ([key isEqual:@"textAlignment"]) {
                // Translate value to text alignment
                NSTextAlignment textAlignment;
                if ([value isEqual:@"left"]) {
                    textAlignment = NSTextAlignmentLeft;
                } else if ([value isEqual:@"center"]) {
                    textAlignment = NSTextAlignmentCenter;
                } else if ([value isEqual:@"right"]) {
                    textAlignment = NSTextAlignmentRight;
                } else if ([value isEqual:@"justified"]) {
                    textAlignment = NSTextAlignmentJustified;
                } else if ([value isEqual:@"natural"]) {
                    textAlignment = NSTextAlignmentNatural;
                } else {
                    textAlignment = -1;
                }

                value = [NSNumber numberWithInt:textAlignment];
            } else if ([key isEqual:@"borderStyle"]) {
                // Translate to text border style
                UITextBorderStyle textBorderStyle;
                if ([value isEqual:@"none"]) {
                    textBorderStyle = UITextBorderStyleNone;
                } else if ([value isEqual:@"line"]) {
                    textBorderStyle = UITextBorderStyleLine;
                } else if ([value isEqual:@"bezel"]) {
                    textBorderStyle = UITextBorderStyleBezel;
                } else if ([value isEqual:@"roundedRect"]) {
                    textBorderStyle = UITextBorderStyleRoundedRect;
                } else {
                    textBorderStyle = -1;
                }

                value = [NSNumber numberWithInt:textBorderStyle];
            } else if ([key isEqual:@"clearButtonMode"]) {
                // Translate to text field view mode
                UITextFieldViewMode textFieldViewMode;
                if ([value isEqual:@"never"]) {
                    textFieldViewMode = UITextFieldViewModeNever;
                } else if ([value isEqual:@"whileEditing"]) {
                    textFieldViewMode = UITextFieldViewModeWhileEditing;
                } else if ([value isEqual:@"unlessEditing"]) {
                    textFieldViewMode = UITextFieldViewModeUnlessEditing;
                } else if ([value isEqual:@"always"]) {
                    textFieldViewMode = UITextFieldViewModeAlways;
                } else {
                    textFieldViewMode = -1;
                }

                value = [NSNumber numberWithInt:textFieldViewMode];
            } else if ([key isEqual:@"autocapitalizationType"]) {
                // Translate to auto-capitalization type
                UITextAutocapitalizationType textAutocapitalizationType;
                if ([value isEqual:@"none"]) {
                    textAutocapitalizationType = UITextAutocapitalizationTypeNone;
                } else if ([value isEqual:@"words"]) {
                    textAutocapitalizationType = UITextAutocapitalizationTypeWords;
                } else if ([value isEqual:@"sentences"]) {
                    textAutocapitalizationType = UITextAutocapitalizationTypeSentences;
                } else if ([value isEqual:@"allCharacters"]) {
                    textAutocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                } else {
                    textAutocapitalizationType = -1;
                }

                // Property is not KVC-compliant
                [(UIView<UITextInputTraits> *)_view setAutocapitalizationType:textAutocapitalizationType];

                continue;
            } else if ([key isEqual:@"autocorrectionType"]) {
                // Translate to auto-correction type
                UITextAutocorrectionType textAutocorrectionType;
                if ([value isEqual:@"default"]) {
                    textAutocorrectionType = UITextAutocorrectionTypeDefault;
                } else if ([value isEqual:@"yes"]) {
                    textAutocorrectionType = UITextAutocorrectionTypeYes;
                } else if ([value isEqual:@"no"]) {
                    textAutocorrectionType = UITextAutocorrectionTypeNo;
                } else {
                    textAutocorrectionType = -1;
                }

                // Property is not KVC-compliant
                [(UIView<UITextInputTraits> *)_view setAutocorrectionType:textAutocorrectionType];

                continue;
            } else if ([key isEqual:@"spellCheckingType"]) {
                // Translate to spell checking type
                UITextSpellCheckingType textSpellCheckingType;
                if ([value isEqual:@"default"]) {
                    textSpellCheckingType = UITextSpellCheckingTypeDefault;
                } else if ([value isEqual:@"yes"]) {
                    textSpellCheckingType = UITextSpellCheckingTypeYes;
                } else if ([value isEqual:@"no"]) {
                    textSpellCheckingType = UITextSpellCheckingTypeNo;
                } else {
                    textSpellCheckingType = -1;
                }

                // Property is not KVC-compliant
                [(UIView<UITextInputTraits> *)_view setSpellCheckingType:textSpellCheckingType];

                continue;
            } else if ([key isEqual:@"keyboardAppearance"]) {
                // Translate to keyboard appearance
                UIKeyboardAppearance keyboardAppearance;
                if ([value isEqual:@"default"]) {
                    keyboardAppearance = UIKeyboardAppearanceDefault;
                } else if ([value isEqual:@"dark"]) {
                    keyboardAppearance = UIKeyboardAppearanceDark;
                } else if ([value isEqual:@"light"]) {
                    keyboardAppearance = UIKeyboardAppearanceLight;
                } else if ([value isEqual:@"alert"]) {
                    keyboardAppearance = UIKeyboardAppearanceAlert;
                } else {
                    keyboardAppearance = -1;
                }

                // Property is not KVC-compliant
                [(UIView<UITextInputTraits> *)_view setKeyboardAppearance:keyboardAppearance];

                continue;
            } else if ([key isEqual:@"keyboardType"]) {
                // Translate to keyboard type
                UIKeyboardType keyboardType;
                if ([value isEqual:@"default"]) {
                    keyboardType = UIKeyboardTypeDefault;
                } else if ([value isEqual:@"ASCIICapable"]) {
                    keyboardType = UIKeyboardTypeASCIICapable;
                } else if ([value isEqual:@"numbersAndPunctuation"]) {
                    keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                } else if ([value isEqual:@"URL"]) {
                    keyboardType = UIKeyboardTypeURL;
                } else if ([value isEqual:@"numberPad"]) {
                    keyboardType = UIKeyboardTypeNumberPad;
                } else if ([value isEqual:@"phonePad"]) {
                    keyboardType = UIKeyboardTypePhonePad;
                } else if ([value isEqual:@"namePhonePad"]) {
                    keyboardType = UIKeyboardTypeNamePhonePad;
                } else if ([value isEqual:@"emailAddress"]) {
                    keyboardType = UIKeyboardTypeEmailAddress;
                } else if ([value isEqual:@"decimalPad"]) {
                    keyboardType = UIKeyboardTypeDecimalPad;
                } else if ([value isEqual:@"twitter"]) {
                    keyboardType = UIKeyboardTypeTwitter;
                } else if ([value isEqual:@"webSearch"]) {
                    keyboardType = UIKeyboardTypeWebSearch;
                } else {
                    keyboardType = -1;
                }

                // Property is not KVC-compliant
                [(UIView<UITextInputTraits> *)_view setKeyboardType:keyboardType];

                continue;
            } else if ([key isEqual:@"returnKeyType"]) {
                // Translate to return key type
                UIReturnKeyType returnKeyType;
                if ([value isEqual:@"default"]) {
                    returnKeyType = UIReturnKeyDefault;
                } else if ([value isEqual:@"go"]) {
                    returnKeyType = UIReturnKeyGo;
                } else if ([value isEqual:@"google"]) {
                    returnKeyType = UIReturnKeyGoogle;
                } else if ([value isEqual:@"join"]) {
                    returnKeyType = UIReturnKeyJoin;
                } else if ([value isEqual:@"next"]) {
                    returnKeyType = UIReturnKeyNext;
                } else if ([value isEqual:@"route"]) {
                    returnKeyType = UIReturnKeyRoute;
                } else if ([value isEqual:@"search"]) {
                    returnKeyType = UIReturnKeySearch;
                } else if ([value isEqual:@"send"]) {
                    returnKeyType = UIReturnKeySend;
                } else if ([value isEqual:@"yahoo"]) {
                    returnKeyType = UIReturnKeyYahoo;
                } else if ([value isEqual:@"done"]) {
                    returnKeyType = UIReturnKeyDone;
                } else if ([value isEqual:@"emergencyCall"]) {
                    returnKeyType = UIReturnKeyEmergencyCall;
                } else {
                    returnKeyType = -1;
                }

                // Property is not KVC-compliant
                [(UIView<UITextInputTraits> *)_view setReturnKeyType:returnKeyType];

                continue;
            } else if ([key isEqual:@"datePickerMode"]) {
                UIDatePickerMode datePickerMode;
                if ([value isEqual:@"time"]) {
                    datePickerMode = UIDatePickerModeTime;
                } else if ([value isEqual:@"date"]) {
                    datePickerMode = UIDatePickerModeDate;
                } else if ([value isEqual:@"dateAndTime"]) {
                    datePickerMode = UIDatePickerModeDateAndTime;
                } else if ([value isEqual:@"countDownTimer"]) {
                    datePickerMode = UIDatePickerModeCountDownTimer;
                } else {
                    datePickerMode = -1;
                }

                value = [NSNumber numberWithInt:datePickerMode];
            } else if ([key isEqual:@"activityIndicatorViewStyle"]) {
                UIActivityIndicatorViewStyle activityIndicatorViewStyle;
                if ([value isEqual:@"whiteLarge"]) {
                    activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
                } else if ([value isEqual:@"white"]) {
                    activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                } else if ([value isEqual:@"gray"]) {
                    activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                } else {
                    activityIndicatorViewStyle = -1;
                }

                value = [NSNumber numberWithInt:activityIndicatorViewStyle];
            } else if ([key isEqual:@"separatorStyle"]) {
                UITableViewCellSeparatorStyle tableViewCellSeparatorStyle;
                if ([value isEqual:@"none"]) {
                    tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleNone;
                } else if ([value isEqual:@"singleLine"]) {
                    tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
                } else if ([value isEqual:@"singleLineEtched"]) {
                    tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
                } else {
                    tableViewCellSeparatorStyle = -1;
                }

                value = [NSNumber numberWithInt:tableViewCellSeparatorStyle];
            } else if ([key isEqual:@"accessoryType"]) {
                // Translate to table view cell accessory type
                UITableViewCellAccessoryType tableViewCellAccessoryType;
                if ([value isEqual:@"none"]) {
                    tableViewCellAccessoryType = UITableViewCellAccessoryNone;
                } else if ([value isEqual:@"disclosureIndicator"]) {
                    tableViewCellAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else if ([value isEqual:@"detailDisclosureButton"]) {
                    tableViewCellAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                } else if ([value isEqual:@"checkmark"]) {
                    tableViewCellAccessoryType = UITableViewCellAccessoryCheckmark;
                } else if ([value isEqual:@"detailButton"]) {
                    tableViewCellAccessoryType = UITableViewCellAccessoryDetailButton;
                } else {
                    tableViewCellAccessoryType = -1;
                }

                value = [NSNumber numberWithInt:tableViewCellAccessoryType];
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
                        if ([component isEqual:@"phoneNumber"]) {
                            dataDetectorTypes |= UIDataDetectorTypePhoneNumber;
                        } else if ([component isEqual:@"link"]) {
                            dataDetectorTypes |= UIDataDetectorTypeLink;
                        } else if ([component isEqual:@"address"]) {
                            dataDetectorTypes |= UIDataDetectorTypeAddress;
                        } else if ([component isEqual:@"calendarEvent"]) {
                            dataDetectorTypes |= UIDataDetectorTypeCalendarEvent;
                        } else {
                            dataDetectorTypes |= -1;
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
                    webPaginationBreakingMode = -1;
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
                    webPaginationMode = -1;
                }

                value = [NSNumber numberWithInt:webPaginationMode];
            } else if ([key isEqual:@"alignment"]) {
                // Translate to stack view alignment
                LMBoxViewAlignment boxViewAlignment;
                if ([value isEqual:@"top"]) {
                    boxViewAlignment = LMBoxViewAlignmentTop;
                } else if ([value isEqual:@"bottom"]) {
                    boxViewAlignment = LMBoxViewAlignmentBottom;
                } else if ([value isEqual:@"left"]) {
                    boxViewAlignment = LMBoxViewAlignmentLeft;
                } else if ([value isEqual:@"right"]) {
                    boxViewAlignment = LMBoxViewAlignmentRight;
                } else if ([value isEqual:@"leading"]) {
                    boxViewAlignment = LMBoxViewAlignmentLeading;
                } else if ([value isEqual:@"trailing"]) {
                    boxViewAlignment = LMBoxViewAlignmentTrailing;
                } else if ([value isEqual:@"center"]) {
                    boxViewAlignment = LMBoxViewAlignmentCenter;
                } else if ([value isEqual:@"baseline"]) {
                    boxViewAlignment = LMBoxViewAlignmentBaseline;
                } else if ([value isEqual:@"fill"]) {
                    boxViewAlignment = LMBoxViewAlignmentFill;
                } else {
                    boxViewAlignment = -1;
                }

                value = [NSNumber numberWithInt:boxViewAlignment];
            } else if ([key rangeOfString:@"[Cc]olor$" options:NSRegularExpressionSearch].location != NSNotFound) {
                // Parse color specification
                UIColor *color = nil;

                if ([value hasPrefix:LMViewBuilderHexValuePrefix]) {
                    if ([value length] < 9) {
                        value = [NSString stringWithFormat:@"%@ff", value];
                    }

                    if ([value length] == 9) {
                        int red, green, blue, alpha;
                        sscanf([value UTF8String], "#%02X%02X%02X%02X", &red, &green, &blue, &alpha);

                        color = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
                    }
                }

                if (color == nil) {
                    continue;
                }

                if ([key hasPrefix:@"layer"]) {
                    value = (id)[color CGColor];
                } else {
                    value = color;
                }
            } else if ([key rangeOfString:@"[Ff]ont$" options:NSRegularExpressionSearch].location != NSNotFound) {
                // Parse font specification
                if ([value isEqual:@"headline"]) {
                    value = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
                } else if ([value isEqual:@"subheadline"]) {
                    value = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
                } else if ([value isEqual:@"body"]) {
                    value = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                } else if ([value isEqual:@"footnote"]) {
                    value = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                } else if ([value isEqual:@"caption1"]) {
                    value = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
                } else if ([value isEqual:@"caption2"]) {
                    value = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                } else {
                    UIFont *font = nil;

                    NSArray *components = [value componentsSeparatedByString:@" "];

                    if ([components count] == 2) {
                        NSString *fontName = [components objectAtIndex:0];
                        CGFloat fontSize = [[components objectAtIndex:1] floatValue];

                        font = [UIFont fontWithName:fontName size:fontSize];
                    }

                    if (font == nil) {
                        continue;
                    }

                    value = font;
                }
            } else if ([key rangeOfString:@"[Ii]mage$" options:NSRegularExpressionSearch].location != NSNotFound) {
                // Load named image
                value = [UIImage imageNamed:value];
            } else if ([key rangeOfString:@"^(?:horizontal|vertical)Content(?:CompressionResistance|Hugging)Priority$"
                options:NSRegularExpressionSearch].location != NSNotFound) {
                // Translate to layout priority
                UILayoutPriority layoutPriority;
                if ([value isEqual:@"required"]) {
                    layoutPriority = UILayoutPriorityRequired;
                } else if ([value isEqual:@"high"]) {
                    layoutPriority = UILayoutPriorityDefaultHigh;
                } else if ([value isEqual:@"low"]) {
                    layoutPriority = UILayoutPriorityDefaultLow;
                } else {
                    layoutPriority = [value floatValue];
                }

                value = [NSNumber numberWithFloat:layoutPriority];
            } else {
                // Get localized value
                NSString *localizedValue = [_strings objectForKey:value];

                if (localizedValue == nil) {
                    localizedValue = [[NSBundle mainBundle] localizedStringForKey:value value:value table:nil];
                }

                value = localizedValue;
            }
        }

        if ([key isEqual:@"layoutMargins"]) {
            // Create edge insets from value
            CGFloat inset = [value floatValue];

            value = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        }

        [_view setValue:value forKeyPath:key];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Pop from view stack
    _view = [_views lastObject];

    [_views removeLastObject];

    // Add to superview
    if ([_views count] > 0) {
        [(UIView *)[_views lastObject] appendMarkupElementView:_view];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error
{
    [NSException raise:NSGenericException format:@"A parse error occurred."];
}

@end
