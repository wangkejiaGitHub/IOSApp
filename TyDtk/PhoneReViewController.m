//
//  PhoneReViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PhoneReViewController.h"

@interface PhoneReViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textPhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *textYzm;
@property (weak, nonatomic) IBOutlet UIButton *buttonYzmImg;

@property (weak, nonatomic) IBOutlet UITextField *textMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetMessage;
@property (weak, nonatomic) IBOutlet UITextField *textPwd;

@end

@implementation PhoneReViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getYzmImageView];
}
//立即注册
- (IBAction)registButtonClick:(UIButton *)sender {
    
}
//点击更换验证码
- (IBAction)yzmButtonClick:(UIButton *)sender {
    [self getYzmImageView];
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
