//
//  ActiveSubjectView.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/1.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ActiveSubjectView.h"

@implementation ActiveSubjectView

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
    _buttonActive.backgroundColor = ColorWithRGB(255, 121, 28);
    [_buttonActive setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _buttonPay.layer.masksToBounds = YES;
    _buttonPay.layer.cornerRadius = 3;
    _buttonPay.backgroundColor = ColorWithRGB(255, 121, 28);
    [_buttonPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _labTitle.adjustsFontSizeToFitWidth = YES;
    _labRemark.adjustsFontSizeToFitWidth = YES;
    _labPrice.textColor = [UIColor redColor];
    _imageWidth.constant = Scr_Width/2 - 10;
    _imageHeight.constant = _imageWidth.constant - 30;
    
}

//设置显示属性
- (void)setActiveValue:(NSDictionary *)dicSubject{
    NSString *imgsUrlSub = dicSubject[@"productImageListStore"];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgsUrlSub]];
    self.labTitle.text = dicSubject[@"Names"];
    NSString *remarkPriceSub =[NSString stringWithFormat:@"￥ %.2f",[dicSubject[@"marketPrice"] floatValue]];
    //市场价格用属性字符串添加删除线
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:remarkPriceSub];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlineStyleSingle) range:NSMakeRange(2,remarkPriceSub.length -2)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(2,remarkPriceSub.length-2)];
    [self.labRemark setAttributedText:attri];
    NSString *priceSub = [NSString stringWithFormat:@"￥ %.2f",[dicSubject[@"price"] floatValue]];
    self.labPrice.text = priceSub;
    
}
///激活按钮
- (IBAction)activeBtnClick:(UIButton *)sender {
    [self.delegateAtive paySubjectProductWithPayParameter:0];
}
///购买按钮
- (IBAction)buttonPayClick:(UIButton *)sender {
    [self.delegateAtive paySubjectProductWithPayParameter:1];
}

@end
