//
//  ImageEnlargeCell.h
//  Init
//
//  Created by 赵世杰 on 16/4/11.
//  Copyright © 2016年 zhaoshijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImageEnlargeCellDelegate<NSObject>
- (void)enlargeCellSaveImage:(UIImage *)image;
@end
@interface ImageEnlargeCell : UICollectionViewCell<UIScrollViewDelegate>

#pragma mark - 变量-------------------------------------------------------------
// 图片的url地址
@property (nonatomic,strong) NSString *imageUrlString ;


#pragma mark - 视图-------------------------------------------------------------
// 视图
@property (nonatomic,strong) UIImageView *imageView ;
@property (nonatomic,strong) UIScrollView *scrollView ;
@property (nonatomic,assign) id <ImageEnlargeCellDelegate> delegateImageCell;
//@property (nonatomic,assign) NSInteger intImageIndex;
- (void)_initViews:(NSInteger)imageIndex;
@end
