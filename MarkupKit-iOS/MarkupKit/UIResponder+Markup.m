//
//  UIResponder+Markup.m
//  MarkupKit-iOS
//
//  Created by Greg Brown on 1/31/17.
//
//

#import "UIResponder+Markup.h"

#import <objc/message.h>

@interface LMBinding : NSObject

@property (weak, nonatomic, readonly) id owner;
@property (nonatomic, readonly) NSString *property;

@property (weak, nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSString *keyPath;

- (instancetype)initWithOwner:(id)owner property:(NSString *)property view:(UIView *)view keyPath:(NSString *)keyPath;

@end

@implementation UIResponder (Markup)

- (NSBundle *)bundleForView
{
    return [NSBundle bundleForClass:[self class]];
}

- (NSBundle *)bundleForStrings
{
    return [NSBundle mainBundle];
}

- (void)bind:(NSString *)property toView:(UIView *)view withKeyPath:(NSString *)keyPath
{
    LMBinding *binding = [[LMBinding alloc] initWithOwner:self property:property view:view keyPath:keyPath];

    [self addObserver:binding forKeyPath:property options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];

    [view addObserver:binding forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];

    [[self bindings] addObject:binding];
}

- (void)unbindAll
{
    NSMutableArray *bindings = [self bindings];

    for (LMBinding *binding in bindings) {
        [self removeObserver:binding forKeyPath:[binding property] context:nil];

        [[binding view] removeObserver:binding forKeyPath:[binding keyPath] context:nil];
    }

    [bindings removeAllObjects];
}

- (NSMutableArray *)bindings
{
    NSMutableArray *bindings = objc_getAssociatedObject(self, @selector(bindings));

    if (bindings == nil) {
        bindings = [NSMutableArray new];

        objc_setAssociatedObject(self, @selector(bindings), bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return bindings;
}

@end

@implementation LMBinding
{
    BOOL _update;
}

- (instancetype)initWithOwner:(id)owner property:(NSString *)property view:(UIView *)view keyPath:(NSString *)keyPath
{
    self = [super init];

    if (self) {
        _owner = owner;
        _property = property;

        _view = view;
        _keyPath = keyPath;
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_update) {
        _update = YES;

        id value = [change objectForKey:NSKeyValueChangeNewKey];

        if (value != nil && value != [NSNull null]) {
            if (object == _owner) {
                [_view setValue:value forKeyPath:_keyPath];
            } else {
                [_owner setValue:value forKeyPath:_property];
            }
        }

        _update = NO;
    }
}

@end
