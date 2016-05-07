//
//  AnalysisQtype3TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "AnalysisQtype3TableViewCell.h"

@implementation AnalysisQtype3TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _imageVIewCollect.layer.masksToBounds = YES;
    _imageVIewCollect.layer.cornerRadius = 2;
    _buttonCollect.layer.masksToBounds = YES;
    _buttonCollect.layer.cornerRadius = 2;
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.opaque = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
