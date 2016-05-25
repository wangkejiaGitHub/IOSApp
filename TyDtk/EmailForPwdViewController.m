//
//  EmailForPwdViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/29.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "EmailForPwdViewController.h"

@interface EmailForPwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonYzm;
//点击屏幕的手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestView;
//朦层
@property (nonatomic,strong) MZView *mzView;
@end

@implementation EmailForPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [self getYzmImageView];
    _tapGestView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapTextRfr)];
    [self.view addGestureRecognizer:_tapGestView];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [self viewTapTextRfr];
    [_tapGestView removeTarget:self action:@selector(viewTapTextRfr)];
}
/**
 屏幕点击事件（所有textfield失去焦点)
 */
- (void)viewTapTextRfr{
    for (id subView in self.view.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *text = (UITextField *)subView;
            [text resignFirstResponder];
        }
    }
}

- (IBAction)buttonYzmClick:(UIButton *)sender {
    [self getYzmImageView];
}
- (IBAction)buttonNextClick:(UIButton *)sender {
    if ([_textEmail.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"请填写邮箱信息"];
        return;
    }
    [self startFindPwdWithEmail];
    [self viewTapTextRfr];
    
}
//开始邮箱找回密码
- (void)startFindPwdWithEmail{
    [SVProgressHUD showWithStatus:@"请稍后..."];
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    NSDictionary *dicInfo = @{@"fromSystem":@"902",@"email":_textEmail.text,@"captcha":_textYzm.text};
    NSString *urlString = [NSString stringWithFormat:@"%@findpwd/email/json",systemHttpsTyUser];
    [HttpTools postHttpRequestURL:urlString RequestPram:dicInfo RequestSuccess:^(id respoes) {
        NSDictionary *dicRe = (NSDictionary *)respoes;
        NSInteger codeId = [dicRe[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"操作成功,请前往邮箱更改密码"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicRe[@"errmsg"]];
            
        }
        [_mzView removeFromSuperview];
    } RequestFaile:^(NSError *erro) {
        [_mzView removeFromSuperview];
    }];
}
/**
 获取验证码图片
 */
- (void)getYzmImageView{
    NSString *urlString = [NSString stringWithFormat:@"%@getCaptcha",systemHttpsTyUser];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSData *data = [[NSData alloc]initWithData:repoes];
        UIImage *image = [UIImage imageWithData:data];
        [_buttonYzm setImage:image forState:UIControlStateNormal];
        
    } RequestFaile:^(NSError *error) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
