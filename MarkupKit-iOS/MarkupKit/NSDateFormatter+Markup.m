//
//  NSDateFormatter+Markup.m
//  MarkupKit
//
//  Created by Greg Brown on 5/22/18.
//

#import "NSDateFormatter+Markup.h"
#import "NSObject+Markup.h"

static NSDictionary *dateFormatterStyleValues;

@implementation NSDateFormatter (Markup)

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
