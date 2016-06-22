//
//  GuideView.h
//  TyDtk
//  引导页封装（可加载本地图片、网络图片）
//  Created by 天一文化 on 16/6/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GuideViewDelegate <NSObject>
- (void)GuideViewDismiss;
@end
@interface GuideView : UIView
/**
 scrollView上面的页面索引
 */
@property (nonatomic,strong) UIPageControl *pageScroll;
/**
 加载本地图片名字，图片数量大于1
 */
- (id)initWithFrame:(CGRect)frame arrayImgName:(NSArray *)arrayImgName;
/**
 用图片地址加载图片(需要加入SDWebImage第三方库)，图片地址个数大于1
 */
- (id)initWithFrame:(CGRect)frame arrayImgUrl:(NSArray *)arrayImgUrl;
@property (nonatomic,assign) id <GuideViewDelegate> delegateGuideView;
@end
