//
//  CollectTopic.h
//  TyDtk
//  用户收藏试题或者取消收藏试题
//  Created by 天一文化 on 16/5/9.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectTopic : NSObject
//收藏试题
+ (void)collectTopicWithQuestionId:(NSInteger)questionId;
//取消收藏试题
+ (void)collectCancelTopicWithQuestionId:(NSInteger)questionId;
@end
