//
//  ViewController.m
//  MKTreeTest
//
//  Created by 张平 on 15/12/24.
//  Copyright © 2015年 zhangping. All rights reserved.
//

#import "MKPeopleSelectTableCell.h"
#import "AppDelegate.h"

#define KOCOLOR_FILES_TITLE [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1] /*#665b53*/
#define KOCOLOR_FILES_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
#define KOCOLOR_FILES_COUNTER [UIColor colorWithRed:141.0/255.0 green:141.0/255.0 blue:141.0/255.0 alpha:1] /
#define KOCOLOR_FILES_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35] /*#ffffff*/
#define KOFONT_FILES_TITLE [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define KOFONT_FILES_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f]

@implementation MKPeopleSelectTableCell


- (void)awakeFromNib {
    self.lineView.frame = CGRectMake(self.lineView.frame.origin.x, self.lineView.frame.origin.y, self.lineView.frame.size.width, 0.5);
    _titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectPeople:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(treeTableViewCell:tapIconWithTreeItem:WithInfo:)]) {
        [self.delegate treeTableViewCell:self tapIconWithTreeItem:self.item WithInfo:self.treeNodeInfo];
    }
}

- (void)setSelect:(BOOL)select
{
    _select = select;
    if (_select) {
        [self.chooseButton setImage:[UIImage imageNamed:@"ico_check_circle"] forState:UIControlStateNormal];
    }
    else{
        [self.chooseButton setImage:[UIImage imageNamed:@"ico_circle_o"] forState:UIControlStateNormal];
    }
}
@end
