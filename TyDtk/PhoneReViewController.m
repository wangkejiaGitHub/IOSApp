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
@property (nonatomic ,assign) NSInteger textTag;
@property (nonatomic,strong) UITextField *textBegin;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestView;
@end

@implementation PhoneReViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
//页面加载
- (void)viewLoad{
    _buttonGetMessage.layer.masksToBounds = YES;
    _buttonGetMessage.layer.cornerRadius = 5;
    _buttonRegiste.layer.masksToBounds = YES;
    _buttonRegiste.layer.cornerRadius = 5;
    [self getYzmImageView];
}
//View即将呈现
- (void)viewWillAppear:(BOOL)animated{
    _tapGestView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap)];
    [self.view addGestureRecognizer:_tapGestView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}
//View即将消失或隐藏
-(void)viewWillDisappear:(BOOL)animated{
    [_tapGestView removeTarget:self action:@selector(viewTap)];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
//屏幕点击事件（所有textfield失去焦点）
- (void)viewTap{
    for (id subView in self.view.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *text = (UITextField *)subView;
            [text resignFirstResponder];
        }
    }
}

//立即注册
- (IBAction)registButtonClick:(UIButton *)sender {
    
}
//点击更换验证码
- (IBAction)yzmButtonClick:(UIButton *)sender {
    [self getYzmImageView];
}
/////////
//键盘监听
//键盘出现
- (void)keyboardShow:(NSNotification *)note{
    [self keyboardHide:nil];
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat keyBoardHeight = keyboardRect.size.height;
    CGFloat cH = Scr_Height - keyBoardHeight;
    NSLog(@"%f",_textPwd.frame.origin.y);
    CGFloat textFoldH = _textBegin.frame.origin.y;
    //如果键盘能够覆盖文本框，让试图向上移动
    if (cH < (textFoldH + 35 +50+64)) {
        _rectH =(textFoldH + 35 +50+64) - cH;
        CGRect rect = self.view.frame;
        rect.origin.y = rect.origin.y-_rectH -15;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = rect;
        }];
    }
}
/////////
//键盘监听
//键盘消失
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
 获取验证码图片
 */
- (void)getYzmImageView{
    NSString *urlString = [NSString stringWithFormat:@"%@getCaptcha",systemHttpsTyUser];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSData *data = [[NSData alloc]initWithData:repoes];
        //        _imageYzm.image = [UIImage imageWithData:data];
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
