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

#import "Foundation+Markup.h"

@implementation NSObject (Markup)

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if (value != nil && value != [NSNull null]) {
        [self setValue:value forKey:key];
    }
}

- (void)applyMarkupPropertyValue:(id)value forKeyPath:(NSString *)keyPath
{
    NSArray *components = [keyPath componentsSeparatedByString:@"."];

    NSUInteger n = [components count];

    id target = self;

    for (NSUInteger i = 0; i < n - 1; i++) {
        target = [target valueForKey:[components objectAtIndex:i]];
    }

    [target applyMarkupPropertyValue:value forKey:[components objectAtIndex:n - 1]];
}

@end

@implementation NSString (Markup)

- (char)charValue
{
    return [self boolValue];
}

- (short)shortValue
{
    return [[NSNumber numberWithInteger:[self integerValue]] shortValue];
}

- (long)longValue
{
    return [[NSNumber numberWithInteger:[self integerValue]] longValue];
}

- (unsigned long long) unsignedLongLongValue
{
    return [[NSNumber numberWithLongLong:[self longLongValue]] unsignedLongLongValue];
}

@end

@implementation NSNumberFormatter (Markup)

static NSDictionary *numberFormatterStyleValues;

+ (void)initialize
{
    numberFormatterStyleValues = @{
        @"none": @(NSNumberFormatterNoStyle),
        @"decimal": @(NSNumberFormatterDecimalStyle),
        @"currency": @(NSNumberFormatterCurrencyStyle),
        @"percent": @(NSNumberFormatterPercentStyle),
        @"scientific": @(NSNumberFormatterScientificStyle),
        @"spellOut": @(NSNumberFormatterSpellOutStyle),
        @"ordinal": @(NSNumberFormatterOrdinalStyle),
        @"currencyISOCode": @(NSNumberFormatterCurrencyISOCodeStyle),
        @"currencyPlural": @(NSNumberFormatterCurrencyPluralStyle),
        @"currencyAccounting": @(NSNumberFormatterCurrencyAccountingStyle)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"numberStyle"]) {
        value = [numberFormatterStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation NSDateFormatter (Markup)

static NSDictionary *dateFormatterStyleValues;

+ (void)initialize
{
    dateFormatterStyleValues = @{
        @"none": @(NSDateFormatterNoStyle),
        @"short": @(NSDateFormatterShortStyle),
        @"medium": @(NSDateFormatterMediumStyle),
        @"long": @(NSDateFormatterLongStyle),
        @"full": @(NSDateFormatterFullStyle)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"dateStyle"] || [key isEqual:@"timeStyle"]) {
        value = [dateFormatterStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation NSPersonNameComponentsFormatter (Markup)

static NSDictionary *personNameComponentsFormatterStyleValues;

+ (void)initialize
{
    personNameComponentsFormatterStyleValues = @{
        @"short": @(NSPersonNameComponentsFormatterStyleShort),
        @"medium": @(NSPersonNameComponentsFormatterStyleMedium),
        @"long": @(NSPersonNameComponentsFormatterStyleLong)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"style"]) {
        value = [personNameComponentsFormatterStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

@implementation NSByteCountFormatter (Markup)

static NSDictionary *byteCountFormatterUnitValues;
static NSDictionary *byteCountFormatterCountStyleValues;

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

@implementation NSMeasurementFormatter (Markup)

static NSDictionary *measurementFormatterUnitOptionValues;
static NSDictionary *formattingUnitStyles;

+ (void)initialize
{
    measurementFormatterUnitOptionValues = @{
        @"providedUnit": @(NSMeasurementFormatterUnitOptionsProvidedUnit),
        @"naturalScale": @(NSMeasurementFormatterUnitOptionsNaturalScale),
        @"temperatureWithoutUnit": @(NSMeasurementFormatterUnitOptionsTemperatureWithoutUnit)
    };

    formattingUnitStyles = @{
        @"short": @(NSFormattingUnitStyleShort),
        @"medium": @(NSFormattingUnitStyleMedium),
        @"long": @(NSFormattingUnitStyleLong)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"unitOptions"]) {
        value = [measurementFormatterUnitOptionValues objectForKey:value];
    } else if ([key isEqual:@"unitStyle"]) {
        value = [formattingUnitStyles objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end

