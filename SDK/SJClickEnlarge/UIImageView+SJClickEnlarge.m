//
//  UIImageView+SJClickEnlarge.m
//  Init
//
//  Created by 赵世杰 on 16/4/11.
//  Copyright © 2016年 zhaoshijie. All rights reserved.
//

#import "UIImageView+SJClickEnlarge.h"
#import "UIView+ViewController.h"
#import "ImageEnlargeViewController.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"

@implementation UIImageView (SJClickEnlarge)

static char ImageUrlArrays ;


#pragma mark - 添加set，get方法
- (void)setImageUrlArrays:(NSArray *)imageUrlArrays
{
    [self willChangeValueForKey:@"ImageUrlArrays"] ;
    objc_setAssociatedObject(self, &ImageUrlArrays, imageUrlArrays, OBJC_ASSOCIATION_COPY_NONATOMIC) ;
    [self didChangeValueForKey:@"ImageUrlArrays"] ;
}

- (NSArray *)imageUrlArrays
{
    return objc_getAssociatedObject(self, &ImageUrlArrays) ;
}




/**
 *  点击放大图片
 */
- (void)clickEnlarge
{
    self.userInteractionEnabled = YES ;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImageAction)] ;
    [self addGestureRecognizer:tap] ;
    
    if(self.imageUrlArrays[0] != nil)
    {
        NSURL *url = [NSURL URLWithString:self.imageUrlArrays[0]] ;
        [self sd_setImageWithURL:url] ;
    }
}


/**
 *  点击图片时的响应事件
 */
- (void)clickImageAction
{
    // 模态跳转
    UIViewController *superViewController = [self viewController] ;
    ImageEnlargeViewController *imageEnlargeVC = [[ImageEnlargeViewController alloc]init] ;
    imageEnlargeVC.imageUrlArrays = self.imageUrlArrays ;
    [superViewController presentViewController:imageEnlargeVC animated:YES completion:nil] ;
}

@end
