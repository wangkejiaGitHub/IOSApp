//
//  PhoneReViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PhoneReViewController.h"

@interface PhoneReViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *textYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonYzmImg;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetMessage;
@property (weak, nonatomic) IBOutlet UITextField *textPwd;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegiste;

@property (nonatomic ,assign) CGFloat rectH;
//开始编辑的TextField
@property (nonatomic,strong) UITextField *textBegin;
//点击屏幕的手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestView;
//是否允许立即注册
@property (nonatomic,assign) BOOL allowRegiste;
//朦层
@property (nonatomic,strong) MZView *mzView;
//获取验证码的button的颜色
@property (nonatomic,strong) UIColor *colorCurr;
@end

@implementation PhoneReViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
//页面加载
- (void)viewLoad{
    _colorCurr = _buttonGetMessage.backgroundColor;
    self.title = @"新用户注册";
    _allowRegiste = NO;
    _buttonGetMessage.layer.masksToBounds = YES;
    _buttonGetMessage.layer.cornerRadius = 5;
    _buttonRegiste.layer.masksToBounds = YES;
    _buttonRegiste.layer.cornerRadius = 5;
}
//View即将呈现(加载)
- (void)viewWillAppear:(BOOL)animated{
    _tapGestView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapTextRfr)];
    [self.view addGestureRecognizer:_tapGestView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [self getYzmImageView];
}
////
//- (void)viewDidAppear:(BOOL)animated{
//    [_textPhoneNumber becomeFirstResponder];
//}
//View即将消失或隐藏
-(void)viewWillDisappear:(BOOL)animated{
    [self viewTapTextRfr];
    [_tapGestView removeTarget:self action:@selector(viewTapTextRfr)];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

//立即注册
- (IBAction)registButtonClick:(UIButton *)sender {
    if (_allowRegiste && _textPwd.text.length>0) {
        [self viewTapTextRfr];
        [self startRegiste];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"请完善注册信息或获取正确短信验证码"];
    }
    
}
//点击更换图片验证码
- (IBAction)yzmButtonClick:(UIButton *)sender {
    [self getYzmImageView];
}
//获取短信验证码
- (IBAction)messageBtnClick:(UIButton *)sender {
    [self getYzmMessage];
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
    CGFloat cH = Scr_Height - keyBoardHeight;
    CGFloat textFoldH = _textBegin.frame.origin.y;
    //如果键盘能够覆盖文本框，让试图向上移动
    if (cH < (textFoldH + 40)) {
        _rectH =(textFoldH + 40) - cH;
        CGRect rect = self.view.frame;
        rect.origin.y = rect.origin.y-_rectH -15;
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
        rect.origin.y = rect.origin.y+_rectH +15;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = rect;
        }];
    }
    _rectH = 0;
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
                _buttonGetMessage.backgroundColor = _colorCurr;
                [_buttonGetMessage setTitle:@"获取短信验证码" forState:UIControlStateNormal];
                _buttonGetMessage.userInteractionEnabled = YES;
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
                [_buttonGetMessage setTitle:[NSString stringWithFormat:@"%@秒后重新获取",strTime] forState:UIControlStateNormal];
                _buttonGetMessage.backgroundColor = [UIColor lightGrayColor];
                _buttonGetMessage.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}
/**
 立即注册，请求服务器
 */
- (void)startRegiste{
    [SVProgressHUD showWithStatus:@"请稍后..."];
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    NSString *urlString = [NSString stringWithFormat:@"%@register/mobile/json",systemHttpsTyUser];
    NSDictionary *dicUserInfo = @{@"fromSystem":@"902",@"mobile":_textPhoneNumber.text,@"password":_textPwd.text,@"regsms":_textMessage.text};
    [HttpTools postHttpRequestURL:urlString RequestPram:dicUserInfo RequestSuccess:^(id respoes) {
        NSDictionary *dicRegiste = (NSDictionary *)respoes;
        NSInteger codeId = [dicRegiste[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"注册成功!"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicRegiste[@"errmsg"]];
        }
        [_mzView removeFromSuperview];
    } RequestFaile:^(NSError *erro) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
/**
 获取短信验证码
 */
- (void)getYzmMessage{
    //判断手机号是否为空
    if (_textPhoneNumber.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"手机号码不能为空"];
        return;
    }
    [SVProgressHUD showWithStatus:@"请稍后..."];
    NSString *urlString = [NSString stringWithFormat:@"%@getregsms?mobile=%@&captcha=%@",systemHttpsTyUser,_textPhoneNumber.text,_textYzm.text];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSString *reString = [[NSString alloc]initWithData:repoes encoding:NSUTF8StringEncoding];
        reString = [reString substringWithRange:NSMakeRange(1, reString.length -2)];
        if (reString.length > 13) {
            //发送成功
            [self startSenderYzmMessage];
            [SVProgressHUD showSuccessWithStatus:reString];
            _allowRegiste = YES;
        }
        else{
            //发送错误
            [SVProgressHUD showInfoWithStatus:reString];
        }
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
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
        [_buttonYzmImg setImage:image forState:UIControlStateNormal];
        
    } RequestFaile:^(NSError *error) {
        
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
/////////
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
