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

#import "NSObject+Markup.h"

#import <objc/message.h>

@interface LMBinding : NSObject

@property (weak, nonatomic, readonly) id observer;
@property (nonatomic, readonly) NSString *binding;

@property (weak, nonatomic, readonly) id object;
@property (nonatomic, readonly) NSString *keyPath;

- (instancetype)initWithObserver:(id)observer binding:(NSString *)binding object:(id)object keyPath:(NSString *)keyPath;

@end

@implementation NSObject (Markup)

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if (value == nil || value == [NSNull null]) {
        return;
    }

    [self setValue:value forKey:key];
}

- (void)applyMarkupPropertyValue:(id)value forKeyPath:(NSString *)keyPath
{
    NSArray *components = [keyPath componentsSeparatedByString:@"."];

    NSUInteger n = [components count];

    id target = self;

    for (NSUInteger i = 0; i < n - 1; i++) {
        target = [target valueForKey:[components objectAtIndex:i]];
    }

    [target applyMarkupPropertyValue:value forKey:[components objectAtIndex:n - 1]];
}

- (void)bind:(NSString *)binding toObject:(id)object withKeyPath:(NSString *)keyPath
{
    // TODO Establish a binding from bound object/key path to this object/binding and add to this object's binding list

    // TODO Establish a binding from this object/binding to bound object/key path and add to bound object's binding list
}

- (void)unbind
{
    [self setBindings:nil];
}

- (NSMutableArray *)bindings
{
    return objc_getAssociatedObject(self, @selector(bindings));
}

- (void)setBindings:(NSMutableArray *)bindings
{
    objc_setAssociatedObject(self, @selector(bindings), bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation LMBinding
{
    BOOL _update;
}

- (instancetype)initWithObserver:(id)observer binding:(NSString *)binding object:(id)object keyPath:(NSString *)keyPath
{
    self = [super init];

    if (self) {
        _observer = observer;
        _binding = binding;

        _object = object;
        _keyPath = keyPath;

        [_object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }

    return self;
}

- (void)dealloc
{
    // TODO Unbind source object if not already unbound
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_update) {
        _update = YES;

        id value = [change objectForKey:NSKeyValueChangeNewKey];

        if (value != nil && value != [NSNull null]) {
            [_observer setValue:value forKey:_binding];
        }

        _update = NO;
    }
}

@end
