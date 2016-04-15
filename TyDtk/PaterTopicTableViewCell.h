//
//  PaterTopicTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicCellDelegate<NSObject>
- (void)topicCellSelectClick:(NSInteger *)idnexTpoic selectDone:(NSString*)selectString;
@end
@interface PaterTopicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
@property (weak, nonatomic) IBOutlet UILabel *labTopicTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labSelectHeight;

@property (weak, nonatomic) IBOutlet UILabel *labSelectOp;
@property (nonatomic,assign) NSInteger topicType;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
