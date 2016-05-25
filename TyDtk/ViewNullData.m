//
//  ViewNullData.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/25.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ViewNullData.h"

@implementation ViewNullData

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame showText:(NSString *)showText{
    self = [super initWithFrame:frame];
    if (self) {
        [self addLabelAndTapGest:frame showTest:showText];
    }
    return self;
}
//初始化方法时调用
- (void)addLabelAndTapGest:(CGRect)frame showTest:(NSString *)showText{
    CGFloat scrW = frame.size.width;
    CGFloat scrH = frame.size.height;
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrW, scrH)];
    imgView.image = systemBackGrdImg;
    [self addSubview:imgView];
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(40, (scrH - 50)/2, scrW - 80, 50)];
    if (showText == nil) {
        labText.text = @"点击屏幕刷新";
    }
    else{
        labText.text = showText;
    }
    labText.textColor = [UIColor grayColor];
    labText.textAlignment = NSTextAlignmentCenter;
    labText.font = [UIFont systemFontOfSize:16.0];
    labText.numberOfLines = 0;
    [self addSubview:labText];
    
    UITapGestureRecognizer *viewTapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestClick:)];
    [self addGestureRecognizer:viewTapGest];
}
- (void)tapGestClick:(UITapGestureRecognizer *)tapGest{
    [self.delegateNullData nullDataTapGestClick];
}
@end
