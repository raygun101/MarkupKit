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

@property (weak, nonatomic, readonly) id owner;
@property (nonatomic, readonly) NSExpression *expression;

@property (weak, nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSString *keyPath;

- (instancetype)initWithOwner:(id)owner expression:(NSString *)expression view:(UIView *)view keyPath:(NSString *)keyPath;

- (void)bind;
- (void)unbind;

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

- (void)bind:(NSString *)expression toView:(UIView *)view withKeyPath:(NSString *)keyPath
{
    LMBinding *binding = [[LMBinding alloc] initWithOwner:self expression:expression view:view keyPath:keyPath];

    [binding bind];

    [[self bindings] addObject:binding];
}

- (void)unbindAll
{
    NSMutableArray *bindings = [self bindings];

    for (LMBinding *binding in bindings) {
        [binding unbind];
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

- (instancetype)initWithOwner:(id)owner expression:(NSString *)expression view:(UIView *)view keyPath:(NSString *)keyPath
{
    self = [super init];

    if (self) {
        _owner = owner;
        _expression = [NSExpression expressionWithFormat:expression];

        _view = view;
        _keyPath = keyPath;
    }

    return self;
}

- (void)bind
{
    [self bindTo:_expression];    
    [self apply];
}

- (void)bindTo:(NSExpression *)expression
{
    switch ([expression expressionType]) {
    case NSKeyPathExpressionType:
        [_owner addObserver:self forKeyPath:[expression keyPath] options:NSKeyValueObservingOptionNew context:nil];

        break;

    case NSFunctionExpressionType:
        for (NSExpression *argument in [expression arguments]) {
            [self bindTo:argument];
        }

        break;

    default:
        break;
    }
}

- (void)unbind
{
    [self unbindFrom:_expression];
}

- (void)unbindFrom:(NSExpression *)expression
{
    switch ([expression expressionType]) {
    case NSKeyPathExpressionType:
        [_owner removeObserver:self forKeyPath:[expression keyPath] context:nil];

        break;

    case NSFunctionExpressionType:
        for (NSExpression *argument in [expression arguments]) {
            [self unbindFrom:argument];
        }

        break;

    default:
        break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self apply];
}

- (void)apply
{
    id value = [_expression expressionValueWithObject:_owner context:nil];

    if (value != nil && value != [NSNull null]) {
        [_view setValue:value forKeyPath:_keyPath];
    }
}

@end
