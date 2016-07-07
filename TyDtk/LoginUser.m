//
//  LoginUser.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "LoginUser.h"
@implementation LoginUser
-(void)LoginAppWithAccount:(NSString *)account password:(NSString *)pwd{
    NSDictionary *dicLogin = @{@"account":account,@"password":pwd};
    [HttpTools postHttpRequestURL:@"http://www.tydlk.cn/tyuser/login/json" RequestPram:dicLogin RequestSuccess:^(id respoes) {
        NSDictionary *dic = respoes;
        NSInteger codeUser = [dic[@"code"] integerValue];
        NSDictionary *dicUser = dic[@"datas"];
        NSLog(@"%@",dicUser);
        if (codeUser == 1) {
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
            [tyUser setObject:dicUser forKey:tyUserUser];
            [self getUserInformationoWithJeeId:dicUser[@"jeeId"]];
        }
        else{
            [self.delegateLogin getUserInfoIsDictionary:nil messagePara:0];
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];

}

///获取用户信息
- (void)getUserInformationoWithJeeId:(NSString *)jeeId{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/finduserinfo;JSESSIONID=%@",systemHttpsTyUser,jeeId];
    NSLog(@"%@",urlString);
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicUserInfo = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if (dicUserInfo != nil) {
            NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithDictionary:dicUserInfo];
            ///如果是nsnull 转化为空
            for (NSString *keyDic in dicc.allKeys) {
                id ddd = dicc[keyDic];
                NSLog(@"%@",ddd);
                if ([dicc[keyDic] isEqual:[NSNull null]]) {
                    [dicc setObject:@"" forKey:keyDic];
                }
            }
            [tyUser setObject:dicc forKey:tyUserUserInfo];
            [self.delegateLogin getUserInfoIsDictionary:dicc messagePara:1];
        }
        else{
            [self.delegateLogin getUserInfoIsDictionary:dicUserInfo messagePara:0];
        }
        
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"异常！"];
    }];
}

@end
