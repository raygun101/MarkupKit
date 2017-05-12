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

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Markup) <UITableViewDataSource, UITableViewDelegate>

/**
 * Returns the name of a section.
 *
 * @param section The section index.
 *
 * @return The section's name.
 */
- (nullable NSString *)nameForSection:(NSInteger)section;

/**
 * Returns the index of the first section with a given name.
 *
 * @param name The section name.
 *
 * @return The section index, or <code>NSNotFound</code> if a matching section was not found.
 */
- (NSInteger)sectionWithName:(NSString *)name;

/**
 * Returns the value associated with the first checked cell in a given section.
 *
 * @param section The section index.
 *
 * @return The associated cell value, or <code>nil</code> if no cell is checked.
 */
- (nullable id)valueForSection:(NSInteger)section;

/**
 * Returns the values associated with all checked cells in a given section.
 *
 * @param section The section index.
 *
 * @return The associated cell values. The array will be empty if no cells are checked.
 */
- (NSArray *)valuesForSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
