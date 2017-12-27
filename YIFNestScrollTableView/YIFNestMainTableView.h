//
//  YIFNestMainTableView.h
//  YIFNestScrollTableView
//
//  Created by zhou_yuepeng on 2017/12/26.
//  Copyright © 2017年 zhou_yuepeng. All rights reserved.
//

#import "YIFNestBaseTableView.h"
#import "YIFNestSubTableView.h"

@protocol YIFNestMainTableViewDelegate;
@interface YIFNestMainTableView : YIFNestBaseTableView
@property (nonatomic, weak) id<YIFNestMainTableViewDelegate> nestDelegate;
@property (nonatomic, assign) CGFloat suspendViewHeight;
@property (nonatomic, assign, readonly) BOOL canScroll;

- (YIFNestSubTableView *)querySubTableViewWithIndex:(NSInteger)index;
- (void)scrollToSubViewAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollMainViewToMaxOffset:(BOOL)animated;
- (BOOL)isMainViewScrollToMaxOffset;
@end

@protocol YIFNestMainTableViewDelegate <NSObject>
- (NSInteger)numberOfSubsInMainTableView:(YIFNestMainTableView *)mainTableView;
- (YIFNestSubTableView *)mainTableView:(YIFNestMainTableView *)mainTableView subViewForItemAtIndex:(NSInteger)index;
- (void)mainTableView:(YIFNestMainTableView *)mainTableView willLoadSubView:(YIFNestSubTableView *)subView;
- (void)mainTableView:(YIFNestMainTableView *)mainTableView didHorizontalScrollToOffsetX:(CGFloat)offsetX;
@end
