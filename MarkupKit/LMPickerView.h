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

@interface LMPickerView : UIPickerView

/**
 * Inserts a new component.
 *
 * @param component The index at which the component will be inserted.
 */
- (void)insertComponent:(NSInteger)component;

/**
 * Deletes an existing component.
 *
 * @param component The index of the component to delete.
 */
- (void)deleteComponent:(NSInteger)component;

/**
 * Sets the name of a component.
 *
 * @param name The component name.
 * @param component The component index.
 */
- (void)setName:(nullable NSString *)name forComponent:(NSInteger)component;

// TODO - (void)insertRow:inComponent:withTitle:(NSString *) value:(nullable id)
// TODO - (void)deleteRow:inComponent

// TODO - (NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component:

@end

NS_ASSUME_NONNULL_END
