//
//  UpdateUserInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/1.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UpdateUserInfoViewController.h"
@interface UpdateUserInfoViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIView *viewText;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@end

@implementation UpdateUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showTextPlaceholderString];
}
///加载
- (void)showTextPlaceholderString{
    _tyUser = [NSUserDefaults standardUserDefaults];
    _viewText .layer.masksToBounds = YES;
    _viewText.layer.cornerRadius = 3;
    _buttonSave.layer.masksToBounds = YES;
    _buttonSave.layer.cornerRadius = 3;
    if (_updateInfoPar == 1) {
        self.title = @"用户名";
        _textValue.placeholder = @"填写用户名";
    }
    else if (_updateInfoPar == 2){
        self.title = @"手机号";
        _textValue.placeholder = @"填写手机号码";
    }
    else if (_updateInfoPar == 3){
        self.title = @"邮箱";
        _textValue.placeholder = @"填写邮箱地址";
    }
    //添加手势
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tapView];
    //文本框获取焦点
     [_textValue becomeFirstResponder];
    _textValue.text = _stringCurr;
}
- (void)viewWillDisappear:(BOOL)animated{
    [_textValue resignFirstResponder];
}
//手势点击事件
- (void)tapClick:(UITapGestureRecognizer *)tap{
    [_textValue resignFirstResponder];
}
//保存按钮
- (IBAction)buttonSaveClick:(UIButton *)sender {
    if (self.updateInfoPar == 1) {
        if ([_textValue.text isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:@"用户名不能为空"];
            return;
        }
        //用户名
        [self updateUserName];
    }
    else if (self.updateInfoPar ==2){
        if ([_textValue.text isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:@"手机号码不能为空"];
            return;
        }
        //手机号
        [self updateUserPhone];
    }
    else if (self.updateInfoPar == 3){
        if ([_textValue.text isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:@"邮箱地址不能为空"];
            return;
        }
        //邮箱
        [self updateUserEmail];
    }
}

///修改手机号
- (void)updateUserPhone{
    if ([self checkTelNumber:_textValue.text]) {
        [self updateUserInfo:@"mobile" stringValue:_textValue.text];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"请输入正确的手机号"];
    }
}
///修改邮箱
- (void)updateUserEmail{
    [self updateUserInfo:@"email" stringValue:_textValue.text];
}
///修改用户名
- (void)updateUserName{
  
    [self updateUserInfo:@"name" stringValue:_textValue.text];
}
//手机号匹配
-(BOOL)checkTelNumber:(NSString *)telNumber{
    NSString *pattern = @"^1+[3-9]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}
- (void)updateUserInfo:(NSString *)stringKey stringValue:(NSString *)value{
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUserInfo];
    NSString *urlString = [NSString stringWithFormat:@"%@updateuser/json;JSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    NSDictionary *dic =@{stringKey:value};
    [HttpTools postHttpRequestURL:urlString RequestPram:dic RequestSuccess:^(id respoes) {
        NSDictionary *dicUpdate = respoes;
        NSInteger codeId = [dicUpdate[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicUpdate[@"errmsg"]];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
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
