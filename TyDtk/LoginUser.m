//
//  LoginUser.m
//  TyDtk
//  登录，→ 测试登录超时
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
        if (codeUser == 1) {
            //[SVProgressHUD showSuccessWithStatus:@"登录成功"];
            NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
            NSDictionary *dicAccount = @{@"acc":account,@"pwd":pwd};
            [tyUser setObject:dicAccount forKey:tyUserAccount];
            [self getUserInformationoWithJeeId:dicUser[@"jeeId"]];
        }
        else{
            [self.delegateLogin getUserInfoIsDictionary:nil messagePara:0];
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
        [self.delegateLogin getUserInfoIsDictionary:nil messagePara:0];
    }];
}

///获取用户信息
- (void)getUserInformationoWithJeeId:(NSString *)jeeId{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/finduserinfo;JSESSIONID=%@",systemHttpsTyUser,jeeId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicUserInfo = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if (dicUserInfo != nil) {
            NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithDictionary:dicUserInfo];
            ///如果是nsnull 转化为空
            for (NSString *keyDic in dicc.allKeys) {
                if ([dicc[keyDic] isEqual:[NSNull null]]) {
                    [dicc setObject:@"" forKey:keyDic];
                }
            }
            ////////////////////////////////////////////////////
            ///如果获取到信息，但是用户是第一次登录，用当前的专业、科目授权
            if ([tyUser objectForKey:tyUserSelectSubject] && ![tyUser objectForKey:tyUserUserInfo]) {
                [self empFirstComeAppWithUserId:dicc[@"userId"] userCode:dicc[@"userCode"]];
            }
            ////////////////////////////////////////////////////
            [tyUser setObject:dicc forKey:tyUserUserInfo];
            [self.delegateLogin getUserInfoIsDictionary:dicc messagePara:1];
        }
        ///登录超时
        else{
            [self.delegateLogin getUserInfoIsDictionary:nil messagePara:0];
        }
    } RequestFaile:^(NSError *error) {
        [self.delegateLogin getUserInfoIsDictionary:@{@"msg":@"异常"} messagePara:0];
    }];
}

/**
 用于授权
 1.第一次登录且已经选过科目（tyUserSelectSubject 有对象存在）,用当前选过的科目进行授权,
 保证用户中心显示的相关信息是当前科目的相关信息
 2.用默认科目授权
 */
- (void)empFirstComeAppWithUserId:(NSString *)userId userCode:(NSString *)user{
    CustomTools *tools = [[CustomTools alloc]init];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicClass = [tyUser objectForKey:tyUserClass];
    NSDictionary *dicSubject = [tyUser objectForKey:tyUserSelectSubject];
    NSString *subjectId = [NSString stringWithFormat:@"%ld",[dicSubject[@"Id"] integerValue]];
    NSString *classId = [NSString stringWithFormat:@"%@",dicClass[@"Id"]];
    [tools empowerAndSignatureWithUserId:userId userCode:user classId:classId subjectId:subjectId];
}

@end
