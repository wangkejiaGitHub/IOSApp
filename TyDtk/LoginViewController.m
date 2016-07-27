//
//  LoginViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate,LoginDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBrg;
@property (weak, nonatomic) IBOutlet UIView *viewName;
@property (weak, nonatomic) IBOutlet UIView *viewPwd;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textPwd;
@property (nonatomic,strong) LoginUser *loginUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
//点击屏幕的手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestView;
@end
@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loginUser = [[LoginUser alloc]init];
    _loginUser.delegateLogin = self;
    [self viewLoad];
    
}
- (void)viewLoad{
    self.title = @"用户登录";
    _viewName.layer.masksToBounds = YES;
    _viewName.layer.cornerRadius = 3;
    _viewName.layer.borderWidth = 1;
    _viewName.layer.borderColor = [[UIColor whiteColor] CGColor];
    _viewPwd.layer.masksToBounds = YES;
    _viewPwd.layer.cornerRadius = 3;
    _viewPwd.layer.borderWidth = 1;
    _viewPwd.layer.borderColor = [[UIColor whiteColor] CGColor];
    _imageViewBrg.image = [UIImage imageNamed:@"loginBrg.jpeg"];
    _buttonLogin.layer.masksToBounds = YES;
    _buttonLogin.layer.cornerRadius = 5;
}
- (void)viewWillAppear:(BOOL)animated{
    _tapGestView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap)];
    [self.view addGestureRecognizer:_tapGestView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_tapGestView removeTarget:self action:@selector(viewTap)];
}
//屏幕点击事件（所有textfield失去焦点）
- (void)viewTap{
    [_textName resignFirstResponder];
    [_textPwd resignFirstResponder];
}
//登录
- (IBAction)btnLoginClick:(UIButton *)sender {
    [self viewTap];
    [SVProgressHUD showWithStatus:@"登录中..."];
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    [_loginUser LoginAppWithAccount:_textName.text password:_textPwd.text];
}

///登录成功回调
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara{
    [_mzView removeFromSuperview];
    if (msgPara == 1) {
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

///登录失败回调
- (void)loginUserErrorString:(NSString *)errorStr{
    ///弹出失败消息（不做任何处理，此页面默认起始登录）
    [_mzView removeFromSuperview];
    [SVProgressHUD showInfoWithStatus:errorStr];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
