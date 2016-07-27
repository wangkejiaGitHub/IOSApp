//
//  StringValidate.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StringValidate.h"

@implementation StringValidate
///验证密码格式是否有误，这里只允许输入数字或字母
+ (BOOL)passWordStringValidate:(NSString *)password{
    NSString *pattern = @"^[[A-Za-z0-9]+$]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}
///验证手机号是否有误
+ (BOOL)phoneNumberStringValidate:(NSString *)phoneNumber{
    NSString *pattern = @"^1+[3-9]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    return isMatch;
}
///   /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
///   ^[A-Za-zd]+([-_.][A-Za-zd]+)*@([A-Za-zd]+[-.])+[A-Za-zd]{2,5}$
///验证邮箱地址
+ (BOOL)emailAddressStringValidate:(NSString *)email{
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:email];
    return isMatch;
}
@end
