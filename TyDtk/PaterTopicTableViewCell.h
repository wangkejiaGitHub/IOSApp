//
//  PaterTopicTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaterTopicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
@property (weak, nonatomic) IBOutlet UILabel *labTopicTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labTitleHeight;

- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
