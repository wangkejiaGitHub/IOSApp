//
//  TopicNumberCard.h
//  TyDtk
//   用于显示收藏和错题的题卡
//  Created by 天一文化 on 16/7/16.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NumberCardDelegate<NSObject>
- (void)getTopicNumber:(NSInteger)topicNumber;
@end
@interface TopicNumberCard : UIView
//试题总数
@property (nonatomic,assign) NSInteger topicNumber;
//显示试题编号的collectView
@property (nonatomic,strong) UICollectionView *collectionViewCard;
/**
 topicNumber : 初始试题总数
 */
@property (nonatomic, assign) id<NumberCardDelegate> delegateNumberTop;
- (id)initWithFrame:(CGRect)frame withTopicNumber:(NSInteger)topicNumber;
@end
