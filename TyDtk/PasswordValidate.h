//
//  PasswordValidate.h
//  TyDtk
//
//  Created by 天一文化 on 16/7/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordValidate : NSObject
///验证密码格式是否有误，这里只允许输入数字或字母
+ (BOOL)PassWordStringValidate:(NSString *)password;
@end
