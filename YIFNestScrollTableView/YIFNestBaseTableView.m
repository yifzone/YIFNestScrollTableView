//
//  YIFNestBaseTableView.m
//  YIFNestScrollTableView
//
//  Created by zhou_yuepeng on 2017/12/26.
//  Copyright © 2017年 zhou_yuepeng. All rights reserved.
//

#import "YIFNestBaseTableView.h"

@implementation YIFNestBaseTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    
    return self;
}
@end
