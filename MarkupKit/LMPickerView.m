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

#import "LMPickerView.h"

@interface LMPickerViewComponent : NSObject

@property NSString* name;
@property (nonatomic, readonly) NSMutableArray *titles;

@end

@interface LMPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation LMPickerView
{
    __weak id<UIPickerViewDataSource> _dataSource;
    __weak id<UIPickerViewDelegate> _delegate;
}

#define INIT {\
    [super setDataSource:self];\
    [super setDelegate:self];\
    [self insertComponent:0];\
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

- (void)setDataSource:(id<UIPickerViewDataSource>)dataSource
{
    _dataSource = dataSource;
}

- (void)setDelegate:(id<UIPickerViewDelegate>)delegate
{
    _delegate = delegate;
}

- (void)insertComponent:(NSInteger)component
{
    // TODO
}

- (void)deleteComponent:(NSInteger)component
{
    // TODO
}

- (NSString *)nameForComponent:(NSInteger)component
{
    // TODO
    return nil;
}

- (void)setName:(nullable NSString *)name forComponent:(NSInteger)component
{
    // TODO
}

- (NSInteger)numberOfComponents
{
    // TODO
    return 0;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    // TODO
    return 0;
}

// TODO - (void)insertRow:inComponent:withTitle:value:
// TODO - (void)deleteRow:inComponent:

// TODO - (NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component:

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger n;
    if ([_dataSource respondsToSelector:@selector(numberOfComponentsInPickerView:)]) {
        n = [_dataSource numberOfComponentsInPickerView:pickerView];
    } else {
        n = [self numberOfComponents];
    }

    return n;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger n;
    if ([_dataSource respondsToSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
        n = [_dataSource pickerView:pickerView numberOfRowsInComponent:component];
    } else {
        n = [self numberOfRowsInComponent:component];
    }

    return n;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if ([_delegate respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)]) {
        view = [_delegate pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
    } else {
        view = [self viewForRow:row forComponent:component];
    }

    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [_delegate pickerView:pickerView didSelectRow:row inComponent:component];
    }
}

- (void)processMarkupInstruction:(NSString *)target data:(NSString *)data
{
    // TODO
}

- (void)appendMarkupElementView:(UIView *)view
{
    // TODO Insert view into current component
}

@end
