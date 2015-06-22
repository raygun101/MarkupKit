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

#import "LMLayoutView.h"

/**
 * Box view alignment options.
 */
typedef NS_ENUM(NSInteger, LMBoxViewAlignment) {
    /** Top layout alignment. */
	LMBoxViewAlignmentTop,

    /** Bottom layout alignment. */
	LMBoxViewAlignmentBottom,

    /** Left layout alignment. */
	LMBoxViewAlignmentLeft,

    /** Right layout alignment. */
	LMBoxViewAlignmentRight,

    /** Leading layout alignment. */
	LMBoxViewAlignmentLeading,

    /** Trailing layout alignment. */
	LMBoxViewAlignmentTrailing,

    /** Center layout alignment. */
	LMBoxViewAlignmentCenter,

    /** Baseline layout alignment. */
	LMBoxViewAlignmentBaseline,

    /** Fill layout alignment. */
	LMBoxViewAlignmentFill
};

/**
 * Abstract base class for box views.
 */
@interface LMBoxView : LMLayoutView

/**
 * Initializes the box view with a frame and an alignment.
 */
- (instancetype)initWithFrame:(CGRect)frame alignment:(LMBoxViewAlignment)alignment;

/**
 * Initializes the box view with a coder and an alignment.
 */
- (id)initWithCoder:(NSCoder *)decoder alignment:(LMBoxViewAlignment)alignment;

/**
 * Defines how subviews are aligned.
 */
@property (nonatomic) LMBoxViewAlignment alignment;

/**
 * The amount of spacing between successive subviews.
 */
@property (nonatomic) CGFloat spacing;

@end
