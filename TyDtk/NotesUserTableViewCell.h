//
//  NotesUserTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/10.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NotesDelegateDelete<NSObject>
-(void)deleteNoteWithNoteId:(NSInteger)noteId cell:(UITableViewCell *)cell;
@end
@interface NotesUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (weak, nonatomic) IBOutlet UILabel *labUserName;
@property (weak, nonatomic) IBOutlet UILabel *labAddTime;
@property (weak, nonatomic) IBOutlet UILabel *labNotes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNotesHeight;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (nonatomic,assign) NSInteger userParameter;
@property (nonatomic,assign) id <NotesDelegateDelete> delegateNotes;
@property (nonatomic,strong) NSDictionary *dicNotes;
/**
 dic：笔记信息  notePara：判断是用户笔记还是网友笔记(0:网友笔记，1.用户笔记)
 */
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic withNotsPara:(NSInteger)notePara;
@end
