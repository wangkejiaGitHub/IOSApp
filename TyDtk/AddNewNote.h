//
//  AddNewNote.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewNote : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;
@property (weak, nonatomic) IBOutlet UITextView *textViewNote;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (nonatomic,assign) NSInteger questionId;
@end
