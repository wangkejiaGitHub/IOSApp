//
//  UptadePwdViewController.m
//  TyDtk
//  用户修改密码
//  Created by 天一文化 on 16/6/2.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UptadePwdViewController.h"

@interface UptadePwdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textPwd;
@property (weak, nonatomic) IBOutlet UITextField *textPwdAg;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;

@end

@implementation UptadePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"密码修改";
    _buttonSave.layer.masksToBounds = YES;
    _buttonSave.layer.cornerRadius = 5;
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tapView];
}
///屏幕点击事件
- (void)tapClick:(UITapGestureRecognizer *)tapView{
    [_textPwd resignFirstResponder];
    [_textPwdAg resignFirstResponder];
    
}
- (IBAction)buttonSaveClick:(UIButton *)sender {
    
    if ([_textPwd.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"密码你能为空"];
    }
    else if (![_textPwd.text isEqualToString:_textPwdAg.text]){
        [SVProgressHUD showInfoWithStatus:@"两次密码输入不一致"];
    }
    else{
        [self updateUserPwd];
    }
}
///修改用户密码
- (void)updateUserPwd{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
    NSString *urlString = [NSString stringWithFormat:@"%@updateuser/json;JSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    NSDictionary *dic =@{@"password":_textPwd.text};
    [HttpTools postHttpRequestURL:urlString RequestPram:dic RequestSuccess:^(id respoes) {
        NSDictionary *dicUpdate = respoes;
        NSInteger codeId = [dicUpdate[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败！"];
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
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
