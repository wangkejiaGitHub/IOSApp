//
//  CustomTools.h
//  TyDtk
//  用户授权，并执行授权成功或者授权失败的操作
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
-(void)httpErrorReturnClick;
@end
@interface CustomTools : NSObject
@property (nonatomic,assign) id<CustomToolDelegate> delegateTool;
/**
 授权并获取令牌，将令牌存储到tyNSUserDefaults，对应的key为tyUserAccessToken
  userId:用户id
  user:用户名
  cateOrClassId:专业分类id
  courseIdOrSubjectId:科目id
 */
-(void)empowerAndSignatureWithUserId:(NSString *)userId userCode:(NSString *)userCode classId:(NSString *)cateOrClassId subjectId:(NSString *)courseIdOrSubjectId;
@end
