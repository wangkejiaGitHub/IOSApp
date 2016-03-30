//
//  CustomTools.h
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
//设置代理（回调授权成功）
@protocol CustomToolDelegate<NSObject>
/**
 授权成功获取令牌后回调
 */
- (void)httpSussessReturnClick;
@end
@interface CustomTools : NSObject
@property (nonatomic,assign) id<CustomToolDelegate> delegateTool;
/**
 授权并获取令牌，将令牌存储到tyNSUserDefaults，对应的key为tyUserAccessToken
 */
-(void)empowerAndSignatureWithUserId:(NSString *)userId userName:(NSString *)user classId:(NSString *)cateOrClassId subjectId:(NSString *)courseIdOrSubjectId;
@end
