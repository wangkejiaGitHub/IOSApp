///Users/tianyiwenhua/Desktop/TyDtk/TyDtk
//  PatersTopicViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicCardRefreshDelegate<NSObject>
//刷新设置答题信息，用于显示做过的题和未做题的信息
- (void)refreshTopicCard:(NSInteger)topicIndex selectString:(NSString *)selectString;
@end
@interface PatersTopicViewController : UIViewController
//题干信息
@property (nonatomic,strong) NSString *topicTitle;
//每道题的字典
@property (nonatomic,strong) NSDictionary *dicTopic;
//每道题的索引
@property (nonatomic,assign) NSInteger topicIndex;
@property (nonatomic,assign) id <TopicCardRefreshDelegate> delegateRefreshTiopicCard;
@end
