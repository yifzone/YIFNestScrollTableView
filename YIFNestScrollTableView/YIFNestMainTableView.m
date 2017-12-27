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
@end

@implementation YIFNestMainTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {        
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.subTableViewDic = [NSMutableDictionary dictionaryWithCapacity:5];
        self.canScroll = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubTableViewArrivedTopNotification:) name:DidSubTableViewArrivedTopNotificationString object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - setter
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
        CGRect frame = CGRectMake(0, 0, YIF_SCREEN_WIDTH, YIF_SCREEN_HEIGHT - self.suspendViewHeight);
        _horizontalScrollCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame));
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _horizontalCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [_horizontalScrollCell addSubview:_horizontalCollectionView];
        _horizontalCollectionView.delegate = self;
        _horizontalCollectionView.dataSource = self;
        _horizontalCollectionView.showsVerticalScrollIndicator = NO;
        _horizontalCollectionView.showsHorizontalScrollIndicator = NO;
        _horizontalCollectionView.pagingEnabled = YES;
        _horizontalCollectionView.backgroundColor = [UIColor whiteColor];
        _horizontalCollectionView.alwaysBounceVertical = NO;
        [_horizontalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    }
    
    return _horizontalScrollCell;
}

#pragma mark - UIScrollViewDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self) {
        return;
    }
 
    CGFloat maxOffsetY = (CGRectGetHeight(self.tableHeaderView.bounds) - self.suspendViewHeight);
    if (scrollView.contentOffset.y >= maxOffsetY) {
        scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        if (self.canScroll) {
            self.canScroll = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:DidMainTableViewArrivedTopNotificationString object:nil];
        }
    }else{
        if (!self.canScroll) {//子视图没到顶部
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView != self.horizontalCollectionView) {
        return;
    }
    
    self.scrollEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView != self.horizontalCollectionView) {
        return;
    }
    
    self.scrollEnabled = YES;
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
        subTableView.canScroll = [self anySubTableViewAtDic:self.subTableViewDic].canScroll;
        [self.subTableViewDic setObject:subTableView forKey:indexKey];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell addSubview:subTableView];
    subTableView.frame = CGRectMake(0, 0, YIF_SCREEN_WIDTH, YIF_SCREEN_HEIGHT - self.suspendViewHeight);
    
    if ([self.nestDelegate respondsToSelector:@selector(mainTableView:willLoadSubView:)]) {
        [self.nestDelegate mainTableView:self willLoadSubView:subTableView];
    }
    
    return cell;
}

#pragma mark - notifycation
- (void)didSubTableViewArrivedTopNotification:(NSNotification *)notification
{
    self.canScroll = YES;
}
@end
