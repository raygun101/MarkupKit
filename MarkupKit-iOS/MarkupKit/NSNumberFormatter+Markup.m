//
//  NSNumberFormatter+Markup.m
//  MarkupKit
//
//  Created by Greg Brown on 5/22/18.
//

#import "NSNumberFormatter+Markup.h"
#import "NSObject+Markup.h"

static NSDictionary *numberFormatterStyleValues;

@implementation NSNumberFormatter (Markup)

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
