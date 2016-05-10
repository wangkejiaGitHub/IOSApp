//
//  TopicAnalysisCardView.h
//  TyDtk
//  模拟试卷分析答题卡
//  Created by 天一文化 on 16/5/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicAnalysisCardDelegate<NSObject>
//点击cell上面的题号，返回题号
- (void)topicCollectonViewCellClick:(NSInteger)indexScroll;
@end
@interface TopicAnalysisCardView : UIView
//所有类型试题数组（单选，多选，一题多问等）
@property (nonatomic,strong) NSArray *arrayTopic;
@property (nonatomic,assign) id <TopicAnalysisCardDelegate> delegateCellClick;
- (id)initWithFrame:(CGRect)frame arrayTopic:(NSArray *)arrayTopic;
@end