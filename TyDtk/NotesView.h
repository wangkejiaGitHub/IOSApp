//
//  NotesView.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesView : UIView
@property (weak, nonatomic) IBOutlet UITextView *textVIewNote;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonCenter;
@property (nonatomic,assign) NSInteger questionId;
@end
