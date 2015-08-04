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

#import <objc/message.h>
#import "UITableViewCell+Markup.h"

@implementation UITableViewCell (Markup)

+ (UITableViewCell *)defaultTableViewCell
{
    return [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

+ (UITableViewCell *)value1TableViewCell
{
    return [[self alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
}

+ (UITableViewCell *)value2TableViewCell
{
    return [[self alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
}

+ (UITableViewCell *)subtitleTableViewCell
{
    return [[self alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
}

- (id)value
{
    return objc_getAssociatedObject(self, @selector(value));
}

- (void)setValue:(id)value
{
    objc_setAssociatedObject(self, @selector(value), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendMarkupElementView:(UIView *)view
{
    [self setAccessoryView:view];

    [view sizeToFit];
}

@end
