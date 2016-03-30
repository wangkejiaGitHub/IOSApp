//
//  CustomTools.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "CustomTools.h"
@implementation CustomTools

-(NSString *)sha1EncryptString:(NSString *)srcString{
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}
-(void)empowerAndSignatureWithUserId:(NSString *)userId userName:(NSString *)user classId:(NSString *)cateOrClassId subjectId:(NSString *)courseIdOrSubjectId{
    [SVProgressHUD show];
    //建立易操作字典
    NSDictionary *dicUserPar = @{@"appId":@"dtkios",@"userId":userId,@"user":user,@"cate":cateOrClassId,@"courseId":courseIdOrSubjectId,@"appKey":@"Xdtkm17070316begg"};
     NSArray *arrayDic = [dicUserPar allKeys];
    //所有key按照字母排序后的数组
     NSArray *arrayCompare = [arrayDic sortedArrayUsingSelector:@selector(compare:)];
    //新建签名字符串我空，以便追加
    NSString *signatureEver = @"";
    for (int i = 0; i<arrayCompare.count; i++) {
        //按照排序后的key对应value的顺序进行追加签名
        signatureEver = [signatureEver stringByAppendingString:dicUserPar[arrayCompare[i]]];
    }
    //加密之前先转变成大写
    signatureEver = [signatureEver uppercaseString];
    //获取sha1加密后的签名
    NSString *qM = [self sha1EncryptString:signatureEver];
    
    //请求服务器，获取令牌
    NSString *urlString = [NSString stringWithFormat:@"%@api/Authorise/GetAccessToken?appId=dtkios&userId=%@&user=%@&cate=%@&courseId=%@&signature=%@",systemHttps,userId,user,cateOrClassId,courseIdOrSubjectId,qM];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dic[@"datas"];
            NSString *accessToken = dicDatas[@"AccessToken"];
            NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
            //储存或修改令牌
            [tyUser setObject:accessToken forKey:tyUserAccessToken];
            //授权成功，回调方法
            [self.delegateTool httpSussessReturnClick];
            [SVProgressHUD dismiss];
            NSLog(@"11111111");
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作有误，请重试!"];
        }
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常!"];
    }];
}

@end
