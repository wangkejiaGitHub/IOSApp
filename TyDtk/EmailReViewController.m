//
//  EmailReViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "EmailReViewController.h"

@interface EmailReViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonYzm;
@property (weak, nonatomic) IBOutlet UITextField *textPwd;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegist;

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
    [self getYzmImageView];
}
- (void)viewWillAppear:(BOOL)animated{
    _tapGestView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapTextRfr)];
    [self.view addGestureRecognizer:_tapGestView];
}
- (void)viewDidAppear:(BOOL)animated{
    [_textEmail becomeFirstResponder];
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
        [self viewTapTextRfr];
        [self startRegiste];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"请完善注册信息"];
    }
}
/**
 立即注册，请求服务器
 */
- (void)startRegiste{
    NSString *urlString = [NSString stringWithFormat:@"%@register/email/json",systemHttpsTyUser];
    NSDictionary *dicUserInfo = @{@"formSystem":@"1",@"email":_textEmail.text,@"password":_textPwd.text,@"captcha":_textYzm.text};
    NSLog(@"%@",dicUserInfo);
    [HttpTools postHttpRequestURL:urlString RequestPram:dicUserInfo RequestSuccess:^(id respoes) {
        //        NSDictionary *dicRegiste = [NSJSONSerialization JSONObjectWithData:respoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",respoes);
    } RequestFaile:^(NSError *erro) {
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
