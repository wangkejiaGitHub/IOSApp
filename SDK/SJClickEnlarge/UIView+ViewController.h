//
//  UIView+ViewController.h
//  UITouch03
//
//  Created by 朱思明 on 15/8/17.
//  Copyright (c) 2015年 朱思明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewController)

/*
 为UIView扩展一个类目，通过这个方法可以获取这个视图所在的控制器
 */
- (UIViewController *)viewController;

@end
