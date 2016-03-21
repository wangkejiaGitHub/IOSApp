//
//  HttpTools.h
//  AFNetWorking封装
//
//  Created by echo214 on 16/1/15.
//  Copyright © 2016年 echo214. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpTools : NSObject
/**Get请求
 url 服务器请求地址
 success 服务器响应返回的结果
 faile  失败的信息
 */
+ (void)getHttpRequestURL:(NSString *)url RequestSuccess:(void(^)(id repoes,NSURLSessionDataTask *task)) success RequestFaile:(void(^)(NSError *error))faile;
/**Post请求
 url 服务器请求地址
 pram 请求参数
 success 服务器响应返回的结果
 faile  失败的信息
 */
+ (void)postHttpRequestURL:(NSString *)url RequestPram:(id)pram RequestSuccess:(void(^)(id respoes))success RequestFaile:(void(^)(NSError *erro))faile;
/**
 url 服务器请求地址
 pram 请求参数
 data 上传的数据
 success 服务器响应返回的结果
 faile  失败的信息
 */
+ (void)uploadHttpRequestURL:(NSString *)url  RequestPram:(id)pram UploadData:(NSData *)data RequestSuccess:(void(^)(id respoes))success RequestFaile:(void(^)(NSError *erro))faile UploadProgress:(void(^)(NSProgress * uploadProgress))progress;
@end
