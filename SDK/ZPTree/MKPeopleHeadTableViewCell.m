//
//  MKPeopleHeadTableViewCell.m
//  ChildrenCloud
//
//  Created by 张平 on 15/8/5.
//  Copyright (c) 2015年 Moekee. All rights reserved.
//

#import "MKPeopleHeadTableViewCell.h"

@implementation MKPeopleHeadTableViewCell

- (void)awakeFromNib {
    self.lineView.frame = CGRectMake(self.lineView.frame.origin.x, self.lineView.frame.origin.y, self.lineView.frame.size.width, 0.5);
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
