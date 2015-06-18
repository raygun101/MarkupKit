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

#import "UISegmentedControl+Markup.h"

static NSString * const LMSegmentTitleTarget = @"segmentTitle";
static NSString * const LMSegmentImageTarget = @"segmentImage";

@implementation UISegmentedControl (Markup)

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    NSUInteger index = [self numberOfSegments];

    if ([target isEqual:LMSegmentTitleTarget]) {
        NSString *title = [[NSBundle mainBundle] localizedStringForKey:data value:data table:nil];

        [self insertSegmentWithTitle:title atIndex:index animated:NO];
    } else if ([target isEqual:LMSegmentImageTarget]) {
        UIImage *image = [UIImage imageNamed:data];

        [self insertSegmentWithImage:image atIndex:index animated:NO];
    }
}

@end
