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

#import "NSByteCountFormatter+Markup.h"
#import "NSObject+Markup.h"

static NSDictionary *byteCountFormatterUnitValues;
static NSDictionary *byteCountFormatterCountStyleValues;

@implementation NSByteCountFormatter (Markup)

+ (void)initialize
{
    byteCountFormatterUnitValues = @{
        @"useBytes": @(NSByteCountFormatterUseBytes),
        @"useKB": @(NSByteCountFormatterUseKB),
        @"useMB": @(NSByteCountFormatterUseMB),
        @"useGB": @(NSByteCountFormatterUseGB),
        @"useTB": @(NSByteCountFormatterUseTB),
        @"usePB": @(NSByteCountFormatterUsePB),
        @"useEB": @(NSByteCountFormatterUseEB),
        @"useZB": @(NSByteCountFormatterUseZB),
        @"useYBOrHigher": @(NSByteCountFormatterUseYBOrHigher),
        @"useAll": @(NSByteCountFormatterUseAll)
    };

    byteCountFormatterCountStyleValues = @{
        @"file": @(NSByteCountFormatterCountStyleFile),
        @"memory": @(NSByteCountFormatterCountStyleMemory),
        @"decimal": @(NSByteCountFormatterCountStyleDecimal),
        @"binary": @(NSByteCountFormatterCountStyleBinary)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"allowedUnits"]) {
        NSArray *components = [value componentsSeparatedByString:@","];

        NSByteCountFormatterUnits byteCountFormatterUnits = 0;

        for (NSString *component in components) {
            NSString *name = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            byteCountFormatterUnits |= [[byteCountFormatterUnitValues objectForKey:name] unsignedIntegerValue];
        }

        value = @(byteCountFormatterUnits);
    } else if ([key isEqual:@"countStyle"]) {
        value = [byteCountFormatterCountStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end
