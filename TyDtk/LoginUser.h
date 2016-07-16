//
//  LoginUser.h
//  TyDtk
//
//  Created by 天一文化 on 16/7/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol LoginDelegate<NSObject>
///获取用户信息 msgPara:0.失败、1.成功
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara;
///登录失败
- (void)loginUserErrorString:(NSString *)errorStr;
@end
@interface LoginUser : NSObject
- (void)LoginAppWithAccount:(NSString *)account password:(NSString *)pwd;
- (void)getUserInformationoWithJeeId:(NSString *)jeeId;
- (void)empFirstComeAppWithUserId:(NSString *)userId userCode:(NSString *)user;
@property (nonatomic,assign) id<LoginDelegate> delegateLogin;
@end
