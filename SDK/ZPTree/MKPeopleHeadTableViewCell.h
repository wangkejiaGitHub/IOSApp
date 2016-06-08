//
//  MKPeopleHeadTableViewCell.h
//  ChildrenCloud
//
//  Created by 张平 on 15/8/5.
//  Copyright (c) 2015年 Moekee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKPeopleHeadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *choseConnectLabel;
@property (weak, nonatomic) IBOutlet UIImageView *choseConnectImage;
@property (weak, nonatomic) IBOutlet UILabel *choseCountLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
