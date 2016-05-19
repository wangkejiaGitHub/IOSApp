//
//  TopicCardCollectionView.h
//  TyDtk
//  模拟试卷答题卡
//  Created by 天一文化 on 16/4/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicCardDelegate<NSObject>
//点击cell上面的题号，返回题号
- (void)topicCollectonViewCellClick:(NSInteger)indexScroll;
@end
@interface TopicCardCollectionView : UICollectionView
//所有类型试题数组（单选，多选，一题多问等）
@property (nonatomic,strong) NSArray *arrayTopic;
//用于筛选是否做过该题
@property (nonatomic,strong) NSMutableArray *arrayisMakeTopic;
@property (nonatomic,assign) id <TopicCardDelegate> delegateCellClick;
@property (nonatomic,strong) UILabel *labTimeString;
@property (nonatomic,strong) NSTimer *timerCard;
/**
 重写实例化方法
 parameter（1章节练习，2模拟试卷，3每周精选，4智能出题）等
 */
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout withTopicArray:(NSArray *)arrayTopic paperParameter:(NSInteger)parameter;
@end
