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
#import "UIResponder+Markup.h"

static NSString * const kCaseTarget = @"case";
static NSString * const kEndTarget = @"end";
static NSString * const kPropertiesTarget = @"properties";

static NSString * const kRootTag = @"root";

static NSString * const kFactoryKey = @"style";
static NSString * const kTemplateKey = @"class";
static NSString * const kOutletKey = @"id";

static NSString * const kBindingPrefix = @"$";
static NSString * const kLocalizedStringPrefix = @"@";
static NSString * const kEscapePrefix = @"^";

@interface LMViewBuilder () <NSXMLParserDelegate>

@end

static NSMutableDictionary *colorTable;
static NSMutableDictionary *templateCache;

@implementation LMViewBuilder
{
    id _owner;
    UIView *_root;

    NSMutableDictionary *_templates;
    NSMutableArray *_views;

    NSString *_target;
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
            [NSException raise:NSGenericException format:@"%@: %@", colorTablePath, [error description]];
        }

        for (NSString *key in colorTableValues) {
            [colorTable setObject:[LMViewBuilder colorValue:[colorTableValues objectForKey:key]] forKey:key];
        }
    }

    templateCache = [NSMutableDictionary new];
}

+ (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root
{
    UIView *view = nil;

    NSBundle *bundle = [owner bundleForView];

    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }

    NSURL *url = [bundle URLForResource:name withExtension:@"xml"];

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
    } else {
        UIImage *image = [UIImage imageNamed:value];

        if (image != nil) {
            color = [UIColor colorWithPatternImage:image];
        } else {
            if (@available(iOS 11, tvOS 11, *)) {
                color = [UIColor colorNamed:value];
            }

            if (color == nil) {
                color = [colorTable objectForKey:value];

                if (color == nil) {
                    NSString *selectorName = [NSString stringWithFormat:@"%@Color", value];

                    if ([[UIColor self] respondsToSelector:NSSelectorFromString(selectorName)]) {
                        color = [[UIColor self] valueForKey:selectorName];
                    }
                }
            }
        }
    }

    return color;
}

+ (UIFont *)fontValue:(NSString *)value
{
    UIFont *font = nil;

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

    return font;
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
                [NSException raise:NSGenericException format:@"%@: %@", path, [error description]];
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

- (instancetype)initWithOwner:(id)owner root:(UIView *)root
{
    self = [super init];

    if (self) {
        _owner = owner;
        _root = root;

        _templates = [NSMutableDictionary new];
        _views = [NSMutableArray new];

        _target = nil;
    }

    return self;
}

- (UIView *)root
{
    return _root;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributes
{
    if (_target != nil && ![_target isEqual:[[UIDevice currentDevice] systemName]]) {
        return;
    }

    NSBundle *bundle = [_owner bundleForStrings];

    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }

    NSString *table = [_owner tableForStrings];

    NSString *factory = nil;
    NSString *template = nil;
    NSString *outlet = nil;
    NSMutableDictionary *actions = [NSMutableDictionary new];
    NSMutableDictionary *bindings = [NSMutableDictionary new];
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
        } else if ([value hasPrefix:kBindingPrefix]) {
            [bindings setObject:[value substringFromIndex:[kBindingPrefix length]] forKey:key];
        } else if ([value hasPrefix:kLocalizedStringPrefix]) {
            [properties setObject:[bundle localizedStringForKey:[value substringFromIndex:[kLocalizedStringPrefix length]] value:value table:table] forKey:key];
        } else if ([value hasPrefix:kEscapePrefix]) {
            [properties setObject:[value substringFromIndex:[kEscapePrefix length]] forKey:key];
        } else {
            [properties setObject:value forKey:key];
        }
    }

    // Determine element type
    UIView *view = nil;

    if ([elementName isEqual:kRootTag]) {
        if (_root == nil) {
            [NSException raise:NSGenericException format:@"Root view is not defined."];
        }

        view = _root;
    } else {
        Class type = NSClassFromString(elementName);

        if ([type isSubclassOfClass:[UIView self]]) {
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
    }

    if (view != nil) {
        // Apply template properties
        if (template != nil) {
            NSArray *components = [template componentsSeparatedByString:@","];

            for (NSString *component in components) {
                NSString *name = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                NSDictionary *template = [_templates objectForKey:name];

                for (NSString *key in template) {
                    [view applyMarkupPropertyValue:[self valueForValue:[template objectForKey:key] withKeyPath:key] forKeyPath:key];
                }
            }
        }

        // Apply instance properties
        for (NSString *key in properties) {
            [view applyMarkupPropertyValue:[self valueForValue:[properties objectForKey:key] withKeyPath:key] forKeyPath:key];
        }

        // Apply bindings
        for (NSString *key in bindings) {
            [_owner bind:[bindings objectForKey:key] toView:view withKeyPath:key];
        }

        // Add action handlers
        for (NSNumber *key in actions) {
            [(UIControl *)view addTarget:_owner action:NSSelectorFromString([actions objectForKey:key]) forControlEvents:[key integerValue]];
        }

        // Set outlet value
        if (outlet != nil) {
            [_owner setValue:view forKey:outlet];
        }

        // Push onto view stack
        [_views addObject:view];
    } else {
        // Process untyped element
        if ([_views count] > 0) {
            id superview = [_views lastObject];

            if ([superview isKindOfClass:[UIView self]]) {
                // Apply bindings
                for (NSString *key in bindings) {
                    [properties setObject:[_owner valueForKeyPath:[bindings objectForKey:key]] forKey:key];
                }

                // Notify superview
                [superview processMarkupElement:elementName properties:properties];
            }
        }

        // Push null view
        [_views addObject:[NSNull null]];
    }
}

