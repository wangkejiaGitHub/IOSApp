//
//  GuideView.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "GuideView.h"
@interface GuideView()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollViewImg;
@property (nonatomic,strong) UIView *viewDismiss;
@property (nonatomic,strong) UIView *viewLine;
@property (nonatomic,strong) UILabel *labText;
//图片数量
@property (nonatomic,assign) NSInteger ImageCount;
@end
@implementation GuideView
///加载本地图片初始化
- (id)initWithFrame:(CGRect)frame arrayImgName:(NSArray *)arrayImgName{
    self = [super initWithFrame:frame];
    if (self) {
        _ImageCount = arrayImgName.count;
        [self addScrollViewForSelf];
        [self addImageViewWithArrayName:arrayImgName];
        
        [self addPageContorl];
    }
    return self;
}
///加载网络图片初始化
- (id)initWithFrame:(CGRect)frame arrayImgUrl:(NSArray *)arrayImgUrl{
    self = [super initWithFrame:frame];
    if (self) {
        _ImageCount = arrayImgUrl.count;
        [self addScrollViewForSelf];
        [self addImageViewWithArrayUrl:arrayImgUrl];
        
        [self addPageContorl];
    }
    return self;
}

/**
 为试图加载scrollView
 */
- (void)addScrollViewForSelf{
    _viewDismiss = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 60 - 15, 0, 60, self.bounds.size.height)];
    _viewDismiss.backgroundColor = [UIColor clearColor];
    _viewLine = [[UIView alloc]initWithFrame:CGRectMake(30+(30-1)/2, 30, 1, self.bounds.size.height-60)];
    _viewLine.backgroundColor = [UIColor whiteColor];
    [_viewDismiss addSubview:_viewLine];
    
    _labText = [[UILabel alloc]initWithFrame:CGRectMake(30, (self.bounds.size.height-230)/2, 30, 230)];
    _labText.backgroundColor = [UIColor whiteColor];
    _labText.font = [UIFont systemFontOfSize:18.0];
    _labText.textAlignment = NSTextAlignmentCenter;
    _labText.textColor = [UIColor whiteColor];
    _labText.numberOfLines = 0;
    _labText.text = @"向左滑动进入点题库";
    [_viewDismiss addSubview:_labText];
    [self addSubview:_viewDismiss];
    //添加scrollView
    _scrollViewImg = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollViewImg.delegate = self;
    _scrollViewImg.pagingEnabled = YES;
    _scrollViewImg.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollViewImg];
}
/**
 加载本地图片
 */
- (void)addImageViewWithArrayName:(NSArray *)arrayImgName{
    _scrollViewImg.contentSize = CGSizeMake(self.bounds.size.width*arrayImgName.count, self.bounds.size.height);
    UIImageView *imageView;
    for (int i =0; i<arrayImgName.count; i++) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.frame.size.width,0, self.frame.size.width, self.frame.size.height)];
        imageView.image = [UIImage imageNamed:arrayImgName[i]];
        ///如果是最后一张图片，加一个进入题库的按钮
        if (i == arrayImgName.count - 1) {
            UIButton *btnCome = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCome.frame = CGRectMake((self.bounds.size.width-30*3.77)/2, self.bounds.size.height - 100, 30*3.77, 30);
//            btnCome.layer.masksToBounds = YES;
//            btnCome.layer.cornerRadius = 3;
//            btnCome.backgroundColor = [UIColor orangeColor];
//            [btnCome setTitle:@"进入题库" forState:UIControlStateNormal];
//            [btnCome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            btnCome.titleLabel.font = [UIFont systemFontOfSize:18.0];
            [btnCome setImage:[UIImage imageNamed:@"try"] forState:UIControlStateNormal];
            [btnCome addTarget:self action:@selector(btnComeClick:) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:btnCome];
        }
        [_scrollViewImg addSubview:imageView];
    }
    
    _viewLine.backgroundColor = [UIColor lightGrayColor];
    _labText.textColor = [UIColor lightGrayColor];
}
/**
 加载网络图片图片
 */
- (void)addImageViewWithArrayUrl:(NSArray *)arrayImgUrl{
    _scrollViewImg.contentSize = CGSizeMake(self.bounds.size.width*arrayImgUrl.count, self.bounds.size.height);
    UIImageView *imageView;
    for (int i =0; i<arrayImgUrl.count; i++) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.frame.size.width,0, self.frame.size.width, self.frame.size.height)];
        NSString *imgUrlString = arrayImgUrl[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imgUrlString]];
        ///如果是最后一张图片，加一个进入题库的按钮
        if (i == arrayImgUrl.count - 1) {
            UIButton *btnCome = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCome.frame = CGRectMake((self.bounds.size.width-30*3.77)/2, self.bounds.size.height - 100, 30*3.77, 30);
//            btnCome.layer.masksToBounds = YES;
//            btnCome.layer.cornerRadius = 3;
//            btnCome.backgroundColor = [UIColor orangeColor];
//            [btnCome setTitle:@"进入题库" forState:UIControlStateNormal];
//            [btnCome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            btnCome.titleLabel.font = [UIFont systemFontOfSize:18.0];
            [btnCome setImage:[UIImage imageNamed:@"try"] forState:UIControlStateNormal];
            [btnCome addTarget:self action:@selector(btnComeClick:) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:btnCome];
        }

        [_scrollViewImg addSubview:imageView];
    }
    _viewLine.backgroundColor = [UIColor lightGrayColor];
    _labText.textColor = [UIColor lightGrayColor];
}
/**
 添加page控件
 */
- (void)addPageContorl{
    _pageScroll = [[UIPageControl alloc]initWithFrame:CGRectMake((self.bounds.size.width - 150)/2, self.bounds.size.height - 40, 150, 15)];
    _pageScroll.numberOfPages = _ImageCount;
    _pageScroll.currentPageIndicatorTintColor = [UIColor blueColor];
    _pageScroll.pageIndicatorTintColor = [UIColor whiteColor];
    [_pageScroll addTarget:self action:@selector(pageValueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageScroll];
}
//点击page控件（联动scrollView）
- (void)pageValueChange:(UIPageControl *)page{
    [_scrollViewImg setContentOffset:CGPointMake(page.currentPage*self.bounds.size.width, 0) animated:YES];
}
///点击进入题库
- (void)btnComeClick:(UIButton *)button{
    [self.delegateGuideView GuideViewDismiss];
}
////////////代理/////////////
//只要滚定了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOff = scrollView.contentOffset.x + self.bounds.size.width;
    if (scrollOff >= self.bounds.size.width*_ImageCount + 60) {
        _labText.text = @"松手可进入点题库";
    }
    else{
        _labText.text = @"向左滑动进入点题库";
    }
}
//完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat scrollOff = scrollView.contentOffset.x + self.bounds.size.width;
    if (scrollOff >= self.bounds.size.width*_ImageCount + 60) {
        NSLog(@"_arrayImgName");
        [self.delegateGuideView GuideViewDismiss];
    }
}
//降速结束(联动page控件)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger indexCurr = scrollView.contentOffset.x/self.bounds.size.width;
    _pageScroll.currentPage = indexCurr;
}
@end
