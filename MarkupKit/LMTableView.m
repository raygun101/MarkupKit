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
#import "UITableViewCell+Markup.h"

static NSString * const kSectionBreakTarget = @"sectionBreak";

static NSString * const kSectionNameTarget = @"sectionName";
static NSString * const kSectionSelectionModeTarget = @"sectionSelectionMode";

static NSString * const kSectionHeaderViewTarget = @"sectionHeaderView";
static NSString * const kSectionFooterViewTarget = @"sectionFooterView";

#define ESTIMATED_HEIGHT 2

typedef enum {
    kElementDefault,
    kElementSectionHeaderView,
    kElementSectionFooterView
} __ElementDisposition;

@interface LMTableViewSection : NSObject

@property (nonatomic) NSString* name;
@property (nonatomic) LMTableViewSelectionMode selectionMode;

@property (nonatomic) UIView *headerView;
@property (nonatomic) UIView *footerView;

@property (nonatomic, readonly) NSMutableArray *rows;

@end

@interface LMTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation LMTableView
{
    __weak id<UITableViewDataSource> _dataSource;
    __weak id<UITableViewDelegate> _delegate;

    NSMutableArray *_sections;

    __ElementDisposition _elementDisposition;
}

#define INIT {\
    _sections = [NSMutableArray new];\
    _elementDisposition = kElementDefault;\
    [super setEstimatedRowHeight:ESTIMATED_HEIGHT];\
    [super setEstimatedSectionHeaderHeight:ESTIMATED_HEIGHT];\
    [super setEstimatedSectionFooterHeight:ESTIMATED_HEIGHT];\
    [super setDataSource:self];\
    [super setDelegate:self];\
    [self insertSection:0];\
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
    _dataSource = dataSource;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    _delegate = delegate;
}

- (void)insertSection:(NSInteger)section
{
    [_sections insertObject:[LMTableViewSection new] atIndex:section];
}

- (void)deleteSection:(NSInteger)section
{
    [_sections removeObjectAtIndex:section];
}

- (NSInteger)numberOfSections
{
    return [_sections count];
}

- (NSString *)nameForSection:(NSInteger)section
{
    return [[_sections objectAtIndex:section] name];
}

- (void)setName:(NSString *)name forSection:(NSInteger)section
{
    [[_sections objectAtIndex:section] setName:name];
}

- (LMTableViewSelectionMode)selectionModeForSection:(NSInteger)section
{
    return [[_sections objectAtIndex:section] selectionMode];
}

- (void)setSelectionMode:(LMTableViewSelectionMode)selectionMode forSection:(NSInteger)section
{
    [[_sections objectAtIndex:section] setSelectionMode:selectionMode];
}

- (UIView *)viewForHeaderInSection:(NSInteger)section
{
    return [[_sections objectAtIndex:section] headerView];
}

- (void)setView:(UIView *)view forHeaderInSection:(NSInteger)section
{
    [[_sections objectAtIndex:section] setHeaderView:view];
}

- (UIView *)viewForFooterInSection:(NSInteger)section
{
    return [[_sections objectAtIndex:section] footerView];
}

- (void)setView:(UIView *)footerView forFooterInSection:(NSInteger)section
{
    [[_sections objectAtIndex:section] setFooterView:footerView];
}

- (void)insertCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[_sections objectAtIndex:indexPath.section] rows] insertObject:cell atIndex:indexPath.row];
}

- (void)deleteCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[_sections objectAtIndex:indexPath.section] rows] removeObjectAtIndex:indexPath.row];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [[[_sections objectAtIndex:section] rows] count];
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[_sections objectAtIndex:indexPath.section] rows] objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n;
    if ([_dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        n = [_dataSource tableView:tableView numberOfRowsInSection:section];
    } else {
        n = [self numberOfRowsInSection:section];
    }

    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([_dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        cell = [_dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = [self cellForRowAtIndexPath:indexPath];
    }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        indexPath = [_delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];

    LMTableViewSelectionMode selectionMode = [self selectionModeForSection:section];

    if (selectionMode != LMTableViewSelectionModeDefault) {
        NSInteger row = [indexPath row];

        switch (selectionMode) {
            case LMTableViewSelectionModeSingleCheckmark: {
                // Uncheck all cells except for current selection
                NSArray *rows = [[_sections objectAtIndex:section] rows];

                for (NSInteger i = 0, n = [rows count]; i < n; i++) {
                    [[rows objectAtIndex:i] setChecked:(i == row)];
                }

                break;
            }

            case LMTableViewSelectionModeMultipleCheckmarks: {
                // Toggle check state of current selection
                UITableViewCell *cell = [[[_sections objectAtIndex:section] rows] objectAtIndex:row];

                [cell setChecked:![cell checked]];

                break;
            }

            default: {
                [NSException raise:NSInternalInconsistencyException format:@"Unexpected selection mode."];
            }
        }

        [self deselectRowAtIndexPath:indexPath animated:YES];
    }

    if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        indexPath = [_delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [_delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self viewForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self viewForFooterInSection:section];
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    if ([target isEqual:kSectionBreakTarget]) {
        [self insertSection:[self numberOfSections]];
    } else if ([target isEqual:kSectionNameTarget]) {
        [self setName:data forSection:[self numberOfSections] - 1];
    } else if ([target isEqual:kSectionSelectionModeTarget]) {
        LMTableViewSelectionMode selectionMode;
        if ([data isEqual:@"default"]) {
            selectionMode = LMTableViewSelectionModeDefault;
        } else if ([data isEqual:@"singleCheckmark"]) {
            selectionMode = LMTableViewSelectionModeSingleCheckmark;
        } else if ([data isEqual:@"multipleCheckmarks"]) {
            selectionMode = LMTableViewSelectionModeMultipleCheckmarks;
        } else {
            return;
        }

        [self setSelectionMode: selectionMode forSection:[self numberOfSections] - 1];
    } else if ([target isEqual:kSectionHeaderViewTarget]) {
        _elementDisposition = kElementSectionHeaderView;
    } else if ([target isEqual:kSectionFooterViewTarget]) {
        _elementDisposition = kElementSectionFooterView;
    }
}

- (void)appendMarkupElementView:(UIView *)view
{
    NSInteger section = [self numberOfSections] - 1;

    switch (_elementDisposition) {
        case kElementDefault: {
            NSInteger row = [self tableView:self numberOfRowsInSection:section];

            [self insertCell:(UITableViewCell *)view forRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

            break;
        }

        case kElementSectionHeaderView: {
            [[_sections objectAtIndex:section] setHeaderView:view];

            break;
        }

        case kElementSectionFooterView: {
            [[_sections objectAtIndex:section] setFooterView:view];

            break;
        }

        default: {
            [NSException raise:NSInternalInconsistencyException format:@"Unexpected element disposition."];
        }
    }

    _elementDisposition = kElementDefault;
}

@end

@implementation LMTableViewSection

- (instancetype)init
{
    self = [super init];

    if (self) {
        _selectionMode = LMTableViewSelectionModeDefault;
        
        _rows = [NSMutableArray new];
    }

    return self;
}

@end
