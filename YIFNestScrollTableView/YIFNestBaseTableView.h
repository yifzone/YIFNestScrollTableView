//
//  YIFNestBaseTableView.h
//  YIFNestScrollTableView
//
//  Created by zhou_yuepeng on 2017/12/26.
//  Copyright © 2017年 zhou_yuepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YIF_ZERO_HEIGHT (0.01f)
#define YIF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define YIF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define DidSubTableViewArrivedTopNotificationString @"DidSubTableViewArrivedTopNotificationString"
#define DidMainTableViewArrivedTopNotificationString @"DidMainTableViewArrivedTopNotificationString"

@interface YIFNestBaseTableView : UITableView
@property (nonatomic, assign) BOOL canScroll;
@end
