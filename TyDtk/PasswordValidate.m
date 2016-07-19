//
//  PasswordValidate.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PasswordValidate.h"

@implementation PasswordValidate
///验证密码格式是否有误，这里只允许输入数字或字母
+ (BOOL)PassWordStringValidate:(NSString *)password{
    NSString *pattern = @"^[[A-Za-z0-9]+$]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}
@end
