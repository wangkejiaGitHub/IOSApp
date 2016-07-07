//
//  LoginUser.h
//  TyDtk
//
//  Created by 天一文化 on 16/7/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol LoginDelegate<NSObject>
///msgPara:0.失败、1.成功
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara;
@end
@interface LoginUser : NSObject
- (void)LoginAppWithAccount:(NSString *)account password:(NSString *)pwd;
- (void)getUserInformationoWithJeeId:(NSString *)jeeId;
@property (nonatomic,assign) id<LoginDelegate> delegateLogin;
@end
