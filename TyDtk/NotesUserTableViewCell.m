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
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic{
    _dicNotes = dic;
//    [self setUserImage];
    CGFloat cellHeight = 0;
    _labUserName.text = dic[@"UserName"];
    _labAddTime.text = dic[@"AddTimeString"];
    _labNotes.text = dic[@"Body"];
    CGSize labNotesSize = [_labNotes sizeThatFits:CGSizeMake(_labNotes.bounds.size.width, MAXFLOAT)];
    _labNotesHeight.constant = labNotesSize.height;
    cellHeight = _labNotes.frame.origin.y + _labNotesHeight.constant;
    return cellHeight;
}
- (void)setUserImage{
    //c1c8a307-697d-4bce-86ad-27d928c64854
    NSString *userId = _dicNotes[@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"http://www.tydlk.cn/tyuser/front/user/look/json?formSystem=902&id=%@",userId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicUser = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicUser);
    } RequestFaile:^(NSError *error) {
        
    }];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
