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

#import "UISearchBar+Markup.h"
#import "Foundation+Markup.h"

static NSDictionary *searchBarStyleValues;

@implementation UISearchBar (Markup)

+ (void)initialize
{
    searchBarStyleValues = @{
        @"default": @(UISearchBarStyleDefault),
        @"prominent": @(UISearchBarStyleProminent),
        @"minimal": @(UISearchBarStyleMinimal)
    };
}

- (void)applyMarkupPropertyValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual:@"searchBarStyle"]) {
        value = [searchBarStyleValues objectForKey:value];
    }

    [super applyMarkupPropertyValue:value forKey:key];
}

@end
