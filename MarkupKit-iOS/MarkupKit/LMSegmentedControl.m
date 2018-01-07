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

#import "LMSegmentedControl.h"

#import <objc/message.h>

@implementation LMSegmentedControl
{
    NSMutableArray *_values;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        _values = [NSMutableArray new];
    }

    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)decoder
{
    return nil;
}

- (void)insertSegmentWithTitle:(nullable NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [self insertSegmentWithTitle:title value:nil atIndex:segment animated:animated];
}

- (void)insertSegmentWithTitle:(nullable NSString *)title value:(id)value atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [super insertSegmentWithTitle:title atIndex:segment animated:animated];

    [_values insertObject:(value == nil ? [NSNull null] : value) atIndex:segment];
}

- (void)insertSegmentWithImage:(nullable UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [self insertSegmentWithImage:image value:nil atIndex:segment animated:animated];
}

- (void)insertSegmentWithImage:(nullable UIImage *)image value:(id)value atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [super insertSegmentWithImage:image atIndex:segment animated:animated];

    [_values insertObject:(value == nil ? [NSNull null] : value) atIndex:segment];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [super removeSegmentAtIndex:segment animated:animated];

    [_values removeObjectAtIndex:segment];
}

- (void)removeAllSegments
{
    [super removeAllSegments];

    [_values removeAllObjects];
}

- (id)valueForSegmentAtIndex:(NSUInteger)segment
{
    id value = [_values objectAtIndex:segment];

    return (value == [NSNull null] ? nil : value);
}

- (void)setValue:(id)value forSegmentAtIndex:(NSUInteger)segment
{
    [_values setObject:(value == nil ? [NSNull null] : value) atIndexedSubscript:segment];
}

@end
