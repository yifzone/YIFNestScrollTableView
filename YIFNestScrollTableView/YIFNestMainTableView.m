//
//  YIFNestMainTableView.m
//  YIFNestScrollTableView
//
//  Created by zhou_yuepeng on 2017/12/26.
//  Copyright © 2017年 zhou_yuepeng. All rights reserved.
//

#import "YIFNestMainTableView.h"

@interface YIFNestMainTableView () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UITableViewCell *horizontalScrollCell;
@property (nonatomic, strong) UICollectionView *horizontalCollectionView;
@property (nonatomic, strong) NSMutableDictionary *subTableViewDic; //index:subTableView
@property (nonatomic, assign) CGFloat maxOffsetY;
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation YIFNestMainTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.subTableViewDic = [NSMutableDictionary dictionaryWithCapacity:5];
        self.canScroll = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubTableViewScrollStateChangedNotification:) name:DidSubTableViewScrollStateChangedNotificationString object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.horizontalScrollCell.frame;
    frame.size.height = CGRectGetHeight(self.bounds) - self.suspendViewHeight;
    self.horizontalScrollCell.frame = frame;
    self.horizontalCollectionView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)reloadData
{
    [super reloadData];
    [self.horizontalCollectionView reloadData];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (contentOffset.y < self.maxOffsetY) {
        self.canScroll = YES;
    }
    
    [super setContentOffset:contentOffset animated:animated];
}

#pragma mark - private
- (YIFNestSubTableView *)anySubTableViewAtDic:(NSDictionary *)dic
{
    YIFNestSubTableView *subTableView = nil;
    for(NSNumber *key in dic) {
        subTableView = [dic objectForKey:key];
        break;
    }
    
    return subTableView;
}

#pragma mark - public
- (YIFNestSubTableView *)querySubTableViewWithIndex:(NSInteger)index
{
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    return [self.subTableViewDic objectForKey:indexKey];
}

- (void)scrollToSubViewAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CGPoint offset = CGPointMake(index * YIF_SCREEN_WIDTH, 0);
    [self.horizontalCollectionView setContentOffset:offset animated:animated];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf scrollViewDidEndScroll:weakSelf.horizontalCollectionView];
    });
}

- (void)scrollMainViewToMaxOffset:(BOOL)animated
{
    CGPoint offset = CGPointMake(0, self.maxOffsetY);
    [self setContentOffset:offset animated:animated];
}

- (BOOL)isMainViewScrollToMaxOffset
{
    return self.contentOffset.y >= self.maxOffsetY;
}

#pragma mark - setter
- (void)setCanScroll:(BOOL)canScroll
{
    _canScroll = canScroll;
    [[NSNotificationCenter defaultCenter] postNotificationName:DidMainTableViewScrollStateChangedNotificationString object:@(canScroll)];
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    [super setDelegate:self];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    [super setDataSource:self];
}

#pragma mark - getter
- (UITableViewCell *)horizontalScrollCell
{
    if (!_horizontalScrollCell) {
        _horizontalScrollCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _horizontalCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_horizontalScrollCell addSubview:_horizontalCollectionView];
        _horizontalCollectionView.delegate = self;
        _horizontalCollectionView.dataSource = self;
        _horizontalCollectionView.showsVerticalScrollIndicator = NO;
        _horizontalCollectionView.showsHorizontalScrollIndicator = NO;
        _horizontalCollectionView.pagingEnabled = YES;
        _horizontalCollectionView.backgroundColor = [UIColor whiteColor];
        _horizontalCollectionView.bounces = NO;
        [_horizontalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    }
    
    return _horizontalScrollCell;
}

- (CGFloat)maxOffsetY
{
    return (CGRectGetHeight(self.tableHeaderView.bounds) - self.suspendViewHeight);
}

#pragma mark - UIScrollViewDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[YIFNestSubTableView class]]) {
        return YES;
    }
         
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self) {
        if (self.horizontalCollectionView == scrollView) {
            if ([self.nestDelegate respondsToSelector:@selector(mainTableView:didHorizontalScrollToOffsetX:)]) {
                [self.nestDelegate mainTableView:self didHorizontalScrollToOffsetX:scrollView.contentOffset.x];
            }
        }
        return;
    }
    
    if (self.subTableViewDic.count <= 0) {
        //防止没有子视图时锁定了滚动
        return;
    }
    
    if (!self.canScroll) {
        scrollView.contentOffset = CGPointMake(0, self.maxOffsetY);
        return;
    }
 
    if (scrollView.contentOffset.y >= self.maxOffsetY) {
        scrollView.contentOffset = CGPointMake(0, self.maxOffsetY);
        if (self.canScroll) {
            self.canScroll = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScroll:scrollView];
}

- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView
{
    //通知外部将要加载的子view
    UICollectionViewCell *visibleCell = [self.horizontalCollectionView visibleCells].firstObject;
    NSIndexPath *indexPath = [self.horizontalCollectionView indexPathForCell:visibleCell];
    NSNumber *indexKey = [NSNumber numberWithInteger:indexPath.row];
    YIFNestSubTableView *subTableView = [self.subTableViewDic objectForKey:indexKey];
    if ([self.nestDelegate respondsToSelector:@selector(mainTableView:willLoadSubView:)]) {
        [self.nestDelegate mainTableView:self willLoadSubView:subTableView];
    }
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.horizontalScrollCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YIF_SCREEN_HEIGHT - self.suspendViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return YIF_ZERO_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return YIF_ZERO_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if ([self.nestDelegate respondsToSelector:@selector(numberOfSubsInMainTableView:)]) {
        number = [self.nestDelegate numberOfSubsInMainTableView:self];
    }
    
    return number;
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *indexKey = [NSNumber numberWithInteger:indexPath.row];
    YIFNestSubTableView *subTableView = [self.subTableViewDic objectForKey:indexKey];
    if (!subTableView) {
        if ([self.nestDelegate respondsToSelector:@selector(mainTableView:subViewForItemAtIndex:)]) {
            subTableView = [self.nestDelegate mainTableView:self subViewForItemAtIndex:indexPath.row];
        }
        
        if (!subTableView) {
            
        }
        
        subTableView.index = indexPath.row;
        subTableView.canScroll = !self.canScroll;
        [self.subTableViewDic setObject:subTableView forKey:indexKey];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell addSubview:subTableView];
    subTableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.horizontalCollectionView.bounds), CGRectGetHeight(self.horizontalCollectionView.bounds));
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.horizontalCollectionView.bounds.size;
}

#pragma mark - notifycation
- (void)didSubTableViewScrollStateChangedNotification:(NSNotification *)notification
{
    NSNumber *state = notification.object;
    _canScroll = !(state.boolValue);
}
@end
