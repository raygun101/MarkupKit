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

#import "UITableView+Markup.h"
#import "UITableViewCell+Markup.h"

@implementation UITableView (Markup)

+ (UITableView *)plainTableView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
}

+ (UITableView *)groupedTableView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
}

- (NSString *)nameForSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)sectionWithName:(NSString *)name
{
    NSInteger section = 0, n = [self numberOfSections];

    while (section < n && ![[self nameForSection:section] isEqual:name]) {
        section++;
    }

    return (section < n) ? section : NSNotFound;
}

- (NSInteger)rowForCellWithValue:(id)value inSection:(NSInteger)section
{
    NSInteger row = 0, n = [self numberOfRowsInSection:section];

    while (row < n && ![[[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]] value] isEqual:value]) {
        row++;
    }

    return (row < n) ? row : NSNotFound;
}

@end
