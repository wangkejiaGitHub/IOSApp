//
//  EmailReViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "EmailReViewController.h"
#import "LoginViewController.h"
@interface EmailReViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonYzm;
@property (weak, nonatomic) IBOutlet UITextField *textPwd;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegist;
//朦层
@property (nonatomic,strong) MZView *mzView;
//点击屏幕的手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestView;
@end

@implementation EmailReViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}


//页面加载
- (void)viewLoad{
    self.title = @"邮箱注册";
    _buttonRegist.layer.masksToBounds = YES;
    _buttonRegist.layer.cornerRadius = 5;
    
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
//更换验证码
- (IBAction)YzmButtonClick:(UIButton *)sender {
    [self getYzmImageView];
}
//立即注册
- (IBAction)registeButtonClick:(UIButton *)sender {
    if (_textEmail.text.length > 0 && _textPwd.text.length >0) {
        if ([PasswordValidate PassWordStringValidate:_textPwd.text]) {
            [self viewTapTextRfr];
            [self startRegiste];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"新密码格式有误"];
        }
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"请完善注册信息"];
    }
}
/**
 立即注册，请求服务器
 */
- (void)startRegiste{
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    [SVProgressHUD showWithStatus:@"请稍后..."];
    NSString *urlString = [NSString stringWithFormat:@"%@register/email/json",systemHttpsTyUser];
    NSDictionary *dicUserInfo = @{@"fromSystem":@"902",@"email":_textEmail.text,@"password":_textPwd.text,@"captcha":_textYzm.text};
    [HttpTools postHttpRequestURL:urlString RequestPram:dicUserInfo RequestSuccess:^(id respoes) {
        NSDictionary *dicRe = (NSDictionary *)respoes;
        NSInteger codeId = [dicRe[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"操作成功,请前往邮箱激活"];
            //当前的Viewcontrol在本栈列的位置
            NSInteger index = (NSInteger)[[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
            
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicRe[@"errmsg"]];
            
        }
        [_mzView removeFromSuperview];
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
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
//textField 代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
