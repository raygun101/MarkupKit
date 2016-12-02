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

#import "UIScrollView+Markup.h"
#import "NSObject+Markup.h"

static NSDictionary *keyboardDismissModeValues;

@implementation UIScrollView (Markup)

+ (void)initialize
{
    keyboardDismissModeValues = @{
        @"none": @(UIScrollViewKeyboardDismissModeNone),
        @"onDrag": @(UIScrollViewKeyboardDismissModeOnDrag),
        @"interactive": @(UIScrollViewKeyboardDismissModeInteractive)
    };
}

#if TARGET_OS_IOS
- (NSInteger)currentPage
{
    return [self isPagingEnabled] ? (NSInteger)[self contentOffset].x / [self frame].size.width : 0;
}
#endif

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"keyboardDismissMode"]) {
        value = [keyboardDismissModeValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end
