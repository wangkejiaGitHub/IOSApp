//
//  UIView+ViewController.m
//  UITouch03
//
//  Created by 朱思明 on 15/8/17.
//  Copyright (c) 2015年 朱思明. All rights reserved.
//

#import "UIView+ViewController.h"

@implementation UIView (ViewController)

/**
 *  为UIView扩展一个类目，通过这个方法可以获取这个视图所在的控制器
 *
 *  @return 返回你找到的父类的控制器
 */
- (UIViewController *)viewController
{
    // 获取当前对象的下一响应者
    UIResponder *next = self.nextResponder;
    
    while (![next isKindOfClass:[UIViewController class]] && next != nil) {
        // 获取next对象的下一响应者
        next = next.nextResponder;
    }

    return (UIViewController *)next;
}


@end
