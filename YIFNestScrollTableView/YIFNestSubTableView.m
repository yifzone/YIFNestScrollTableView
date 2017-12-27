//
//  YIFNestSubTableView.m
//  YIFNestScrollTableView
//
//  Created by zhou_yuepeng on 2017/12/26.
//  Copyright © 2017年 zhou_yuepeng. All rights reserved.
//

#import "YIFNestSubTableView.h"

@interface YIFNestSubTableView() <UIScrollViewDelegate, UITableViewDelegate>
@property (nonatomic, weak)   id<UITableViewDelegate> adapterDelegate;
@end

@implementation YIFNestSubTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMainTableViewScrollStateChangedNotification:) name:DidMainTableViewScrollStateChangedNotificationString object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubTableViewScrollStateChangedNotification:) name:DidSubTableViewScrollStateChangedNotificationString object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (contentOffset.y >= 0) {
        self.canScroll = YES;
    }
    
    [super setContentOffset:contentOffset animated:animated];
}

#pragma mark - setter
- (void)setCanScroll:(BOOL)canScroll
{
    _canScroll = canScroll;
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSubTableViewScrollStateChangedNotificationString object:@(canScroll)];
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    _adapterDelegate = delegate;
    [super setDelegate:self];
}

#pragma mark - 消息转发
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (self != self.adapterDelegate && [self.adapterDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.adapterDelegate respondsToSelector:aSelector]) {
        return self.adapterDelegate;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.canScroll) {
        scrollView.contentOffset = CGPointZero;
        return;
    }
    
    if (scrollView.contentOffset.y <= 0) {
        if (self.canScroll) {
            self.canScroll = NO;
        }
    }
}

#pragma mark - notifycation
- (void)didMainTableViewScrollStateChangedNotification:(NSNotification *)notification
{
    NSNumber *state = notification.object;
    _canScroll = !(state.boolValue);
}

- (void)didSubTableViewScrollStateChangedNotification:(NSNotification *)notification
{
    NSNumber *state = notification.object;
    _canScroll = state.boolValue;
    if (!state.boolValue) {
        //子view响应该消息将自己滚动到顶部
        self.contentOffset = CGPointZero;
    }
}
@end
