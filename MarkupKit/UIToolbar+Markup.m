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

#import "UIToolbar+Markup.h"

static NSString * const kItemTag = @"item";

static NSString * const kItemTypeKey = @"type";
static NSString * const kItemTitleKey = @"title";
static NSString * const kItemImageKey = @"image";

static NSString * const kItemActionKey = @"action";

@implementation UIToolbar (Markup)

- (void)processMarkupElement:(NSString *)tag properties:(NSDictionary *)properties
{
    if ([tag isEqual:kItemTag]) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:[self items]];

        // TODO Test actions
        
        SEL action = NSSelectorFromString([properties objectForKey:kItemActionKey]);

        // TODO Check for type first

        NSString *title = [properties objectForKey:kItemTitleKey];

        UIBarButtonItem *item = nil;

        if (title != nil) {
            item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain
                target:nil action:action];
        } else {
            NSString *image = [properties objectForKey:kItemImageKey];

            if (image != nil) {
                item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:image] style:UIBarButtonItemStylePlain
                    target:nil action:action];
            }
        }

        if (item != nil) {
            [items addObject:item];
        }

        [self setItems:items];
        [self sizeToFit];
    }
}

@end
