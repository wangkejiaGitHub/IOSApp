//
//  HttpTools.m
//  AFNetWorking封装
//  用于网络get post 请求
//  Created by echo214 on 16/1/15.
//  Copyright © 2016年 echo214. All rights reserved.
//

#import "HttpTools.h"
#import "AFNetworking.h"
@implementation HttpTools
+(void)getHttpRequestURL:(NSString *)url RequestSuccess:(void(^)(id respoes,NSURLSessionDataTask * task))success RequestFaile:(void(^)(NSError *erro))faile{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//放弃解析
    
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {//如果成功，返回结果
            success(responseObject,task);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        faile(error);
    }];
}

//post 
+(void)postHttpRequestURL:(NSString *)url RequestPram:(id)pram RequestSuccess:(void(^)(id respoes))success RequestFaile:(void(^)(NSError *erro))faile{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:pram progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        faile(error);
    }];
    
    
}

//上传
+(void)uploadHttpRequestURL:(NSString *)url  RequestPram:(id)pram UploadData:(NSData *)data RequestSuccess:(void(^)(id respoes))success RequestFaile:(void(^)(NSError *erro))faile UploadProgress:(void(^)(NSProgress * uploadProgress))progress{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:pram constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *fileName = [formatter stringFromDate:date];
        NSLog(@"fileName == %@",fileName);
        [formData appendPartWithFileData:data name:@"headimg" fileName:@"ghfhhfh.jpg" mimeType:@"image/jpg"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        faile(error);
    }];
}
@end
