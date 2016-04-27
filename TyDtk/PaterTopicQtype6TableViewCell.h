//
//  PaterTopicQtype6TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaterTopicTableViewCell.h"
@interface PaterTopicQtype6TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTitleType;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCollect;

@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webTitleHeight;
@property (nonatomic,assign) id <TopicCellDelegate> delegateTopic;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
