//
//  PaterTopicTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicCellDelegate<NSObject>
//传递选项参数，用于同步答题卡
- (void)topicCellSelectClick:(NSInteger)indexTpoic selectDone:(NSString*)selectString;
//cell的伸长和缩短（笔记、记错、收藏）
- (void)cellHetghtChangeWithNE:(NSInteger)indexStep;
@end
@interface PaterTopicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
@property (weak, nonatomic) IBOutlet UILabel *labTopicTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labSelectHeight;
@property (weak, nonatomic) IBOutlet UILabel *labSelectOp;
@property (nonatomic,assign) CGFloat selfHeight;
//笔记试图
@property (nonatomic,strong) UIView *viewNotes;
//纠错试图
@property (nonatomic,strong) UIView *viewError;
@property (nonatomic,assign) NSInteger indexTopic;
@property (nonatomic,assign) id <TopicCellDelegate> delegateCellClick;
@property (nonatomic,assign) NSInteger topicType;
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
- (void)addNotesView:(CGFloat)viewOY;
- (void)addErrorView:(CGFloat)viewOY;
@end
