//
//  CustomTools.h
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface CustomTools : NSObject
/**
 sha1加密>
 参数:需要加密的字符串
 */
+(NSString *)sha1EncryptString:(NSString *)srcString;
/**
 授权并获取令牌
 */
+(NSString *)empowerWithSignature:(NSDictionary *)dicInfo;
@end
