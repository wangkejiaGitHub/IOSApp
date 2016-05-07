//
//  TopicCardCollectionView.h
//  TyDtk
//  **封装答题卡**
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
//重写实例化方法
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout withTopicArray:(NSArray *)arrayTopic;
@end
