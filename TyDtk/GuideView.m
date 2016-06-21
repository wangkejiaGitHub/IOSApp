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
@property (nonatomic,strong) UILabel *labText;
//判断是否是本地图片
@property (nonatomic,assign) BOOL isImgName;
@property (nonatomic,strong) NSArray *arrayImgName;
@property (nonatomic,strong) NSArray *arrayImgUrl;
@end
@implementation GuideView
///加载本地图片
- (id)initWithFrame:(CGRect)frame arrayImgName:(NSArray *)arrayImgName{
    self = [super initWithFrame:frame];
    if (self) {
        _isImgName = YES;
        _arrayImgName = arrayImgName;
        [self addScrollViewForSelf];
        [self addImageViewWithArrayName:arrayImgName];
    }
    return self;
}

///加载网络图片
- (id)initWithFrame:(CGRect)frame arrayImgUrl:(NSArray *)arrayImgUrl{
    self = [super initWithFrame:frame];
    if (self) {
        _isImgName = NO;
        _arrayImgUrl = arrayImgUrl;
        [self addScrollViewForSelf];
        [self addImageViewWithArrayUrl:arrayImgUrl];

    }
    return self;
}
- (void)addScrollViewForSelf{
    _viewDismiss = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 60 - 15, 0, 60, self.bounds.size.height)];
    _viewDismiss.backgroundColor = [UIColor clearColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(30+(30-1)/2, 30, 1, self.bounds.size.height-60)];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [_viewDismiss addSubview:viewLine];
    
    _labText = [[UILabel alloc]initWithFrame:CGRectMake(30, (self.bounds.size.height-230)/2, 30, 230)];
    _labText.backgroundColor = [UIColor whiteColor];
    _labText.font = [UIFont systemFontOfSize:18.0];
    _labText.textAlignment = NSTextAlignmentCenter;
    _labText.textColor = [UIColor lightGrayColor];
    _labText.numberOfLines = 0;
    _labText.text = @"向左滑动进入点题库";
    [_viewDismiss addSubview:_labText];
    [self addSubview:_viewDismiss];
    
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
        ///接一个进入题库的按钮
        if (i == arrayImgName.count - 1) {
            UIButton *btnCome = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCome.frame = CGRectMake((self.bounds.size.width-133)/2, self.bounds.size.height - 100, 133, 30);
            btnCome.layer.masksToBounds = YES;
            btnCome.layer.cornerRadius = 3;
            btnCome.backgroundColor = [UIColor orangeColor];
            [btnCome setTitle:@"进入题库" forState:UIControlStateNormal];
            [btnCome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnCome.titleLabel.font = [UIFont systemFontOfSize:18.0];
            [btnCome addTarget:self action:@selector(btnComeClick:) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:btnCome];
        }
        [_scrollViewImg addSubview:imageView];
    }
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
        [_scrollViewImg addSubview:imageView];
    }
}
- (void)btnComeClick:(UIButton *)button{
    [self.delegateGuideView GuideViewDismiss];
}
////////////代理/////////////
//只要滚定了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOff = scrollView.contentOffset.x + self.bounds.size.width;
    if (_isImgName) {
        if (scrollOff >= self.bounds.size.width*_arrayImgName.count + 50) {
            _labText.text = @"松手可进入点题库";
        }
        else{
            _labText.text = @"向左滑动进入点题库";
        }
    }
    else{
        if (scrollOff >= self.bounds.size.width*_arrayImgUrl.count + 50) {
            _labText.text = @"松手可进入点题库";
        }
        else{
            _labText.text = @"向左滑动进入点题库";
        }
    }
}
//完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat scrollOff = scrollView.contentOffset.x + self.bounds.size.width;
    if (_isImgName) {
        if (scrollOff >= self.bounds.size.width*_arrayImgName.count + 50) {
            NSLog(@"_arrayImgName");
            [self.delegateGuideView GuideViewDismiss];
        }
    }
    else{
        if (scrollOff >= self.bounds.size.width*_arrayImgUrl.count + 50) {
             [self.delegateGuideView GuideViewDismiss];
        }
    }
}
@end