- (id)valueForValue:(id)value withKeyPath:(NSString *)keyPath
{
    if ([keyPath rangeOfString:@"[Cc]olor$" options:NSRegularExpressionSearch].location != NSNotFound) {
        value = [LMViewBuilder colorValue:[value description]];
    } else if ([keyPath rangeOfString:@"[Ff]ont$" options:NSRegularExpressionSearch].location != NSNotFound) {
        value = [LMViewBuilder fontValue:[value description]];
    } else if ([keyPath rangeOfString:@"[Ii]mage$" options:NSRegularExpressionSearch].location != NSNotFound) {
        NSBundle *bundle = [_owner bundleForImages];

        if (bundle == nil) {
            bundle = [NSBundle mainBundle];
        }

        value = [UIImage imageNamed:[value description] inBundle:bundle compatibleWithTraitCollection:[_owner traitCollection]];
    }

    return value;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (_target != nil && ![_target isEqual:[[UIDevice currentDevice] systemName]]) {
        return;
    }

    // Pop from view stack
    id view = [_views lastObject];

    [_views removeLastObject];

    if ([view isKindOfClass:[UIView self]]) {
        if ([_views count] > 0) {
            // Add to superview
            id superview = [_views lastObject];

            if ([superview isKindOfClass:[UIView self]]) {
                [superview appendMarkupElementView:view];
            }
        } else {
            // Set root view
            _root = view;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return;
    }

    [NSException raise:NSGenericException format:@"Unexpected character content near line %ld.",
        (long)[parser lineNumber]];
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    if ([target isEqual:kCaseTarget]) {
        _target = data;
    } else if ([target isEqual:kEndTarget]) {
        _target = nil;
    } else {
        if (_target != nil && ![_target isEqual:[[UIDevice currentDevice] systemName]]) {
            return;
        }

        if ([target isEqual:kPropertiesTarget]) {
            // Merge templates
            NSDictionary *dictionary;
            if ([data hasPrefix:@"{"]) {
                NSError *error = nil;

                dictionary = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                    options:0 error:&error];

                if (error != nil) {
                    [NSException raise:NSGenericException format:@"Line %ld: %@", (long)[parser lineNumber], [error description]];
                }
            } else {
                dictionary = [LMViewBuilder templatesWithName:data];
            }

            [LMViewBuilder mergeDictionary:dictionary into:_templates];
        } else {
            // Notify view
            id view = [_views lastObject];

            if ([view isKindOfClass:[UIView self]]) {
                [view processMarkupInstruction:target data:data];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    [NSException raise:NSGenericException format:@"Unexpected CDATA content near line %ld.",
        (long)[parser lineNumber]];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error
{
    [NSException raise:NSGenericException format:@"A parse error occurred at line %ld, column %ld.",
        (long)[parser lineNumber],
        (long)[parser columnNumber]];
}

@end
