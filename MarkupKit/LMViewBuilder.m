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
#import "NSObject+Markup.h"
#import "UIView+Markup.h"

static NSString * const kNormalSizeClass = @"normal";
static NSString * const kHorizontalSizeClass = @"horizontal";
static NSString * const kVerticalSizeClass = @"vertical";
static NSString * const kMinimalSizeClass = @"minimal";

static NSString * const kSizeClassFormat = @"%@~%@";

static NSString * const kPropertiesTarget = @"properties";
static NSString * const kIncludeTarget = @"include";

static NSString * const kRootTag = @"root";
static NSString * const kFactoryKey = @"style";
static NSString * const kTemplateKey = @"class";

static NSString * const kOutletKey = @"id";

static NSString * const kLocalizedStringPrefix = @"@";

@interface LMViewBuilderInclude : NSObject

@property (nonatomic) UIView *parent;
@property (nonatomic) NSString *name;

- (instancetype)initWithParent:(UIView *)parent name:(NSString *)name;

@end

@interface LMViewBuilder () <NSXMLParserDelegate>

@end

static NSMutableDictionary *colorTable;
static NSMutableDictionary *fontTable;

static NSMutableDictionary *templateCache;

@implementation LMViewBuilder
{
    id _owner;
    UIView *_root;

    NSMutableDictionary *_templates;

    NSMutableArray *_views;
    NSMutableArray *_includes;
}

+ (void)initialize
{
    colorTable = [NSMutableDictionary new];

    NSString *colorTablePath = [[NSBundle mainBundle] pathForResource:@"Colors" ofType:@"plist"];

    if (colorTablePath != nil) {
        NSError *error = nil;

        NSDictionary *colorTableValues = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:colorTablePath]
            options:0 format:nil error:&error];

        if (error != nil) {
            [NSException raise:NSGenericException format:@"%@: %@", colorTablePath,
                [[error userInfo] objectForKey:@"NSDebugDescription"]];
        }

        for (NSString *key in colorTableValues) {
            [colorTable setObject:[LMViewBuilder colorValue:[colorTableValues objectForKey:key]] forKey:key];
        }
    }

    fontTable = [NSMutableDictionary new];

    NSString *fontTablePath = [[NSBundle mainBundle] pathForResource:@"Fonts" ofType:@"plist"];

    if (fontTablePath != nil) {
        NSError *error = nil;

        NSDictionary *fontTableValues = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:fontTablePath]
            options:0 format:nil error:&error];

        if (error != nil) {
            [NSException raise:NSGenericException format:@"%@: %@", fontTablePath,
                [[error userInfo] objectForKey:@"NSDebugDescription"]];
        }

        for (NSString *key in fontTableValues) {
            [fontTable setObject:[LMViewBuilder fontValue:[fontTableValues objectForKey:key]] forKey:key];
        }
    }

    templateCache = [NSMutableDictionary new];
}

+ (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root
{
    return [LMViewBuilder viewWithName:name owner:owner root:root templates:nil];
}

+ (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root templates:(NSDictionary *)templates
{
    NSURL *url = nil;

    NSBundle *mainBundle = [NSBundle mainBundle];

    if ([owner conformsToProtocol:@protocol(UITraitEnvironment)]) {
        NSString *sizeClass = [LMViewBuilder sizeClassForTraitCollection:[owner traitCollection]];

        if (sizeClass != nil) {
            url = [mainBundle URLForResource:[NSString stringWithFormat:kSizeClassFormat, name, sizeClass] withExtension:@"xml"];
        }
    }

    if (url == nil) {
        url = [mainBundle URLForResource:name withExtension:@"xml"];
    }

    UIView *view = nil;

    if (url != nil) {
        LMViewBuilder *viewBuilder = [[LMViewBuilder alloc] initWithOwner:owner root:root templates:templates];

        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];

        [parser setDelegate:viewBuilder];
        [parser parse];

        view = [viewBuilder root];

        for (LMViewBuilderInclude *include in [viewBuilder includes]) {
            UIView *child = [LMViewBuilder viewWithName:[include name] owner:owner root:nil templates:[viewBuilder templates]];

            [[include parent] appendMarkupElementView:child];
        }
    }

    return view;
}

+ (NSString *)sizeClassForTraitCollection:(UITraitCollection *)traitCollection
{
    UIUserInterfaceSizeClass horizontalSizeClass = [traitCollection horizontalSizeClass];
    UIUserInterfaceSizeClass verticalSizeClass = [traitCollection verticalSizeClass];

    NSString *sizeClass;
    if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        sizeClass = kNormalSizeClass;
    } else if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        sizeClass = kHorizontalSizeClass;
    } else if (horizontalSizeClass == UIUserInterfaceSizeClassCompact && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        sizeClass = kVerticalSizeClass;
    } else if (horizontalSizeClass == UIUserInterfaceSizeClassCompact && verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        sizeClass = kMinimalSizeClass;
    } else {
        sizeClass = nil;
    }

    return sizeClass;
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
    } else {
        color = [colorTable objectForKey:value];

        if (color == nil) {
            NSString *selectorName = [NSString stringWithFormat:@"%@Color", value];

            if ([[UIColor self] respondsToSelector:NSSelectorFromString(selectorName)]) {
                color = [[UIColor self] valueForKey:selectorName];
            } else {
                UIImage *image = [UIImage imageNamed:value];

                if (image != nil) {
                    color = [UIColor colorWithPatternImage:image];
                }
            }
        }
    }

    return color;
}

