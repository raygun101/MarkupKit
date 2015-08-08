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

#import "LMBoxView.h"

#define DEFAULT_ALIGNMENT LMBoxViewAlignmentFill
#define DEFAULT_SPACING 8

@implementation LMBoxView

#define INIT {\
    _alignment = DEFAULT_ALIGNMENT;\
    _spacing = DEFAULT_SPACING;\
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) INIT

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) INIT

    return self;
}

- (void)setAlignment:(LMBoxViewAlignment)alignment
{
    _alignment = alignment;

    [self setNeedsUpdateConstraints];
}

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;

    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"alignment"]) {
        // Translate to box view alignment
        LMBoxViewAlignment boxViewAlignment;
        if ([value isEqual:@"top"]) {
            boxViewAlignment = LMBoxViewAlignmentTop;
        } else if ([value isEqual:@"bottom"]) {
            boxViewAlignment = LMBoxViewAlignmentBottom;
        } else if ([value isEqual:@"left"]) {
            boxViewAlignment = LMBoxViewAlignmentLeft;
        } else if ([value isEqual:@"right"]) {
            boxViewAlignment = LMBoxViewAlignmentRight;
        } else if ([value isEqual:@"leading"]) {
            boxViewAlignment = LMBoxViewAlignmentLeading;
        } else if ([value isEqual:@"trailing"]) {
            boxViewAlignment = LMBoxViewAlignmentTrailing;
        } else if ([value isEqual:@"center"]) {
            boxViewAlignment = LMBoxViewAlignmentCenter;
        } else if ([value isEqual:@"baseline"]) {
            boxViewAlignment = LMBoxViewAlignmentBaseline;
        } else if ([value isEqual:@"fill"]) {
            boxViewAlignment = LMBoxViewAlignmentFill;
        } else {
            boxViewAlignment = [value intValue];
        }

        value = [NSNumber numberWithInt:boxViewAlignment];
    }

    [super setValue:value forKey:key];
}

@end
