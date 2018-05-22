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

#import "NSString+Markup.h"

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
