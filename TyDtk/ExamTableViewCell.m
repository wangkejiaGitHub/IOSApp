//
//  ExamTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ExamTableViewCell.h"

@implementation ExamTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _viewL.layer.masksToBounds = YES;
    _viewL.layer.cornerRadius = 3;
    _viewL.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _viewL.layer.borderWidth = 1;
    _viewL.backgroundColor = ColorWithRGB(200, 200, 200);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
