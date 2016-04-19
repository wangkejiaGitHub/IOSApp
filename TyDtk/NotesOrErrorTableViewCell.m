//
//  NotesOrErrorTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesOrErrorTableViewCell.h"
@interface NotesOrErrorTableViewCell()<UITextViewDelegate>
@end
@implementation NotesOrErrorTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _textVIew.layer.masksToBounds = YES;
    _textVIew.layer.cornerRadius = 2;
    [_button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [_buttonClear setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _textVIew.delegate = self;
}
- (IBAction)buttonClick:(UIButton *)sender {
    
}
- (IBAction)clearButtonClick:(UIButton *)sender {
    _textVIew.text = @"";
}

//换行时失去焦点
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
