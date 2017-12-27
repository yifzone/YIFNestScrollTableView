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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMainTableViewArrivedTopNotification:) name:DidMainTableViewArrivedTopNotificationString object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubTableViewArrivedTopNotification:) name:DidSubTableViewArrivedTopNotificationString object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter
- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    _adapterDelegate = delegate;
    [super setDelegate:self];
}

#pragma mark - 消息转发
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.adapterDelegate respondsToSelector:aSelector]) {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:DidSubTableViewArrivedTopNotificationString object:nil];
        }
    }
}

#pragma mark - notifycation
- (void)didMainTableViewArrivedTopNotification:(NSNotification *)notification
{
    self.canScroll = YES;
}

- (void)didSubTableViewArrivedTopNotification:(NSNotification *)notification
{
    //子view响应该消息将自己滚动到顶部
    self.contentOffset = CGPointZero;
}
@end
