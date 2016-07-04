//
//  UptadePwdViewController.m
//  TyDtk
//  用户修改密码
//  Created by 天一文化 on 16/6/2.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UptadePwdViewController.h"

@interface UptadePwdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textOldPwd;
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
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
//    view.backgroundColor = [UIColor clearColor];
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = view.frame;
//    [btn setImage:[UIImage imageNamed:@"eyes"] forState:UIControlStateNormal];
//    [view addSubview:btn];
//    [_textOldPwd setRightViewMode:UITextFieldViewModeAlways];
//    [_textOldPwd setRightView:view];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tapView];
}
///屏幕点击事件
- (void)tapClick:(UITapGestureRecognizer *)tapView{
    [_textPwd resignFirstResponder];
    [_textPwdAg resignFirstResponder];
    [_textOldPwd resignFirstResponder];
    
}
- (IBAction)buttonSaveClick:(UIButton *)sender {
    
    if ([_textOldPwd.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"旧密码不能为空"];
        return;
    }
    else if ([_textPwd.text isEqualToString:@""]){
        [SVProgressHUD showInfoWithStatus:@"密码不能为空"];
        return;
    }
    else if (![_textPwd.text isEqualToString:_textPwdAg.text]){
        [SVProgressHUD showInfoWithStatus:@"两次密码输入不一致"];
        return;
    }
    else{
        [self updateUserPwd];
    }
}
///修改用户密码
- (void)updateUserPwd{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
    NSString *urlString = [NSString stringWithFormat:@"%@app/updatepwd;JSESSIONID=%@?fromSystem=902",systemHttpsTyUser,dicUser[@"jeeId"]];
    NSDictionary *dic =@{@"oldpwd":_textOldPwd.text,@"password":_textPwdAg.text};
    [HttpTools postHttpRequestURL:urlString RequestPram:dic RequestSuccess:^(id respoes) {
        NSDictionary *dicUpdate = respoes;
        NSInteger codeId = [dicUpdate[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicUpdate[@"errmsg"]];
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
