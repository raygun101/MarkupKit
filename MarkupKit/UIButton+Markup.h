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

@interface UIButton (Markup)

/**
 * Creates a system button.
 */
+ (UIButton *)systemButton;

/**
 * Creates a detail disclosure button.
 */
+ (UIButton *)detailDisclosureButton;

/**
 * Creates a light info button.
 */
+ (UIButton *)infoLightButton;

/**
 * Creates a dark info button.
 */
+ (UIButton *)infoDarkButton;

/**
 * Creates an "add contact" button.
 */
+ (UIButton *)contactAddButton;

/**
 * Creates a custom button.
 */
+ (UIButton *)customButton;

/**
 * The button's title.
 */
@property (nonatomic, nullable) NSString *title;

/**
 * The button's image.
 */
@property (nonatomic, nullable) UIImage *image;

/**
 * The button's normal title.
 */
@property (nonatomic, nullable) NSString *normalTitle DEPRECATED_ATTRIBUTE;

/**
 * The button's normal title color.
 */
@property (nonatomic, nullable) UIColor *normalTitleColor DEPRECATED_ATTRIBUTE;

/**
 * The button's normal title shadow color.
 */
@property (nonatomic, nullable) UIColor *normalTitleShadowColor DEPRECATED_ATTRIBUTE;

/**
 * The button's normal image.
 */
@property (nonatomic, nullable) UIImage *normalImage DEPRECATED_ATTRIBUTE;

/**
 * The button's normal background image.
 */
@property (nonatomic, nullable) UIImage *normalBackgroundImage DEPRECATED_ATTRIBUTE;

/**
 * The button's highlighted title.
 */
@property (nonatomic, nullable) NSString *highlightedTitle DEPRECATED_ATTRIBUTE;

/**
 * The button's highlighted title color.
 */
@property (nonatomic, nullable) UIColor *highlightedTitleColor DEPRECATED_ATTRIBUTE;

/**
 * The button's highlighted title shadow color.
 */
@property (nonatomic, nullable) UIColor *highlightedTitleShadowColor DEPRECATED_ATTRIBUTE;

/**
 * The button's highlighted image.
 */
@property (nonatomic, nullable) UIImage *highlightedImage DEPRECATED_ATTRIBUTE;

/**
 * The button's highlighted background image.
 */
@property (nonatomic, nullable) UIImage *highlightedBackgroundImage DEPRECATED_ATTRIBUTE;

/**
 * The button's disabled title.
 */
@property (nonatomic, nullable) NSString *disabledTitle DEPRECATED_ATTRIBUTE;

/**
 * The button's disabled title color.
 */
@property (nonatomic, nullable) UIColor *disabledTitleColor DEPRECATED_ATTRIBUTE;

/**
 * The button's disabled title shadow color.
 */
@property (nonatomic, nullable) UIColor *disabledTitleShadowColor DEPRECATED_ATTRIBUTE;

/**
 * The button's disabled image.
 */
@property (nonatomic, nullable) UIImage *disabledImage DEPRECATED_ATTRIBUTE;

/**
 * The button's disabled background image.
 */
@property (nonatomic, nullable) UIImage *disabledBackgroundImage DEPRECATED_ATTRIBUTE;

/**
 * The button's selected title.
 */
@property (nonatomic, nullable) NSString *selectedTitle DEPRECATED_ATTRIBUTE;

/**
 * The button's selected title color.
 */
@property (nonatomic, nullable) UIColor *selectedTitleColor DEPRECATED_ATTRIBUTE;

/**
 * The button's selected title shadow color.
 */
@property (nonatomic, nullable) UIColor *selectedTitleShadowColor DEPRECATED_ATTRIBUTE;

/**
 * The button's selected image.
 */
@property (nonatomic, nullable) UIImage *selectedImage DEPRECATED_ATTRIBUTE;

/**
 * The button's selected background image.
 */
@property (nonatomic, nullable) UIImage *selectedBackgroundImage DEPRECATED_ATTRIBUTE;

/**
 * The top content edge inset.
 */
@property (nonatomic) CGFloat contentEdgeInsetTop;

/**
 * The left content edge inset.
 */
@property (nonatomic) CGFloat contentEdgeInsetLeft;

/**
 * The bottom content edge inset.
 */
@property (nonatomic) CGFloat contentEdgeInsetBottom;

/**
 * The right content edge inset.
 */
@property (nonatomic) CGFloat contentEdgeInsetRight;

/**
 * The top title edge inset.
 */
@property (nonatomic) CGFloat titleEdgeInsetTop;

/**
 * The left title edge inset.
 */
@property (nonatomic) CGFloat titleEdgeInsetLeft;

/**
 * The bottom title edge inset.
 */
@property (nonatomic) CGFloat titleEdgeInsetBottom;

/**
 * The right title edge inset.
 */
@property (nonatomic) CGFloat titleEdgeInsetRight;

/**
 * The top image edge inset.
 */
@property (nonatomic) CGFloat imageEdgeInsetTop;

/**
 * The left image edge inset.
 */
@property (nonatomic) CGFloat imageEdgeInsetLeft;

/**
 * The bottom image edge inset.
 */
@property (nonatomic) CGFloat imageEdgeInsetBottom;

/**
 * The right image edge inset.
 */
@property (nonatomic) CGFloat imageEdgeInsetRight;

@end

NS_ASSUME_NONNULL_END
