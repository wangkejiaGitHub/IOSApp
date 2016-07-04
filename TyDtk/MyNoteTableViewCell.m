//
//  MyNoteTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/23.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyNoteTableViewCell.h"

@implementation MyNoteTableViewCell

- (void)awakeFromNib {
    _buttonDelete.layer.masksToBounds = YES;
    _buttonDelete.layer.cornerRadius= 2;
    _imageUser.layer.masksToBounds = YES;
    _imageUser.layer.cornerRadius = _imageUser.frame.size.height/2;
    NSUserDefaults *tyUseri = [NSUserDefaults standardUserDefaults];
    if ([tyUseri objectForKey:tyUserUserInfo]) {
        NSDictionary *dicUserInfo = [tyUseri objectForKey:tyUserUserInfo];
        [_imageUser sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,dicUserInfo[@"headImg"]]]];
    }
}
- (CGFloat)setModelValueForCellWitnDic:(NSDictionary *)dicNote{
    _noteId = [dicNote[@"Id"] integerValue];
    _labName.text = dicNote[@"UserName"];
    NSString *timeNote = dicNote[@"AddTime"];
    _labTime.text = [timeNote substringToIndex:10];
    NSString *bodyString = dicNote[@"Body"];
    _labNote.text = bodyString;
    
    CGSize labSize = [_labNote sizeThatFits:CGSizeMake(Scr_Width - 15 - 40,MAXFLOAT)];
    _labNoteHeight.constant = labSize.height;
    
    return _labNote.frame.origin.y + _labNoteHeight.constant + 20 + 30;
}
///删除笔记
- (IBAction)buttonDeleteClick:(UIButton *)sender {
    [self.delegateNote deleteNoteWithNoteId:_noteId cell:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
