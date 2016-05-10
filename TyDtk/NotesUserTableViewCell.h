//
//  NotesUserTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/10.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (weak, nonatomic) IBOutlet UILabel *labUserName;
@property (weak, nonatomic) IBOutlet UILabel *labAddTime;
@property (weak, nonatomic) IBOutlet UILabel *labNotes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNotesHeight;
@property (nonatomic,strong) NSDictionary *dicNotes;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic;
@end
