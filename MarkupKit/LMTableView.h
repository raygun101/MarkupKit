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

#import <UIKit/UIKit.h>

/**
 * Table view that presents a collection of statically-defined content. 
 */
@interface LMTableView : UITableView

/**
 * Inserts a new section.
 *
 * @param section The index at which the section will be inserted.
 */
- (void)insertSection:(NSInteger)section;

/**
 * Deletes an existing section.
 *
 * @param section The index of the section to delete.
 */
- (void)deleteSection:(NSInteger)section;

/**
 * Returns the header view for a section.
 *
 * @param section The section index.
 *
 * @return The header view for the section.
 */
- (UIView *)viewForHeaderInSection:(NSInteger)section;

/**
 * Sets the header view for a section.
 * 
 * @param view The header view.
 * @param section The section index.
 */
- (void)setView:(UIView *)view forHeaderInSection:(NSInteger)section;

/**
 * Returns the footer view for a section.
 *
 * @param section The section index.
 *
 * @return The footer view for the section.
 */
- (UIView *)viewForFooterInSection:(NSInteger)section;

/**
 * Sets the footer view for a section.
 * 
 * @param view The footer view.
 * @param section The section index.
 */
- (void)setView:(UIView *)footerView forFooterInSection:(NSInteger)section;

/**
 * Inserts a new row into the table view.
 *
 * @param cell The cell representing the row to insert.
 * @param indexPath The index path at which the row will be inserted.
 */
- (void)insertCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Deletes an existing row from the table view.
 *
 * @param indexPath The index path of the row to delete.
 */
- (void)deleteCellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
