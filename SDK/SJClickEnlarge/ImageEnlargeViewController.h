//
//  ImageEnlargeViewController.h
//  Init
//
//  Created by 赵世杰 on 16/4/11.
//  Copyright © 2016年 zhaoshijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageEnlargeViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
#pragma mark - 变量-------------------------------------------------------------
// 图片url地址的数组
@property (nonatomic,strong) NSArray *imageUrlArrays ;

// 第几张图片
@property (nonatomic,assign) NSInteger imageIndex ;


#pragma mark - 视图-------------------------------------------------------------
// 第几张图片的文本
@property (nonatomic,strong) UILabel *label ;
@end
