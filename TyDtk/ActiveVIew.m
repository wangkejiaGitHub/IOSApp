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
    self.frame = CGRectMake(0, 0, Scr_Width, Scr_Width/2 - 10);
    _buttonActive.layer.masksToBounds = YES;
    _buttonActive.layer.cornerRadius = 3;
    _labTitle.adjustsFontSizeToFitWidth = YES;
    _labRemark.adjustsFontSizeToFitWidth = YES;
//    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.cornerRadius = 5;
//    _labSubjectNumber.textColor = [UIColor purpleColor];
//    _labPersonNumber.textColor = [UIColor purpleColor];
    _labPrice.textColor = [UIColor redColor];
    _imageWidth.constant = Scr_Width/2 - 10;
    _imageHeight.constant = _imageWidth.constant - 40;
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
//设置显示属性
- (void)setActiveValue:(NSDictionary *)dicSubject{
    NSString *imgsUrlSub = dicSubject[@"productImageListStore"];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgsUrlSub]];
    self.labTitle.text = dicSubject[@"Names"];
    NSString *remarkPriceSub =[NSString stringWithFormat:@"￥ %ld",[dicSubject[@"marketPrice"] integerValue]];
    //市场价格用属性字符串添加删除线
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:remarkPriceSub];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlineStyleSingle) range:NSMakeRange(2,remarkPriceSub.length -2)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(2,remarkPriceSub.length-2)];
    [self.labRemark setAttributedText:attri];
    NSString *priceSub = [NSString stringWithFormat:@"￥ %ld",[dicSubject[@"price"] integerValue]];
    self.labPrice.text = priceSub;
    
    [self isBuyThisSubject];
}
///判断是否已经购买过该科目
- (void)isBuyThisSubject{
    //127.0.0.1:8082/ty/mobile/order/productValidate?productId=662
//    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
//    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/productValidate?productId=%@&jsessionid=%@",systemHttpsKaoLaTopicImg,_subjectId,dicUser[@"jeeId"]];
//    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
//        NSDictionary *dicBuy = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
//        NSLog(@"%@",dicBuy);
//    } RequestFaile:^(NSError *error) {
//        
//    }];
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
