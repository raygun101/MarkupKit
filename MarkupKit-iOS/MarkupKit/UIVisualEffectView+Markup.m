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

#import "UIVisualEffectView+Markup.h"

@implementation UIVisualEffectView (Markup)

+ (UIVisualEffectView *)extraLightBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
}

+ (UIVisualEffectView *)lightBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}

+ (UIVisualEffectView *)darkBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
}

+ (UIVisualEffectView *)extraDarkBlurEffectView
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraDark]];
}

+ (UIVisualEffectView *)regularBlurEffectView
{
    UIVisualEffectView *regularBlurEffectView;
    if (@available(iOS 10, tvOS 10, *)) {
        regularBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    } else {
        regularBlurEffectView = nil;
    }

    return regularBlurEffectView;
}

+ (UIVisualEffectView *)prominentBlurEffectView
{
    UIVisualEffectView *prominentBlurEffectView;
    if (@available(iOS 10, tvOS 10, *)) {
        prominentBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
    } else {
        prominentBlurEffectView = nil;
    }

    return prominentBlurEffectView;
}

@end
