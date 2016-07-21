//
//  PhoneForPwdViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/29.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PhoneForPwdViewController.h"

@interface PhoneForPwdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textPhoneTopLayout;
@property (weak, nonatomic) IBOutlet UITextField *textPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *textYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonYzm;
@property (weak, nonatomic) IBOutlet UITextField *textPhoneYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetYzm;
@property (weak, nonatomic) IBOutlet UITextField *textpwd;
@property (weak, nonatomic) IBOutlet UITextField *textPwdAgain;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;
//开始编辑的TextField
@property (nonatomic,strong) UITextField *textBegin;
//朦层
@property (nonatomic,strong) MZView *mzView;
//点击屏幕的手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestView;
//获取验证码的button的颜色
@property (nonatomic,strong) UIColor *colorCurr;
@property (nonatomic ,assign) CGFloat rectH;
@end

@implementation PhoneForPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
- (void)viewLoad{
    _buttonGetYzm.layer.masksToBounds = YES;
    _buttonGetYzm.layer.cornerRadius = 5;
    _buttonSubmit.layer.masksToBounds = YES;
    _buttonSubmit.layer.cornerRadius = 5;
}
- (void)viewWillAppear:(BOOL)animated{
    [self getYzmImageView];
    //适应4s手机，让整个试图能够全部显示
    if (Scr_Height < 560) {
        _textPhoneTopLayout.constant = 20;
    }
    _tapGestView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapTextRfr)];
    [self.view addGestureRecognizer:_tapGestView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];

}
- (void)viewWillDisappear:(BOOL)animated{
     [_tapGestView removeTarget:self action:@selector(viewTapTextRfr)];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
//获取验证码
- (IBAction)getYzmBtnClick:(UIButton *)sender {
    [self viewTapTextRfr];
    [self getYzmMessage];
}
//提交
- (IBAction)buttonSubClick:(UIButton *)sender {
    if ([_textpwd.text isEqualToString:@""] | [_textPwdAgain.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"请完善信息"];
        return;
    }
    if (![_textpwd.text isEqualToString:_textPwdAgain.text]) {
        [SVProgressHUD showInfoWithStatus:@"两次密码输入不一致"];
        return;
    }
    else{
        if ([PasswordValidate PassWordStringValidate:_textPwdAgain.text]) {
            [self startFindPwdWithPhone];
            [self viewTapTextRfr];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"新密码格式有误"];
        }
    }
}
- (IBAction)buttonYzmImgsClick:(UIButton *)sender {
    [self getYzmImageView];
}
//开始找回密码
- (void)startFindPwdWithPhone{
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    [SVProgressHUD showWithStatus:@"请稍后..."];
    NSDictionary *dicInfo = @{@"fromSystem":@"902",@"mobile":_textPhoneNumber.text,@"password":_textPwdAgain.text,@"findpwdsms":_textPhoneYzm.text};
    NSString *urlString = [NSString stringWithFormat:@"%@findpwd/mobile/json",systemHttpsTyUser];
    [HttpTools postHttpRequestURL:urlString RequestPram:dicInfo RequestSuccess:^(id respoes) {
        NSDictionary *dicRe = (NSDictionary *)respoes;
        NSInteger codeId = [dicRe[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"密码更新成功"];
            ///更新本地存储的用户账号和密码
            NSUserDefaults *tyUserAcc = [NSUserDefaults standardUserDefaults];
            NSDictionary *dicAccount = [tyUserAcc objectForKey:tyUserAccount];
            NSMutableDictionary *dicAcc = [NSMutableDictionary dictionaryWithDictionary:dicAccount];
            [dicAcc setObject:_textPwdAgain.text forKey:@"pwd"];
            [tyUserAcc setObject:dicAcc forKey:tyUserAccount];
            [self.navigationController popViewControllerAnimated:YES];
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
///////////
//键盘监听//
//键盘出现//
- (void)keyboardShow:(NSNotification *)note{
    [self keyboardHide:nil];
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat keyBoardHeight = keyboardRect.size.height;
    NSLog(@"%f",Scr_Height);
    CGFloat cH = Scr_Height - keyBoardHeight;
    CGFloat textFoldH = _textBegin.frame.origin.y;
    //如果键盘能够覆盖文本框，让试图向上移动
    if (cH < (textFoldH + 40+50+60)) {
        _rectH =(textFoldH + 40+50+60) - cH;
        CGRect rect = self.view.frame;
        rect.origin.y = rect.origin.y-_rectH -40;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = rect;
        }];
    }
}
///////////
//键盘监听//
//键盘消失//
- (void)keyboardHide:(NSNotification *)note{
    if (_rectH > 0) {
        CGRect rect = self.view.frame;
        rect.origin.y = rect.origin.y+_rectH +40;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = rect;
        }];
    }
    _rectH = 0;
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

/**
 60秒后重新发送手机验证码
 */
-(void)startSenderYzmMessage{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                _buttonGetYzm.backgroundColor = _colorCurr;
                [_buttonGetYzm setTitle:@"获取短信验证码" forState:UIControlStateNormal];
                _buttonGetYzm.userInteractionEnabled = YES;
            });
        }else{
            // int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            if ([strTime isEqualToString:@"00"]) {
                strTime = @"60";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_buttonGetYzm setTitle:[NSString stringWithFormat:@"%@秒后重新获取",strTime] forState:UIControlStateNormal];
                _buttonGetYzm.backgroundColor = [UIColor lightGrayColor];
//                _buttonGetYzm.backgroundColor = [UIColor groupTableViewBackgroundColor];
                _buttonGetYzm.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
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

/**
 获取短信验证码
 */
- (void)getYzmMessage{
    if (_textPhoneNumber.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"手机号码不能为空"];
        return;
    }
    [SVProgressHUD showWithStatus:@"请稍后..."];
    NSString *urlString = [NSString stringWithFormat:@"%@getfindpwdsms/json?mobile=%@&captcha=%@",systemHttpsTyUser,_textPhoneNumber.text,_textYzm.text];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        //判断手机号是否为空
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            //发送成功
            [self startSenderYzmMessage];
            [SVProgressHUD showSuccessWithStatus:@"验证码发送成功"];

        }
        else{
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
        }

    } RequestFaile:^(NSError *error) {
        NSLog(@"fasfafsf");
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
//textField代理
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textBegin = textField;
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
