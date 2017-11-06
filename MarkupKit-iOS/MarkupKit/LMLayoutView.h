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

/**
 * Abstract base class for layout views.
 */
@interface LMLayoutView : UIView

/**
 * Specifies that subviews will be arranged relative to the view's layout margins.
 * The default value is <code>YES</code>.
 */
@property (nonatomic) BOOL layoutMarginsRelativeArrangement;

/**
 * The amount of space to reserve at the top of the view. The default is 0.
 */
@property (nonatomic) CGFloat topSpacing;

/**
 * The amount of space to reserve at the bottom of the view. The default is 0.
 */
@property (nonatomic) CGFloat bottomSpacing;

/**
 * The amount of space to reserve at the view's leading edge. The default is 0.
 */
@property (nonatomic) CGFloat leadingSpacing;

/**
 * The amount of space to reserve at the view's trailing edge. The default is 0.
 */
@property (nonatomic) CGFloat trailingSpacing;

@end

NS_ASSUME_NONNULL_END

