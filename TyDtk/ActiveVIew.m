//
//  ActiveVIew.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ActiveVIew.h"

@implementation ActiveVIew

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib{
    self.frame = CGRectMake(0, 0, Scr_Width, Scr_Width/2+20);
    _buttonActive.layer.masksToBounds = YES;
    _buttonActive.layer.cornerRadius = 3;
    _labTitle.adjustsFontSizeToFitWidth = YES;
    _labRemark.adjustsFontSizeToFitWidth = YES;
//    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.cornerRadius = 5;
    _labSubjectNumber.textColor = [UIColor purpleColor];
    _labPersonNumber.textColor = [UIColor purpleColor];
    _labPrice.textColor = [UIColor redColor];
    _imageWidth.constant = Scr_Width/2 - 10;
    _imageHeight.constant = _imageWidth.constant - 50;
    NSLog(@"%f",Scr_Width);
    //iPhone5以上的设备
    if (Scr_Width > 323) {
        _buttonWidth.constant = Scr_Width/4 - 10;
        _buttonHeight.constant = 30;
        _buttonActive.titleLabel.font = [UIFont systemFontOfSize:13.0];
        _buttonActive.layer.cornerRadius = 5;
        _labGetActiveAcc.font = [UIFont systemFontOfSize:11.0];
    }
    
    [self addgestForlabActive];
    _labGetActiveAcc.userInteractionEnabled = YES;
}
- (void)addgestForlabActive{
    UITapGestureRecognizer *tapLabGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labClick)];
    [_labGetActiveAcc addGestureRecognizer:tapLabGest];
}
- (void)labClick{
    [self.delegateAtive getActiveMaClick];
}
- (IBAction)activeBtnClick:(UIButton *)sender {
    [self.delegateAtive activeForPapersClick];
}

@end
