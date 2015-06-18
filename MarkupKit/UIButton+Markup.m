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

#import "UIButton+Markup.h"

@implementation UIButton (Markup)

+ (UIButton *)customButton
{
    return [UIButton buttonWithType:UIButtonTypeCustom];
}

+ (UIButton *)systemButton
{
    return [UIButton buttonWithType:UIButtonTypeSystem];
}

+ (UIButton *)detailDisclosureButton
{
    return [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
}

+ (UIButton *)infoLightButton
{
    return [UIButton buttonWithType:UIButtonTypeInfoLight];
}

+ (UIButton *)infoDarkButton
{
    return [UIButton buttonWithType:UIButtonTypeInfoDark];
}

+ (UIButton *)contactAddButton
{
    return [UIButton buttonWithType:UIButtonTypeContactAdd];
}

- (NSString *)normalTitle
{
    return [self titleForState:UIControlStateNormal];
}

- (void)setNormalTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

- (UIColor *)normalTitleColor
{
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setNormalTitleColor:(UIColor *)titleColor
{
    [self setTitleColor:titleColor forState:UIControlStateNormal];
}

- (UIColor *)normalTitleShadowColor
{
    return [self titleShadowColorForState:UIControlStateNormal];
}

- (void)setNormalTitleShadowColor:(UIColor *)titleShadowColor
{
    [self setTitleShadowColor:titleShadowColor forState:UIControlStateNormal];
}

- (UIImage *)normalImage
{
    return [self imageForState:UIControlStateNormal];
}

- (void)setNormalImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

- (UIImage *)normalBackgroundImage
{
    return [self backgroundImageForState:UIControlStateNormal];
}

- (void)setNormalBackgroundImage:(UIImage *)backgroundImage
{
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (NSString *)highlightedTitle
{
    return [self titleForState:UIControlStateHighlighted];
}

- (void)setHighlightedTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateHighlighted];
}

- (UIColor *)highlightedTitleColor
{
    return [self titleColorForState:UIControlStateHighlighted];
}

- (void)setHighlightedTitleColor:(UIColor *)titleColor
{
    [self setTitleColor:titleColor forState:UIControlStateHighlighted];
}

- (UIColor *)highlightedTitleShadowColor
{
    return [self titleShadowColorForState:UIControlStateHighlighted];
}

- (void)setHighlightedTitleShadowColor:(UIColor *)titleShadowColor
{
    [self setTitleShadowColor:titleShadowColor forState:UIControlStateHighlighted];
}

- (UIImage *)highlightedImage
{
    return [self imageForState:UIControlStateHighlighted];
}

- (void)setHighlightedImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateHighlighted];
}

- (UIImage *)highlightedBackgroundImage
{
    return [self backgroundImageForState:UIControlStateHighlighted];
}

- (void)setHighlightedBackgroundImage:(UIImage *)backgroundImage
{
    [self setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
}

- (NSString *)disabledTitle
{
    return [self titleForState:UIControlStateDisabled];
}

- (void)setDisabledTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateDisabled];
}

- (UIColor *)disabledTitleColor
{
    return [self titleColorForState:UIControlStateDisabled];
}

- (void)setDisabledTitleColor:(UIColor *)titleColor
{
    [self setTitleColor:titleColor forState:UIControlStateDisabled];
}

- (UIColor *)disabledTitleShadowColor
{
    return [self titleShadowColorForState:UIControlStateDisabled];
}

- (void)setDisabledTitleShadowColor:(UIColor *)titleShadowColor
{
    [self setTitleShadowColor:titleShadowColor forState:UIControlStateDisabled];
}

- (UIImage *)disabledImage
{
    return [self imageForState:UIControlStateDisabled];
}

- (void)setDisabledImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateDisabled];
}

- (UIImage *)disabledBackgroundImage
{
    return [self backgroundImageForState:UIControlStateDisabled];
}

- (void)setDisabledBackgroundImage:(UIImage *)backgroundImage
{
    [self setBackgroundImage:backgroundImage forState:UIControlStateDisabled];
}

- (NSString *)selectedTitle
{
    return [self titleForState:UIControlStateSelected];
}

- (void)setSelectedTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateSelected];
}

- (UIColor *)selectedTitleColor
{
    return [self titleColorForState:UIControlStateSelected];
}

- (void)setSelectedTitleColor:(UIColor *)titleColor
{
    [self setTitleColor:titleColor forState:UIControlStateSelected];
}

- (UIColor *)selectedTitleShadowColor
{
    return [self titleShadowColorForState:UIControlStateSelected];
}

- (void)setSelectedTitleShadowColor:(UIColor *)titleShadowColor
{
    [self setTitleShadowColor:titleShadowColor forState:UIControlStateSelected];
}

- (UIImage *)selectedImage
{
    return [self imageForState:UIControlStateSelected];
}

- (void)setSelectedImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateSelected];
}

- (UIImage *)selectedBackgroundImage
{
    return [self backgroundImageForState:UIControlStateSelected];
}

- (void)setSelectedBackgroundImage:(UIImage *)backgroundImage
{
    [self setBackgroundImage:backgroundImage forState:UIControlStateSelected];
}

@end
