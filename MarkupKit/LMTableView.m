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

#import "LMTableView.h"

static NSString * const LMTableViewSectionBreakTarget = @"sectionBreak";

static NSString * const LMTableViewSectionHeaderTitleTarget = @"sectionHeaderTitle";
static NSString * const LMTableViewSectionFooterTitleTarget = @"sectionFooterTitle";

#define DEFAULT_ESTIMATED_ROW_HEIGHT 2

@interface LMTableViewSection : NSObject

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;

@property NSString *headerTitle;
@property NSString *footerTitle;

@property (nonatomic, readonly) NSMutableArray *rows;

@end

@interface LMTableView () <UITableViewDataSource>

@end

@implementation LMTableView
{
    NSMutableArray *_sections;
}

#define INIT {\
    _sections = [NSMutableArray new];\
    [self setEstimatedRowHeight:DEFAULT_ESTIMATED_ROW_HEIGHT];\
    [super setDataSource:self];\
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];

    if (self) INIT

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) INIT

    return self;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    [NSException raise:NSGenericException format:@"Cannot set data source of static table view."];
}

- (void)insertSection:(NSInteger)section
{
    [_sections insertObject:[[LMTableViewSection alloc] init] atIndex:section];
}

- (void)insertSection:(NSInteger)section withHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    [_sections insertObject:[[LMTableViewSection alloc] initWithHeaderTitle:headerTitle footerTitle:footerTitle] atIndex:section];
}

- (void)deleteSection:(NSInteger)section
{
    [_sections removeObjectAtIndex:section];
}

- (NSString *)headerTitleForSection:(NSInteger)section
{
    return [(LMTableViewSection *)[_sections objectAtIndex:section] headerTitle];
}

- (void)setHeaderTitle:(NSString *)headerTitle forSection:(NSInteger)section
{
    [(LMTableViewSection *)[_sections objectAtIndex:section] setHeaderTitle:headerTitle];
}

- (NSString *)footerTitleForSection:(NSInteger)section
{
    return [(LMTableViewSection *)[_sections objectAtIndex:section] footerTitle];
}

- (void)setFooterTitle:(NSString *)footerTitle forSection:(NSInteger)section
{
    [(LMTableViewSection *)[_sections objectAtIndex:section] setFooterTitle:footerTitle];
}

- (void)insertCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[(LMTableViewSection *)[_sections objectAtIndex:indexPath.section] rows] insertObject:cell atIndex:indexPath.row];
}

- (void)deleteCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[(LMTableViewSection *)[_sections objectAtIndex:indexPath.section] rows] removeObjectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[(LMTableViewSection *)[_sections objectAtIndex:section] rows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[(LMTableViewSection *)[_sections objectAtIndex:indexPath.section] rows]objectAtIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self headerTitleForSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self footerTitleForSection:section];
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSInteger section = [self numberOfSectionsInTableView:self] - 1;

    if (section < 0) {
        [self insertSection:++section];
    }

    NSInteger row = [self tableView:self numberOfRowsInSection:section];

    [self insertCell:(UITableViewCell *)view forRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    if ([target isEqual:LMTableViewSectionBreakTarget]) {
        [self insertSection:[self numberOfSectionsInTableView:self]];
    } else if ([target isEqual:LMTableViewSectionHeaderTitleTarget]) {
        NSString *headerTitle = [[NSBundle mainBundle] localizedStringForKey:data value:data table:nil];

        [self insertSection:[self numberOfSectionsInTableView:self] withHeaderTitle:headerTitle footerTitle:nil];
    } else if ([target isEqual:LMTableViewSectionFooterTitleTarget]) {
        NSString *footerTitle = [[NSBundle mainBundle] localizedStringForKey:data value:data table:nil];

        [self setFooterTitle:footerTitle forSection:[self numberOfSectionsInTableView:self] - 1];
    }
}

@end

@implementation LMTableViewSection

- (instancetype)init
{
    return [self initWithHeaderTitle:nil footerTitle:nil];
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    self = [super init];

    if (self) {
        _rows = [NSMutableArray new];

        _headerTitle = headerTitle;
        _footerTitle = footerTitle;
    }

    return self;
}

@end
