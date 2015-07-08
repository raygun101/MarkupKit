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

@interface UIView (Markup)

/**
 * The view's weight.
 */
@property (nonatomic) CGFloat weight;

/**
 * The view's horizontal content compression resistance priority.
 */
@property (nonatomic) CGFloat horizontalContentCompressionResistancePriority;

/**
 * The view's horizontal content hugging priority.
 */
@property (nonatomic) CGFloat horizontalContentHuggingPriority;

/**
 * The view's vertical content compression resistance priority.
 */
@property (nonatomic) CGFloat verticalContentCompressionResistancePriority;

/**
 * The view's vertical content hugging priority.
 */
@property (nonatomic) CGFloat verticalContentHuggingPriority;

/**
 * The top layout margin.
 */
@property (nonatomic) CGFloat layoutMarginTop;

/**
 * The left layout margin.
 */
@property (nonatomic) CGFloat layoutMarginLeft;

/**
 * The bottom layout margin.
 */
@property (nonatomic) CGFloat layoutMarginBottom;

/**
 * The right layout margin.
 */
@property (nonatomic) CGFloat layoutMarginRight;

/**
 * Processes a markup instruction.
 */
- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data;

/**
 * Appends a sub-element view from markup.
 */
- (void)appendMarkupElementView:(UIView *)view;

@end
