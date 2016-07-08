//
//  NotesUserTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/10.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesUserTableViewCell.h"

@implementation NotesUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _imageUser.layer.masksToBounds = YES;
    _imageUser.layer.cornerRadius = 20;
    _buttonDelete.layer.masksToBounds = YES;
    _buttonDelete.layer.cornerRadius = 2;
    NSUserDefaults *tyUseri = [NSUserDefaults standardUserDefaults];
    if ([tyUseri objectForKey:tyUserUserInfo]) {
        NSDictionary *dicUserInfo = [tyUseri objectForKey:tyUserUserInfo];
        [_imageUser sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,dicUserInfo[@"headImg"]]]];
    }
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic{
    _dicNotes = dic;
    CGFloat cellHeight = 0;
    _labUserName.text = dic[@"UserName"];
    _labAddTime.text = dic[@"AddTimeString"];
    _labNotes.text = dic[@"Body"];
    CGSize labNotesSize = [_labNotes sizeThatFits:CGSizeMake(_labNotes.bounds.size.width, MAXFLOAT)];
    _labNotesHeight.constant = labNotesSize.height;
    cellHeight = _labNotes.frame.origin.y + _labNotesHeight.constant;
    if (_userParameter == 0) {
        [_buttonDelete removeFromSuperview];
    }
    return cellHeight+20;
}
- (IBAction)buttonDeleteClick:(UIButton *)sender {
    NSInteger noteId = [_dicNotes[@"Id"] integerValue];
    [self.delegateNotes deleteNoteWithNoteId:noteId cell:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
