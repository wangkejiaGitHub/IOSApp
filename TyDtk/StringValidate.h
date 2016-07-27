//
//  StringValidate.h
//  TyDtk
//
//  Created by 天一文化 on 16/7/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringValidate : NSObject
///验证密码格式是否有误，这里只允许输入数字或字母
+ (BOOL)passWordStringValidate:(NSString *)password;
///验证手机号是否有误
+ (BOOL)phoneNumberStringValidate:(NSString *)phoneNumber;
///验证邮箱地址
+ (BOOL)emailAddressStringValidate:(NSString *)email;
@end
