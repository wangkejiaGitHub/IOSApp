//
//  CollectTopic.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/9.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "CollectTopic.h"

@implementation CollectTopic
//收藏试题
+ (void)collectTopicWithQuestionId:(NSInteger)questionId{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Collection/Add/%ld?access_token=%@",systemHttps,questionId,accessToken];
    
    
}
//取消收藏试题
+ (void)collectCancelTopicWithQuestionId:(NSInteger)questionId{
    
}
@end
