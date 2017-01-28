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

// TODO

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
    // TODO Establish a two-way binding between this object and the given object
}

- (void)unbind
{
    // TODO Release all bindings to and from this object
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

// TODO

- (void)dealloc
{
    // TODO Unbind source object if not already unbound
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // TODO Update target object
}

@end