+ (UIFont *)fontValue:(NSString *)value
{
    UIFont *font = [fontTable objectForKey:value];

    if (font == nil) {
        if ([value isEqual:@"title1"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        } else if ([value isEqual:@"title2"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        } else if ([value isEqual:@"title3"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        } else if ([value isEqual:@"headline"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        } else if ([value isEqual:@"subheadline"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        } else if ([value isEqual:@"body"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        } else if ([value isEqual:@"callout"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        } else if ([value isEqual:@"footnote"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        } else if ([value isEqual:@"caption1"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        } else if ([value isEqual:@"caption2"]) {
            font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
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
    }

    return font;
}

+ (NSDictionary *)templatesWithName:(NSString *)name traitCollection:(UITraitCollection *)traitCollection
{
    NSMutableDictionary *templates = [NSMutableDictionary new];

    [LMViewBuilder mergeDictionary:[LMViewBuilder templatesWithName:name] into:templates];

    NSString *sizeClass = [LMViewBuilder sizeClassForTraitCollection:traitCollection];

    if (sizeClass != nil) {
        [LMViewBuilder mergeDictionary:[LMViewBuilder templatesWithName:[NSString stringWithFormat:kSizeClassFormat, name, sizeClass]] into:templates];
    }

    return templates;
}

+ (NSDictionary *)templatesWithName:(NSString *)name
{
    NSDictionary *templates = [templateCache objectForKey:name];

    if (templates == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];

        if (path != nil) {
            NSError *error = nil;

            templates = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                options:0 error:&error];

            if (error != nil) {
                [NSException raise:NSGenericException format:@"%@: %@", path,
                    [[error userInfo] objectForKey:@"NSDebugDescription"]];
            }

            [templateCache setObject:templates forKey:name];
        }
    }

    return templates;
}

+ (void)mergeDictionary:(NSDictionary *)dictionary into:(NSMutableDictionary *)templates
{
    for (NSString *key in dictionary) {
        NSMutableDictionary *template = (NSMutableDictionary *)[templates objectForKey:key];

        if (template == nil) {
            template = [NSMutableDictionary new];

            [templates setObject:template forKey:key];
        }

        [template addEntriesFromDictionary:(NSDictionary *)[dictionary objectForKey:key]];
    }
}

- (instancetype)init
{
    return nil;
}

- (instancetype)initWithOwner:(id)owner root:(UIView *)root templates:(NSDictionary *)templates
{
    self = [super init];

    if (self) {
        _owner = owner;
        _root = root;

        _templates = [[NSMutableDictionary alloc] initWithDictionary:templates];
        
        _views = [NSMutableArray new];
        _includes = [NSMutableArray new];
    }

    return self;
}

- (UIView *)root
{
    return _root;
}

- (NSArray *)includes
{
    return _includes;
}

- (NSDictionary *)templates
{
    return _templates;
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    if ([target isEqual:kPropertiesTarget]) {
        // Merge templates
        if ([_views count] == 0) {
            if ([data hasPrefix:@"{"]) {
                NSError *error = nil;

                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                    options:0 error:&error];

                if (error != nil) {
                    [NSException raise:NSGenericException format:@"Line %ld: %@", (long)[parser lineNumber],
                        [[error userInfo] objectForKey:@"NSDebugDescription"]];
                }

                [LMViewBuilder mergeDictionary:dictionary into:_templates];
            } else {
                [LMViewBuilder mergeDictionary:[LMViewBuilder templatesWithName:data traitCollection:[_owner traitCollection]] into:_templates];
            }
        }
    } else if ([target isEqual:kIncludeTarget]) {
        // Push include
        if ([_views count] > 0) {
            [_includes addObject:[[LMViewBuilderInclude alloc] initWithParent:[_views lastObject] name:data]];
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
        } else if ([key isEqual:@"onTouchDown"]) {
            [actions setObject:value forKey:@(UIControlEventTouchDown)];
        } else if ([key isEqual:@"onTouchDownRepeat"]) {
            [actions setObject:value forKey:@(UIControlEventTouchDownRepeat)];
        } else if ([key isEqual:@"onTouchDragInside"]) {
            [actions setObject:value forKey:@(UIControlEventTouchDragInside)];
        } else if ([key isEqual:@"onTouchDragOutside"]) {
            [actions setObject:value forKey:@(UIControlEventTouchDragOutside)];
        } else if ([key isEqual:@"onTouchDragEnter"]) {
            [actions setObject:value forKey:@(UIControlEventTouchDragEnter)];
        } else if ([key isEqual:@"onTouchDragExit"]) {
            [actions setObject:value forKey:@(UIControlEventTouchDragExit)];
        } else if ([key isEqual:@"onTouchUpInside"]) {
            [actions setObject:value forKey:@(UIControlEventTouchUpInside)];
        } else if ([key isEqual:@"onTouchUpOutside"]) {
            [actions setObject:value forKey:@(UIControlEventTouchUpOutside)];
        } else if ([key isEqual:@"onTouchCancel"]) {
            [actions setObject:value forKey:@(UIControlEventTouchCancel)];
        } else if ([key isEqual:@"onValueChanged"]) {
            [actions setObject:value forKey:@(UIControlEventValueChanged)];
        } else if ([key isEqual:@"onPrimaryActionTriggered"]) {
            [actions setObject:value forKey:@(UIControlEventPrimaryActionTriggered)];
        } else if ([key isEqual:@"onEditingDidBegin"]) {
            [actions setObject:value forKey:@(UIControlEventEditingDidBegin)];
        } else if ([key isEqual:@"onEditingChanged"]) {
            [actions setObject:value forKey:@(UIControlEventEditingChanged)];
        } else if ([key isEqual:@"onEditingDidEnd"]) {
            [actions setObject:value forKey:@(UIControlEventEditingDidEnd)];
        } else if ([key isEqual:@"onEditingDidEndOnExit"]) {
            [actions setObject:value forKey:@(UIControlEventEditingDidEndOnExit)];
        } else if ([key isEqual:@"onAllTouchEvents"]) {
            [actions setObject:value forKey:@(UIControlEventAllTouchEvents)];
        } else if ([key isEqual:@"onAllEditingEvents"]) {
            [actions setObject:value forKey:@(UIControlEventAllEditingEvents)];
        } else if ([key isEqual:@"onAllEvents"]) {
            [actions setObject:value forKey:@(UIControlEventAllEvents)];
        } else {
            if ([value hasPrefix:kLocalizedStringPrefix]) {
                value = [[NSBundle mainBundle] localizedStringForKey:[value substringFromIndex:[kLocalizedStringPrefix length]] value:nil table:nil];
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
                NSString *name = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                [view applyMarkupPropertyValues:[_templates objectForKey:name]];
            }
        }

        // Apply instance properties
        [view applyMarkupPropertyValues:properties];

        // Add action handlers
        for (NSNumber *key in actions) {
            [(UIControl *)view addTarget:_owner action:NSSelectorFromString([actions objectForKey:key])
                forControlEvents:[key integerValue]];
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

@implementation LMViewBuilderInclude

- (instancetype)initWithParent:(UIView *)parent name:(NSString *)name
{
    self = [super init];

    if (self) {
        _parent = parent;
        _name = name;
    }

    return self;
}

@end
