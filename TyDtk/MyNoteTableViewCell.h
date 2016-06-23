//
//  MyNoteTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/23.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesUserTableViewCell.h"
@interface MyNoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labNote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNoteHeight;
@property (nonatomic,assign) NSInteger noteId;
@property (nonatomic,assign) id <NotesDelegateDelete> delegateNote;
- (CGFloat)setModelValueForCellWitnDic:(NSDictionary *)dicNote;
@end
