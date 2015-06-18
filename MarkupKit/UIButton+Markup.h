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

@interface UIButton (Markup)

/**
 * Creates a custom button.
 */
+ (UIButton *)customButton;

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
 * The button's normal title.
 */
@property (nonatomic) NSString *normalTitle;

/**
 * The button's normal title color.
 */
@property (nonatomic) UIColor *normalTitleColor;

/**
 * The button's normal title shadow color.
 */
@property (nonatomic) UIColor *normalTitleShadowColor;

/**
 * The button's normal image.
 */
@property (nonatomic) UIImage *normalImage;

/**
 * The button's normal background image.
 */
@property (nonatomic) UIImage *normalBackgroundImage;

/**
 * The button's highlighted title.
 */
@property (nonatomic) NSString *highlightedTitle;

/**
 * The button's highlighted title color.
 */
@property (nonatomic) UIColor *highlightedTitleColor;

/**
 * The button's highlighted title shadow color.
 */
@property (nonatomic) UIColor *highlightedTitleShadowColor;

/**
 * The button's highlighted image.
 */
@property (nonatomic) UIImage *highlightedImage;

/**
 * The button's highlighted background image.
 */
@property (nonatomic) UIImage *highlightedBackgroundImage;

/**
 * The button's disabled title.
 */
@property (nonatomic) NSString *disabledTitle;

/**
 * The button's disabled title color.
 */
@property (nonatomic) UIColor *disabledTitleColor;

/**
 * The button's disabled title shadow color.
 */
@property (nonatomic) UIColor *disabledTitleShadowColor;

/**
 * The button's disabled image.
 */
@property (nonatomic) UIImage *disabledImage;

/**
 * The button's disabled background image.
 */
@property (nonatomic) UIImage *disabledBackgroundImage;

/**
 * The button's selected title.
 */
@property (nonatomic) NSString *selectedTitle;

/**
 * The button's selected title color.
 */
@property (nonatomic) UIColor *selectedTitleColor;

/**
 * The button's selected title shadow color.
 */
@property (nonatomic) UIColor *selectedTitleShadowColor;

/**
 * The button's selected image.
 */
@property (nonatomic) UIImage *selectedImage;

/**
 * The button's selected background image.
 */
@property (nonatomic) UIImage *selectedBackgroundImage;

@end
