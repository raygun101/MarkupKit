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

#import "UISegmentedControl+Markup.h"
#import "UIView+Markup.h"

static NSString * const kSegmentTag = @"segment";
static NSString * const kSegmentTitleKey = @"title";
static NSString * const kSegmentImageKey = @"image";
static NSString * const kSegmentValueKey = @"value";

@implementation UISegmentedControl (Markup)

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
