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
 * Class that reads a view hierarchy from markup.
 */
@interface LMViewBuilder : NSObject

/**
 * Loads a named view.
 *
 * @param name The name of the view to load.
 * @param owner The view's owner.
 * @param root The root view, or <tt>nil</tt> for no root view.
 *
 * @return The named view, or <tt>nil</tt> if the view could not be loaded.
 */
+ (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root;

/**
 * Decodes a color value.
 *
 * @param value The encoded color value.
 *
 * @return The decoded color value.
 */
+ (UIColor *)colorValue:(NSString *)value;

/**
 * Decodes a font value.
 *
 * @param value The encoded font value.
 *
 * @return The decoded font value.
 */
+ (UIFont *)fontValue:(NSString *)value;

@end
