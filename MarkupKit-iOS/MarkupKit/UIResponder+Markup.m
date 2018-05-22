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

#import "UIResponder+Markup.h"

#import <objc/message.h>

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

- (NSFormatter *)formatterWithName:(NSString *)name
{
    NSFormatter *formatter;
    if ([name isEqual:@"shortDate"]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];

        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

        formatter = dateFormatter;
    } else if ([name isEqual:@"mediumDate"]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];

        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

        formatter = dateFormatter;
    } else if ([name isEqual:@"longDate"]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];

        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

        formatter = dateFormatter;
    } else if ([name isEqual:@"fullDate"]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];

        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

        formatter = dateFormatter;
    } else {
        formatter = nil;
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
    NSString *_format;
}

- (instancetype)initWithExpression:(NSString *)expression view:(UIView *)view keyPath:(NSString *)keyPath
{
    self = [super init];

    if (self) {
        NSArray *components = [expression componentsSeparatedByString:@"::"];

        _expression = [NSExpression expressionWithFormat:components[0]];

        if ([components count] > 1) {
            _format = components[1];
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

    if (_format != nil) {
        NSFormatter *formatter = [object formatterWithName:_format];

        if (formatter != nil) {
            value = [formatter stringForObjectValue:value];
        } else {
            value = [NSString stringWithFormat:_format, value];
        }
    }

    if (value != nil && value != [NSNull null]) {
        [_view setValue:value forKeyPath:_keyPath];
    }
}

@end
