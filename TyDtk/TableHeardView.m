//
//  TableHeardView.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TableHeardView.h"
@interface TableHeardView()
@property (nonatomic,strong) NSUserDefaults *tyUser;
@end
@implementation TableHeardView
-(void)awakeFromNib{
    _tyUser = [NSUserDefaults standardUserDefaults];
    NSLog(@"awakeFromNib");
    _imageHeardImg.layer.masksToBounds = YES;
    _imageHeardImg.layer.cornerRadius = _imageHeardImg.bounds.size.height/2;
    _imageHeardImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *imgTapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgClick:)];
    [_imageHeardImg addGestureRecognizer:imgTapGest];
}
- (void)imgClick:(UITapGestureRecognizer *)tapGest{
    ///已登录
    if ([_tyUser objectForKey:tyUserUser]) {
        [self.delegateImg ImgButtonClick:1];
    }
    ///未登录
    else{
        [self.delegateImg ImgButtonClick:0];
    }
    NSLog(@"delegateImg");
}
@end
