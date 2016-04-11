//
//  PaterTopicTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicTableViewCell.h"

@implementation PaterTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    _labTopicTitle.text = dic[@"title"];
    _labTopicNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labTopicNumber.text.length*10+15;
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    CGSize labSize = [_labTopicTitle sizeThatFits:CGSizeMake(_labTopicTitle.frame.size.width, MAXFLOAT)];
    _labTitleHeight.constant = labSize.height+20;
    
    return _labTopicTitle.frame.origin.y + _labTitleHeight.constant + 30;
}
@end
