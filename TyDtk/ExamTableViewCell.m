//
//  ExamTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ExamTableViewCell.h"
@interface ExamTableViewCell()
@property (nonatomic,strong) NSDictionary *dicExam;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@end
@implementation ExamTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _viewL.layer.masksToBounds = YES;
    _viewL.layer.cornerRadius = 3;
    _viewL.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _viewL.layer.borderWidth = 1;
    _viewL.backgroundColor = ColorWithRGB(240, 240, 240);
    _buttonDelete.layer.masksToBounds = YES;
    _buttonDelete.layer.cornerRadius = 3;
    _buttonEdit.layer.masksToBounds = YES;
    _buttonEdit.layer.cornerRadius = 3;
}
//设置cell上面的值并返回
- (CGFloat)setCellModelValueWithDictionary:(NSDictionary *)dicExam{
    if ([dicExam[@"IsDefault"] integerValue] == 1) {
        [_buttonSet setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_buttonSet setTitle:@"" forState:UIControlStateNormal];
        [_buttonSet setImage:nil forState:UIControlStateNormal];
        _imageLab.image = [UIImage imageNamed:@"label"];
        _buttonSet.userInteractionEnabled = NO;
//        [_buttonSet removeFromSuperview];
    }
    else{
       [_buttonSet setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_buttonSet setTitle:@"设置默认" forState:UIControlStateNormal];
        [_buttonSet setImage:[UIImage imageNamed:@"cog"] forState:UIControlStateNormal];
        _imageLab.image = nil;
        _buttonSet.userInteractionEnabled = YES;
    }
    _dicExam = dicExam;
    CGFloat cellHeight = 0;
    _labTitle.text = dicExam[@"CourseName"];
    NSString *time = dicExam[@"ExamTime"];
    time = [time substringToIndex:10];
    _labTime.text = time;
    //备注说明
    NSString *notes = dicExam[@"Note"];
    _labRemark.text =[NSString stringWithFormat:@"备注：%@",notes];
    CGSize labSize = [_labRemark sizeThatFits:CGSizeMake(_labRemark.frame.size.width, MAXFLOAT)];
    if (labSize.height > 20) {
        _labRemarkHeight.constant = labSize.height;
        cellHeight = 210 + (_labRemarkHeight.constant - 20);
    }
    else{
        _labRemarkHeight.constant = 20;
        cellHeight = 210;
    }
    return cellHeight;
}
///删除按钮
- (IBAction)buttonDeleteExam:(UIButton *)sender {
    LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"考试删除" message:@"确定要删除该考试信息吗？" cancelBtnTitle:@"删除" otherBtnTitle:@"保留" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 0) {
            [self deleteExam];
        }
    }];
    alert.animationStyle = LXASAnimationDefault;
    [alert showLXAlertView];
}
///设置默认考试按钮
- (IBAction)biuttonSetDefultClick:(UIButton *)sender {
    [self setExamDefault];
}
///编辑按钮
- (IBAction)buttonEditClick:(UIButton *)sender {
    [self editExam];
}
///删除考试
- (void)deleteExam{
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamSet/Del/%@?access_token=%@",systemHttps,_dicExam[@"Id"],_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicExam = (NSDictionary *)respoes;
        NSInteger codeId = [dicExam[@"code"] integerValue];
        if (codeId == 1) {
            [self.delegateExam reFreshExamInfo];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作异常"];
        }
        
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
///设置默认
- (void)setExamDefault{
    ////
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamSet/SetDefault/%@?access_token=%@",systemHttps,_dicExam[@"Id"],_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicExam = (NSDictionary *)respoes;
        NSInteger codeId = [dicExam[@"code"] integerValue];
        if (codeId == 1) {
            [self.delegateExam reFreshExamInfo];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
///编辑考试
- (void)editExam{
    [self.delegateExam editExamInfo:_dicExam];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
