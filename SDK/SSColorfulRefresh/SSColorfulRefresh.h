//
//  SSColorfulRefresh.h
//  SSColorfulRefresh
//
//  Created by Mrss on 16/3/1.
//  Copyright © 2016年 expai. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SSColorfulRefresh : UIControl

//the count of color must be 6.
//clockwise.

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                            colors:(NSArray <UIColor *> *)colors;

- (void)beginRefreshing;

- (void)endRefreshing;

@end
