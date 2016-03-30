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
    [self viewTapTextRfr];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
