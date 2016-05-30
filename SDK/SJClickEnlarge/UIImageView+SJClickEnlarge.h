//
//  UIImageView+SJClickEnlarge.h
//  Init
//
//  Created by 赵世杰 on 16/4/11.
//  Copyright © 2016年 zhaoshijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SJClickEnlarge)


#pragma mark - 变量-------------------------------------------------------------
// 图片的url地址数组
@property (nonatomic,strong) NSArray *imageUrlArrays ;


#pragma mark - 方法-------------------------------------------------------------
/**
 *  点击放大图片
 */
- (void)clickEnlarge ;

@end
